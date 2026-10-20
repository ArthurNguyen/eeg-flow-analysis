# EEG-Flow Analysis Pipeline

Analysis code for two companion papers studying how load and flow modulate auditory deviance detection in EEG, using a video game oddball paradigm (Unreal Tournament 2004).

**Papers:**
- *Name TBD* (Flow paper)
- *Name TBD* (Load paper)

**Preprocessing pipeline:** [mscheltienne/eeg-flow](https://github.com/mscheltienne/eeg-flow)  
**Data:** Available upon reasonable request (contact: daphne.bavelier@unige.ch)

---

## Overview

Two studies — Active (participants respond to oddballs) and Passive (no response required) — with quasi-identical EEG acquisition. Both papers share the same preprocessing pipeline and much of the analysis infrastructure, but differ in which participants and conditions are included.

All analysis outputs are written to `derivatives_v2/outputs/` on the NAS (measures, grand averages, stats, figures). Code paths point to `L:/EEG_Flow_data/` on Windows or `/Volumes/faculty/EEG_Flow_data/` on macOS.

---

## Prerequisites

**Python environment:**
```bash
conda env create -f environment.yml
conda activate eeg-flow
```

**R environment:** R 4.x with the following packages:
`rstatix`, `ggplot2`, `glue`, `dplyr`, `BayesFactor`, `knitr`, `quarto`

**Data access:** NAS mount required. All notebooks read from and write to absolute NAS paths — no data files are included in this repository.

---

## Repository structure

├── core/ # Shared configuration and utilities
│ ├── config_flow.py # Flow paper: conditions, participants, paths
│ ├── config_load.py # Load paper: conditions, participants, paths
│ ├── participants.py # Participant lists (Active/Passive, included/excluded)
│ └── utils.py # Shared utility functions (load_pkl, etc.)
│
├── behavior_prep/ # Behavioral data preparation (run once)
│ ├── AVG-score_preprocessing.ipynb # Action score from VG questionnaires
│ ├── participants_preprocessing.ipynb
│ ├── questionnaires_preprocessing.ipynb
│ └── oddball_response/
│ ├── aggregate_metadata.ipynb
│ └── compute_measures.ipynb
│
├── shared/ # Notebooks shared across both papers
│ ├── pipeline/ # Core EEG pipeline (run before measures)
│ │ ├── grand_average.ipynb
│ │ └── concatenate_epochs.ipynb
│ ├── measures/ # ERP and frequency measure extraction
│ │ ├── extract_measures.ipynb
│ │ ├── extract_measures_resp.ipynb
│ │ └── band_power_continuous.ipynb
│ ├── plots/ # Grand average waveform and topomap figures
│ │ ├── plots_waveform.ipynb
│ │ └── plots_topomap.ipynb
│ ├── behavior/ # Behavioral summary figures
│ │ ├── epochs_count.ipynb
│ │ ├── oddball_response.ipynb
│ │ ├── participants.ipynb
│ │ └── questionnaires.ipynb
│ └── exploration/ # Supplementary and exploratory analyses
│ ├── multiverse_analysis.ipynb # Supplementary — flow paper
│ ├── ERP-vs-AVGscore_correlations.ipynb
│ ├── source_load_simple.ipynb
│ ├── passive_cross_flicker_count_and_vg_status.ipynb
│ └── archive_cluster_permutation_exp2_mmn_with_crop.ipynb # Archived, do not rerun
│
├── flow_paper/ # Flow-paper-specific notebooks
│ ├── notebooks/
│ │ ├── band_power_castellar.ipynb
│ │ └── Correlation_Alpha_RT_with_plot.ipynb
│ └── plots/
│ └── plots_responselocked_CSD.ipynb
│
├── load_paper/ # Load-paper-specific notebooks
│ └── plots/
│ ├── plots_taskdiff_waveform.ipynb
│ └── plots_taskdiff_topomap.ipynb
│
├── stats/ # R/Quarto statistical analyses
│ ├── render_all.R # Render all analyses in one call
│ ├── analyses/ # One QMD file per analysis
│ │ ├── config_flow.R # Flow paper R config
│ │ ├── config_load.R # Load paper R config
│ │ ├── utils.R
│ │ ├── utils_freq.R
│ │ └── analysis_.qmd # 14 analysis files (ERP, freq, behav)
│ └── README.md # Stats-specific documentation
│
└── validation/ # Pipeline validation and data inventory
├── v1_vs_v2_grand_average_comparison.ipynb
├── data_size_report.ipynb
└── pipeline_check_.txt


---

## How to run

### 1. Behavioral preparation (once)
Run notebooks in `behavior_prep/` to generate action scores, questionnaire CSVs, and oddball response measures.

### 2. EEG pipeline
In `shared/pipeline/`:
1. `grand_average.ipynb` — compute grand averages per condition
2. `concatenate_epochs.ipynb` — concatenate runs for load paper

### 3. Measure extraction
In `shared/measures/`:
- `extract_measures.ipynb` — stim-locked ERP mean amplitudes
- `extract_measures_resp.ipynb` — response-locked ERP measures
- `band_power_continuous.ipynb` — continuous band power (flow/load)

For flow-paper-specific frequency measures: `flow_paper/notebooks/band_power_castellar.ipynb`

### 4. Figures
Run notebooks in `shared/plots/`, `flow_paper/plots/`, and `load_paper/plots/`.

### 5. Statistical analyses
```r
source("stats/render_all.R")
```
Or render individual QMD files from `stats/analyses/`. HTML outputs are saved to `derivatives_v2/outputs/stats/`.

---

## Notes

- **v2 pipeline:** This repository corresponds to `derivatives_v2` on the NAS, the canonical version used for submission. See `validation/v1_vs_v2_grand_average_comparison.ipynb` for validation against v1 (all correlations ≥ 0.985).
- **Paths:** All NAS paths are constructed from `get_study_root()` in `core/utils.py` and auto-detect Windows vs macOS.
- **Preprocessing code:** The upstream preprocessing pipeline (steps 1–8, ICA, epoching) lives at [ArthurNguyen/eeg-flow-preprocessing](https://github.com/ArthurNguyen/eeg-flow-preprocessing), tagged `v2-preprocessing-2026-10`.

---

## Citation

*To be updated.*

## Contact

Arthur Nguyen — arthur.nguyen@unige.ch
Daphne Bavelier — daphne.bavelier@unige.ch