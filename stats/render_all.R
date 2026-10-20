# =============================================================================
# render_all.R — Render all HTML reports for Load and Flow papers.
# Source this file (not Render) to generate all outputs on L:
# =============================================================================
library(quarto)
library(glue)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
DATE_STR <- format(Sys.Date(), "%Y%m%d")

# ==============================================================================
# TOGGLES — set to TRUE/FALSE to control what gets rendered
# ==============================================================================

RUN_BEHAVIOR <- FALSE
RUN_FLOW     <- FALSE
RUN_LOAD     <- TRUE

# Behavior sub-toggles
RUN_BEHAV_QUEST     <- FALSE   # questionnaires (flow + load, active + passive)
RUN_BEHAV_ODDBALL   <- FALSE   # oddball response (flow + load)
RUN_BEHAV_COUNTING  <- FALSE   # passive fixation-cross counting accuracy (load only)

# Flow sub-toggles
RUN_FLOW_ERP             <- FALSE  # analysis_erp_flow.qmd (active + passive, raw + diff)
RUN_FLOW_CASTELLAR       <- FALSE  # castellar stim + resp
RUN_FLOW_FREQ_CASTELLAR  <- FALSE  # analysis_freq_castellar.qmd (active only)
RUN_FLOW_FREQ_CONTINUOUS <- FALSE  # analysis_freq_continuous.qmd (active + passive)

# Load sub-toggles
RUN_LOAD_ERP             <- FALSE  # analysis_erp_load.qmd (active + passive, raw + diff)
RUN_LOAD_LATERALITY      <- TRUE  # analysis_erp_load_laterality.qmd
RUN_LOAD_RESP_P3         <- FALSE  # analysis_erp_load_resp_p3.qmd
RUN_LOAD_ACTION          <- FALSE  # analysis_erp_load_action.qmd (active + passive)
RUN_LOAD_FREQ_CONTINUOUS <- FALSE  # analysis_freq_continuous.qmd (active only)

# ==============================================================================
# PATHS
# ==============================================================================

RESULTS_LOAD_ACTIVE  <- "L:/EEG_Flow_data/Study_EEG_Flow_Active/derivatives_v2/outputs/stats/load/"
RESULTS_LOAD_PASSIVE <- "L:/EEG_Flow_data/Study_EEG_Flow_Passive/derivatives_v2/outputs/stats/load/"
RESULTS_FLOW_ACTIVE  <- "L:/EEG_Flow_data/Study_EEG_Flow_Active/derivatives_v2/outputs/stats/flow/"
RESULTS_FLOW_PASSIVE <- "L:/EEG_Flow_data/Study_EEG_Flow_Passive/derivatives_v2/outputs/stats/flow/"

RESULTS_FLOW_FREQ_CASTELLAR  <- file.path(RESULTS_FLOW_ACTIVE,  "freq_castellar")
RESULTS_FLOW_FREQ_CONTINUOUS_ACTIVE  <- file.path(RESULTS_FLOW_ACTIVE,  "freq_continuous")
RESULTS_FLOW_FREQ_CONTINUOUS_PASSIVE <- file.path(RESULTS_FLOW_PASSIVE, "freq_continuous")
RESULTS_LOAD_FREQ_CONTINUOUS_ACTIVE  <- file.path(RESULTS_LOAD_ACTIVE,  "freq_continuous")
RESULTS_LOAD_FREQ_CONTINUOUS_PASSIVE <- file.path(RESULTS_LOAD_PASSIVE, "freq_continuous")

RESULTS_BEHAVIOR_FLOW_ACTIVE  <- file.path(RESULTS_FLOW_ACTIVE,  "behavior")
RESULTS_BEHAVIOR_FLOW_PASSIVE <- file.path(RESULTS_FLOW_PASSIVE, "behavior")
RESULTS_BEHAVIOR_LOAD_ACTIVE  <- file.path(RESULTS_LOAD_ACTIVE,  "behavior")
RESULTS_BEHAVIOR_LOAD_PASSIVE <- file.path(RESULTS_LOAD_PASSIVE, "behavior")

for (d in c(
  RESULTS_LOAD_ACTIVE, RESULTS_LOAD_PASSIVE,
  RESULTS_FLOW_ACTIVE, RESULTS_FLOW_PASSIVE,
  RESULTS_FLOW_FREQ_CASTELLAR,
  RESULTS_FLOW_FREQ_CONTINUOUS_ACTIVE, RESULTS_FLOW_FREQ_CONTINUOUS_PASSIVE,
  RESULTS_LOAD_FREQ_CONTINUOUS_ACTIVE, RESULTS_LOAD_FREQ_CONTINUOUS_PASSIVE,
  RESULTS_BEHAVIOR_FLOW_ACTIVE, RESULTS_BEHAVIOR_FLOW_PASSIVE,
  RESULTS_BEHAVIOR_LOAD_ACTIVE, RESULTS_BEHAVIOR_LOAD_PASSIVE
)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}

# ==============================================================================
# Helper
# ==============================================================================

render_and_move <- function(qmd_file, out_dir, out_name, ...) {
  cat(glue("\nRendering: {out_name} ...\n"))
  tryCatch({
    quarto::quarto_render(qmd_file, output_format = "html", quiet = FALSE, ...)
    local_html <- sub("\\.qmd$", ".html", qmd_file)
    dest       <- file.path(out_dir, out_name)
    dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
    success <- file.copy(local_html, dest, overwrite = TRUE)
    if (success) {
      file.remove(local_html)
      cat(glue("  Saved -> {dest}\n\n"))
    } else {
      cat(glue("  ERROR: copy failed\n"))
    }
  },
  error = function(e) cat(glue("  ERROR: {e$message}\n")))
}

# ==============================================================================
# LOAD PAPER
# ==============================================================================

if (RUN_LOAD) {
  cat("\n=== LOAD ===\n")

  if (RUN_LOAD_ERP) {
    load_combos <- list(
      list(paradigm = "passive", measure = "raw",  out_dir = RESULTS_LOAD_PASSIVE),
      list(paradigm = "passive", measure = "diff", out_dir = RESULTS_LOAD_PASSIVE),
      list(paradigm = "active",  measure = "raw",  out_dir = RESULTS_LOAD_ACTIVE),
      list(paradigm = "active",  measure = "diff", out_dir = RESULTS_LOAD_ACTIVE)
    )
    for (combo in load_combos) {
      render_and_move(
        qmd_file       = "analyses/analysis_erp_load.qmd",
        out_dir        = combo$out_dir,
        out_name       = glue("{combo$paradigm}_load_{combo$measure}_{DATE_STR}.html"),
        execute_params = list(paradigm = combo$paradigm, measure = combo$measure)
      )
    }
  }

  if (RUN_LOAD_LATERALITY) {
    for (stim in c("target", "novel")) {
      render_and_move(
        qmd_file       = "analyses/analysis_erp_load_laterality.qmd",
        out_dir        = file.path(RESULTS_LOAD_ACTIVE, "laterality"),
        out_name       = glue("active_load_laterality_ind_{stim}_FC_C_{DATE_STR}.html"),
        execute_params = list(
          aggregate_by_laterality = FALSE,
          stim                    = stim,
          cohort                  = "full",
          laterality_row          = "FC_C",
          window                  = if (stim == "target") "180-230ms" else "150-220ms"
        )
      )
    }
  }

  if (RUN_LOAD_RESP_P3) {
    render_and_move(
      qmd_file = "analyses/analysis_erp_load_resp_p3.qmd",
      out_dir  = file.path(RESULTS_LOAD_ACTIVE, "resp_p3"),
      out_name = glue("active_load_resp_p3_{DATE_STR}.html")
    )
  }

  if (RUN_LOAD_ACTION) {
    for (paradigm in c("active", "passive")) {
      render_and_move(
        qmd_file       = "analyses/analysis_erp_load_action.qmd",
        out_dir        = file.path(
          if (paradigm == "active") RESULTS_LOAD_ACTIVE else RESULTS_LOAD_PASSIVE,
          "correlations_action"),
        out_name       = glue("{paradigm}_load_action_erp_{DATE_STR}.html"),
        execute_params = list(paradigm = paradigm)
      )
    }
  }

  if (RUN_LOAD_FREQ_CONTINUOUS) {
    load_freq_continuous_combos <- list(
      list(paradigm = "active",  out_dir = RESULTS_LOAD_FREQ_CONTINUOUS_ACTIVE),
      list(paradigm = "passive", out_dir = RESULTS_LOAD_FREQ_CONTINUOUS_PASSIVE)
    )
    for (combo in load_freq_continuous_combos) {
      render_and_move(
        qmd_file       = "analyses/analysis_freq_continuous.qmd",
        out_dir        = combo$out_dir,
        out_name       = glue("{combo$paradigm}_load_freq_continuous_{DATE_STR}.html"),
        execute_params = list(paradigm = combo$paradigm, paper = "load")
      )
    }
  }
}

# ==============================================================================
# FLOW PAPER
# ==============================================================================

if (RUN_FLOW) {
  cat("\n=== FLOW ===\n")

  if (RUN_FLOW_ERP) {
    flow_combos <- list(
      list(paradigm = "passive", measure = "raw",  out_dir = RESULTS_FLOW_PASSIVE),
      list(paradigm = "passive", measure = "diff", out_dir = RESULTS_FLOW_PASSIVE),
      list(paradigm = "active",  measure = "raw",  out_dir = RESULTS_FLOW_ACTIVE),
      list(paradigm = "active",  measure = "diff", out_dir = RESULTS_FLOW_ACTIVE)
    )
    for (combo in flow_combos) {
      render_and_move(
        qmd_file       = "analyses/analysis_erp_flow.qmd",
        out_dir        = combo$out_dir,
        out_name       = glue("{combo$paradigm}_flow_{combo$measure}_{DATE_STR}.html"),
        execute_params = list(paradigm = combo$paradigm, measure = combo$measure)
      )
    }
  }

  if (RUN_FLOW_CASTELLAR) {
    render_and_move(
      qmd_file = "analyses/analysis_erp_flow_castellar_stim.qmd",
      out_dir  = file.path(RESULTS_FLOW_ACTIVE, "castellar"),
      out_name = glue("active_flow_castellar_stim_{DATE_STR}.html")
    )
    render_and_move(
      qmd_file = "analyses/analysis_erp_flow_castellar_resp.qmd",
      out_dir  = file.path(RESULTS_FLOW_ACTIVE, "castellar"),
      out_name = glue("active_flow_castellar_resp_{DATE_STR}.html")
    )
  }

  if (RUN_FLOW_FREQ_CASTELLAR) {
    render_and_move(
      qmd_file = "analyses/analysis_freq_castellar.qmd",
      out_dir  = RESULTS_FLOW_FREQ_CASTELLAR,
      out_name = glue("active_freq_flow_castellar_{DATE_STR}.html")
    )
  }

  if (RUN_FLOW_FREQ_CONTINUOUS) {
    freq_continuous_combos <- list(
      list(paradigm = "active",  out_dir = RESULTS_FLOW_FREQ_CONTINUOUS_ACTIVE),
      list(paradigm = "passive", out_dir = RESULTS_FLOW_FREQ_CONTINUOUS_PASSIVE)
    )
    for (combo in freq_continuous_combos) {
      render_and_move(
        qmd_file       = "analyses/analysis_freq_continuous.qmd",
        out_dir        = combo$out_dir,
        out_name       = glue("{combo$paradigm}_flow_freq_continuous_{DATE_STR}.html"),
        execute_params = list(paradigm = combo$paradigm, paper = "flow")
      )
    }
  }
}

# ==============================================================================
# BEHAVIOR
# ==============================================================================

if (RUN_BEHAVIOR) {
  cat("\n=== BEHAVIOR ===\n")

  if (RUN_BEHAV_QUEST) {
    behav_combos <- list(
      list(paper = "flow", paradigm = "active",  out_dir = RESULTS_BEHAVIOR_FLOW_ACTIVE),
      list(paper = "flow", paradigm = "passive", out_dir = RESULTS_BEHAVIOR_FLOW_PASSIVE),
      list(paper = "load", paradigm = "active",  out_dir = RESULTS_BEHAVIOR_LOAD_ACTIVE),
      list(paper = "load", paradigm = "passive", out_dir = RESULTS_BEHAVIOR_LOAD_PASSIVE)
    )
    for (combo in behav_combos) {
      render_and_move(
        qmd_file       = glue("analyses/analysis_behav_questionnaires_{combo$paper}.qmd"),
        out_dir        = combo$out_dir,
        out_name       = glue("{combo$paradigm}_{combo$paper}_questionnaires_{DATE_STR}.html"),
        execute_params = list(paradigm = combo$paradigm)
      )
    }
  }

  if (RUN_BEHAV_ODDBALL) {
    render_and_move(
      qmd_file = "analyses/analysis_behav_oddball_flow.qmd",
      out_dir  = RESULTS_BEHAVIOR_FLOW_ACTIVE,
      out_name = glue("active_flow_oddball_{DATE_STR}.html")
    )
    render_and_move(
      qmd_file = "analyses/analysis_behav_oddball_load.qmd",
      out_dir  = RESULTS_BEHAVIOR_LOAD_ACTIVE,
      out_name = glue("active_load_oddball_{DATE_STR}.html")
    )
  }

  if (RUN_BEHAV_COUNTING) {
    render_and_move(
      qmd_file = "analyses/analysis_behav_counting_load.qmd",
      out_dir  = RESULTS_BEHAVIOR_LOAD_PASSIVE,
      out_name = glue("passive_load_counting_{DATE_STR}.html")
    )
  }
}

cat("\n=== All done. ===\n")
