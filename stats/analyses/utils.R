# =============================================================================
# utils.R — Shared functions for ERP statistical analyses
# =============================================================================

library(car)
library(ggpubr)
library(rstatix)
library(glue)
library(tidyverse)
library(BayesFactor)  # NEW: replaces JASP workflow -- ttestBF() uses the same
                       # JZS default prior (r=0.707) as JASP/pingouin, so
                       # numbers stay consistent with the multiverse analysis

# Force tidyverse functions to take priority
filter    <- dplyr::filter
select    <- dplyr::select
summarise <- dplyr::summarise

# =============================================================================
# Data loading and filtering
# =============================================================================

load_cluster_data <- function(csv_path, condition_map, included_participants) {
  if (!file.exists(csv_path)) {
    stop(glue("File not found: {csv_path}"))
  }
  df <- read.csv(csv_path, sep = ",") %>%
    filter(participant %in% included_participants)

  if ("task" %in% names(df)) {
    df <- df %>% rename(condition = task)
  }

  cond_df <- tibble(
    condition     = names(condition_map),
    condition_new = unname(condition_map)
  )
  df <- df %>%
    left_join(cond_df, by = "condition") %>%
    mutate(condition = coalesce(condition_new, condition)) %>%
    select(-condition_new)

  df
}

# -----------------------------------------------------------------------------
# Stimulus-locked measure CSVs — two variants since 2026-10-30:
#   trials = "correct"   -> correct trials only (primary analysis)
#   trials = "alltrials" -> all trials (sensitivity analysis)
# Matches the exact file-name pattern written by extract_measures.ipynb, so an
# old CSV without the trials suffix, or the other variant, can never be picked.
# date_source = NULL picks the latest date; a "YYYYMMDD" string pins one.
# -----------------------------------------------------------------------------
find_stim_measures <- function(data_root, paradigm, paper,
                               measure = c("raw", "diff"),
                               trials  = c("correct", "alltrials"),
                               date_source = NULL) {
  measure  <- match.arg(measure)
  trials   <- match.arg(trials)
  date_pat <- if (is.null(date_source)) "[0-9]{8}" else date_source
  pat <- sprintf("^%s_%s_[0-9]+p_%s_stim_%s_%s_allch_allwin_meanamp\\.csv$",
                 date_pat, paradigm, paper, measure, trials)
  files <- sort(list.files(data_root, pattern = pat), decreasing = TRUE)
  if (length(files) == 0) {
    stop(sprintf("No %s %s stim %s CSV for trials='%s'%s in %s",
                 paper, paradigm, measure, trials,
                 if (is.null(date_source)) "" else paste0(" and date ", date_source),
                 data_root))
  }
  same_date <- files[substr(files, 1, 8) == substr(files[1], 1, 8)]
  if (length(same_date) > 1) {
    stop("Several CSVs share the same date, pin one explicitly: ",
         paste(same_date, collapse = ", "))
  }
  message("Using: ", files[1])
  file.path(data_root, files[1])
}

filter_condition <- function(df, stim_val, window_val, electrodes) {
  # Handle both "stim" (raw) and "contrast" (diff) column names
  stim_col <- if ("stim" %in% names(df)) "stim" else "contrast"
  
  df %>%
    filter(
      .data[[stim_col]] == stim_val,
      window  %in% c(window_val, paste0(window_val, "ms")),
      ch_name %in% electrodes
    ) %>%
    group_by(participant, condition, .data[[stim_col]], window) %>%
    summarise(mean_amp_uv = mean(mean_amp_uv, na.rm = TRUE), .groups = "drop") %>%
    rename(stim = .data[[stim_col]])  # normalize to "stim" for downstream
}

# =============================================================================
# Assumption checks
# =============================================================================

run_checks <- function(df_wide, condition_levels, output_dir, label) {
  col_a <- paste0("mean_amp_uv.", condition_levels[1])
  col_b <- paste0("mean_amp_uv.", condition_levels[2])

  if (!all(c(col_a, col_b) %in% names(df_wide))) {
    warning(glue("Columns not found for {label}: {col_a}, {col_b}"))
    return(NULL)
  }

  diffs   <- as.numeric(df_wide[[col_a]]) - as.numeric(df_wide[[col_b]])
  shapiro <- shapiro.test(diffs)

  df_long <- df_wide %>%
    select(participant, all_of(c(col_a, col_b))) %>%
    pivot_longer(cols = -participant, names_to = "condition", values_to = "mean_amp_uv")
  levene <- leveneTest(mean_amp_uv ~ condition, data = df_long)

  if (!is.null(output_dir)) {
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    png(file.path(output_dir, glue("{label}_hist.png")), width = 600, height = 400)
    hist(diffs, main = glue("Differences: {label}"), xlab = "uV", breaks = 12, col = "#3498DB")
    dev.off()
    png(file.path(output_dir, glue("{label}_qq.png")), width = 600, height = 400)
    qqnorm(diffs, main = glue("Q-Q Plot: {label}"))
    qqline(diffs, col = "red")
    dev.off()
  }

  list(shapiro = shapiro, levene = levene, diffs = diffs, df_long = df_long)
}

# =============================================================================
# Statistical tests
# =============================================================================

run_paired_ttest <- function(df_wide, condition_levels) {
  col_a <- paste0("mean_amp_uv.", condition_levels[1])
  col_b <- paste0("mean_amp_uv.", condition_levels[2])

  t_result <- t.test(df_wide[[col_a]], df_wide[[col_b]], paired = TRUE)

  # Bayesian paired t-test, JZS prior r=0.707 (BayesFactor's default,
  # matches JASP/pingouin -- same convention as the multiverse analysis).
  # Reported for EVERY test per PI directive, not conditionally on p >= .05
  # (that conditional convention was used only for the multiverse analysis).
  bf_result <- ttestBF(x = df_wide[[col_a]], y = df_wide[[col_b]], paired = TRUE)
  bf10      <- as.numeric(extractBF(bf_result)$bf)
  bf01      <- 1 / bf10

  df_long <- df_wide %>%
    select(participant, all_of(c(col_a, col_b))) %>%
    pivot_longer(cols = -participant, names_to = "condition", values_to = "mean_amp_uv") %>%
    mutate(condition = factor(condition,
                              levels = c(col_a, col_b),
                              labels = condition_levels))

  d_result <- df_long %>% cohens_d(mean_amp_uv ~ condition, paired = TRUE, ref.group = condition_levels[1])

  list(t = t_result, d = d_result, bf10 = bf10, bf01 = bf01, df_long = df_long)
}

# =============================================================================
# APA text generation
# =============================================================================

interpret_d <- function(d) {
  if (is.na(d)) return("unknown")
  abs_d <- abs(d)
  if      (abs_d < 0.2) "negligible"
  else if (abs_d < 0.5) "small"
  else if (abs_d < 0.8) "medium"
  else                  "large"
}

format_p <- function(p) {
  if (p < .001) "p < .001"
  else          glue("p = {format(round(p, 3), nsmall = 3)}")
}

# NEW: clean display for BF10, switching to scientific notation for
# extreme values (raw JZS output can return awkward numbers like 1e-8
# or 50000+ that look bad printed directly with round()).
format_bf <- function(bf, digits = 2) {
  if (is.na(bf) || is.infinite(bf)) return("NA")
  if (bf >= 1000 || bf < 0.001) {
    glue("{formatC(bf, format = 'e', digits = digits)}")
  } else {
    glue("{round(bf, digits)}")
  }
}

apa_ttest <- function(t_result, d_result, bf10, component, stim, window, cluster,
                      condition_levels, means, sds) {
  t_val  <- round(as.numeric(t_result$statistic), 2)
  df_val <- round(as.numeric(t_result$parameter), 1)
  p_val  <- as.numeric(t_result$p.value)
  d_val  <- round(as.numeric(d_result$effsize), 2)
  d_int  <- interpret_d(d_val)
  p_str  <- format_p(p_val)
  bf_str <- format_bf(bf10)

  sig_str <- if (p_val < .05) "significantly" else "not significantly"
  dir_str <- if (t_val > 0) "greater" else "smaller"

  glue(
    "{component} mean amplitude ({stim}, {window}, {cluster} cluster): ",
    "{condition_levels[1]} (M = {round(as.numeric(means[1]), 2)}, SD = {round(as.numeric(sds[1]), 2)} uV) was ",
    "{sig_str} {dir_str} than {condition_levels[2]} ",
    "(M = {round(as.numeric(means[2]), 2)}, SD = {round(as.numeric(sds[2]), 2)} uV), ",
    "t({df_val}) = {t_val}, {p_str}, d = {d_val} ({d_int} effect), BF10 = {bf_str}."
  )
}

# =============================================================================
# Summary row builder
# =============================================================================

build_summary_row <- function(component, stim, window, cluster,
                               condition_levels, means, sds,
                               t_result, d_result, bf10, bf01) {
  p_val <- as.numeric(t_result$p.value)
  tibble(
    Component  = component,
    Stim       = stim,
    Window     = window,
    Cluster    = cluster,
    !!glue("Mean_{condition_levels[1]}") := round(as.numeric(means[1]), 3),
    !!glue("SD_{condition_levels[1]}")   := round(as.numeric(sds[1]),   3),
    !!glue("Mean_{condition_levels[2]}") := round(as.numeric(means[2]), 3),
    !!glue("SD_{condition_levels[2]}")   := round(as.numeric(sds[2]),   3),
    t        = round(as.numeric(t_result$statistic), 3),
    df       = round(as.numeric(t_result$parameter), 1),
    p        = round(p_val, 4),
    p_star   = case_when(
      p_val < .001 ~ "***",
      p_val < .01  ~ "**",
      p_val < .05  ~ "*",
      TRUE         ~ ""
    ),
    d        = round(as.numeric(d_result$effsize), 3),
    d_interp = interpret_d(as.numeric(d_result$effsize)),
    BF10     = round(bf10, 3),
    BF01     = round(bf01, 3)
  )
}

# =============================================================================
# Boxplot
# =============================================================================

plot_boxplot <- function(df_long, condition_levels, condition_colors,
                         component, stim, window, cluster) {
  N <- n_distinct(df_long$participant)

  df_long %>%
    mutate(condition = factor(condition, levels = condition_levels)) %>%
    ggplot(aes(x = condition, y = mean_amp_uv, fill = condition)) +
    geom_boxplot(color = "black", outlier.shape = 21) +
    scale_fill_manual(values = condition_colors) +
    scale_y_reverse() +
    labs(
      title    = glue("{component} - {stim} | {window} | {cluster} cluster"),
      subtitle = glue("N = {N}"),
      x        = NULL,
      y        = "Mean amplitude (uV)"
    ) +
    theme_classic(base_size = 13) +
    theme(legend.position = "none")
}


filter_condition_allch <- function(df, stim_val, window_val, electrodes) {
  stim_col <- if ("stim" %in% names(df)) "stim" else "contrast"
  
  df %>%
    filter(
      .data[[stim_col]] == stim_val,
      window  %in% c(window_val, paste0(window_val, "ms")),
      ch_name %in% electrodes
    ) %>%
    rename(stim = .data[[stim_col]])
}
