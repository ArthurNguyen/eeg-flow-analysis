# Statistical Analyses — R/Quarto

All analyses use R with Quarto (`.qmd`). Outputs (HTML reports, CSV summaries) are written to `derivatives_v2/outputs/stats/` on the NAS.

---

## Running analyses

**Render all at once:**
```r
source("render_all.R")
```
Toggles at the top of `render_all.R` control which papers and paradigms are rendered. All default to `FALSE` — set to `TRUE` selectively.

**Render a single file:**
```r
quarto::quarto_render(
  "analyses/analysis_erp_load.qmd",
  execute_params = list(paradigm = "active")
)
```

---

## File overview

| File | Paper | Description |
|------|-------|-------------|
| `analysis_erp_load.qmd` | Load | 2-way RM ANOVA: condition × electrode, stim-locked ERP |
| `analysis_erp_load_laterality.qmd` | Load | N2 laterality (FC2/C2), active only |
| `analysis_erp_load_resp_p3.qmd` | Load | Response-locked P3 |
| `analysis_erp_load_action.qmd` | Load | ERP × action experience (linear model + median split) |
| `analysis_erp_flow.qmd` | Flow | High vs low flow, stim-locked ERP |
| `analysis_erp_flow_castellar_stim.qmd` | Flow | Castellar replication, stim-locked |
| `analysis_erp_flow_castellar_resp.qmd` | Flow | Castellar replication, response-locked (FCz only) |
| `analysis_freq_castellar.qmd` | Flow | Alpha/theta/beta band power, Castellar method |
| `analysis_freq_continuous.qmd` | Both | Continuous band power; `params$paper` selects flow or load |
| `analysis_behav_questionnaires_flow.qmd` | Flow | FSS, IMI, RSME questionnaires |
| `analysis_behav_questionnaires_load.qmd` | Load | FSS, IMI, RSME questionnaires |
| `analysis_behav_oddball_flow.qmd` | Flow | RT, d-prime, errors |
| `analysis_behav_oddball_load.qmd` | Load | RT, d-prime, errors |
| `analysis_behav_counting_load.qmd` | Load | Passive counting accuracy |

---

## Configuration

- `config_flow.R` / `config_load.R` — condition labels, cluster definitions, included participants
- `utils.R` — shared helper functions (APA formatting, t-test wrappers)
- `utils_freq.R` — frequency analysis helpers (`filter_data_band`, `create_band_boxplot`)

**Date convention:** Each QMD has a hardcoded `DATE_SOURCE` variable (e.g. `"20261015"`) matching the date prefix of the input CSV files in `derivatives_v2/outputs/measures/`. If measures are regenerated, update this variable.