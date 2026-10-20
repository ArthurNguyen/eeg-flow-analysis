# =============================================================================
# utils_freq.R — Shared functions for frequency-band power analyses
# Used by analysis_freq_castellar.qmd and analysis_freq_continuous.qmd
# =============================================================================

library(dplyr)
library(tidyverse)
library(ggpubr)
library(rstatix)
library(glue)
library(lsr)
library(BayesFactor)

# =============================================================================
# Data filtering
# cond1/cond2 are passed in dynamically so this works for both:
#   flow:  UT_highflow / UT_lowflow
#   load:  Simple / Complex
# =============================================================================

filter_data_band <- function(data, electrodes,
                             cond1 = "UT_highflow", cond2 = "UT_lowflow") {
  data %>%
    filter(electrode %in% electrodes) %>%
    filter(cond %in% c(cond1, cond2)) %>%
    mutate(
      electrode = factor(electrode, levels = electrodes),
      cond      = factor(cond, levels = c(cond1, cond2))
    )
}

# =============================================================================
# Boxplot
# =============================================================================

create_band_boxplot <- function(df, band,
                                cond1 = "UT_highflow", cond2 = "UT_lowflow",
                                label1 = "High Flow",  label2 = "Low Flow") {
  N      <- df %>% summarize(N = n_distinct(participant)) %>% pull(N)
  colors <- setNames(c("#E74C3C", "#2ECC71"), c(cond1, cond2))
  labels <- setNames(c(label1, label2),       c(cond1, cond2))

  ggplot(df, aes(x = electrode, y = power, fill = cond)) +
    geom_boxplot(color = "black") +
    scale_fill_manual(values = colors, labels = labels, name = "Condition") +
    labs(
      title = glue("{toupper(band)} band: Power (N={N})"),
      x = "Electrode", y = "Power"
    ) +
    theme_classic(base_size = 13) +
    theme(plot.title = element_text(hjust = 0.5), legend.position = "top")
}

# =============================================================================
# Frequentist repeated-measures ANOVA (electrode x condition)
# =============================================================================

run_band_anova <- function(df) {
  # rstatix::anova_test only returns one effect-size type per call --
  # run twice and merge.
  res_ges <- anova_test(data = df, dv = power, wid = participant,
                        within = c(electrode, cond), type = 2, effect.size = "ges")
  res_pes <- anova_test(data = df, dv = power, wid = participant,
                        within = c(electrode, cond), type = 2, effect.size = "pes")

  table_ges     <- get_anova_table(res_ges)
  table_ges$pes <- get_anova_table(res_pes)$pes

  res_ges$ANOVA <- table_ges
  res_ges
}

# =============================================================================
# Bayesian repeated-measures ANOVA (electrode x condition)
# =============================================================================

run_band_anova_bayesian <- function(df) {
  df_bf <- df %>%
    mutate(participant = factor(participant),
           electrode   = factor(electrode),
           cond        = factor(cond))

  bf_models <- anovaBF(
    power ~ electrode * cond + participant,
    data        = df_bf,
    whichRandom = "participant",
    whichModels = "withmain",
    progress    = FALSE
  )

  bf_df       <- as.data.frame(bf_models)
  bf_df$model <- rownames(bf_df)

  normalize_term <- function(term) {
    if (grepl(":", term)) {
      parts <- sort(trimws(strsplit(term, ":")[[1]]))
      paste(parts, collapse = ":")
    } else {
      trimws(term)
    }
  }

  get_bf_for_model <- function(target_terms) {
    target_norm <- sort(sapply(target_terms, normalize_term))
    terms_list  <- strsplit(bf_df$model, "\\s*\\+\\s*")
    matches <- sapply(terms_list, function(terms) {
      setequal(sort(sapply(terms, normalize_term)), target_norm)
    })
    if (sum(matches) != 1) {
      warning(glue("Expected exactly 1 match for {paste(target_terms, collapse=', ')}, found {sum(matches)}."))
      return(NA)
    }
    bf_df$bf[matches]
  }

  bf_electrode   <- get_bf_for_model(c("electrode", "participant"))
  bf_cond        <- get_bf_for_model(c("cond", "participant"))
  bf_maineffects <- get_bf_for_model(c("cond", "electrode", "participant"))
  bf_full        <- get_bf_for_model(c("cond", "electrode", "cond:electrode", "participant"))
  bf_interaction <- bf_full / bf_maineffects

  list(
    bf_df  = bf_df,
    lookup = c("electrode"      = bf_electrode,
               "cond"           = bf_cond,
               "electrode:cond" = bf_interaction)
  )
}

# =============================================================================
# Sphericity reporting
# =============================================================================

format_sphericity_note <- function(res, term) {
  mauchly <- res$`Mauchly's Test for Sphericity`
  spheri  <- res$`Sphericity Corrections`

  if (is.null(mauchly) || !(term %in% mauchly$Effect)) {
    return("(sphericity N/A -- factor has only 2 levels)")
  }

  m_row   <- mauchly[mauchly$Effect == term, ]
  w_val   <- round(as.numeric(m_row$W), 3)
  m_p     <- as.numeric(m_row$p)
  m_p_str <- format_p(m_p)

  if (m_p >= .05) {
    return(glue("(Mauchly's W = {w_val}, {m_p_str} -- sphericity assumed, uncorrected values reported)"))
  }

  s_row   <- spheri[spheri$Effect == term, ]
  epsilon <- round(as.numeric(s_row$GGe), 3)
  glue("(Mauchly's W = {w_val}, {m_p_str} -- sphericity violated; ",
       "Greenhouse-Geisser corrected, epsilon = {epsilon})")
}

# =============================================================================
# Residuals
# =============================================================================

fit_residuals <- function(df) {
  aov(power ~ electrode * cond + Error(participant / (electrode * cond)), data = df)
}

extract_within_residuals <- function(fit_aov) {
  residuals(fit_aov[["participant:electrode:cond"]])
}

# save_residual_checks kept for backward compatibility — now just returns shapiro
save_residual_checks <- function(fit_aov, res_name, output_dir = NULL) {
  res <- extract_within_residuals(fit_aov)
  shapiro.test(res)
}

# =============================================================================
# Cohen's d for posthoc comparisons
# =============================================================================

calc_cohens_d_posthoc <- function(df, cond1, cond2, elec_val, dep_var = "power") {
  data1 <- df %>% filter(cond == cond1, electrode == elec_val) %>% pull(!!sym(dep_var))
  data2 <- df %>% filter(cond == cond2, electrode == elec_val) %>% pull(!!sym(dep_var))
  diffs <- data1 - data2
  mean(diffs) / sd(diffs)
}

# =============================================================================
# Bayesian posthoc: per-electrode paired t-test
# =============================================================================

run_band_posthoc_bayesian <- function(df, cond1, cond2) {
  map_dfr(levels(df$electrode), function(elec) {
    df_wide <- df %>%
      filter(electrode == elec) %>%
      pivot_wider(id_cols = participant, names_from = cond, values_from = power) %>%
      drop_na(all_of(c(cond1, cond2)))
    bf_res <- ttestBF(x = df_wide[[cond1]], y = df_wide[[cond2]], paired = TRUE)
    tibble(electrode = elec, BF10 = as.numeric(extractBF(bf_res)$bf))
  }) %>%
    mutate(BF01 = 1 / BF10)
}
