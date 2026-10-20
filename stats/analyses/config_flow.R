# =============================================================================
# config_flow.R — Paper 1 (Flow) configuration
# =============================================================================

# =============================================================================
# Participants
# =============================================================================

INCLUDED_ACTIVE <- c(
  "P02", "P04", "P05", "P07", "P08", "P10", "P12", "P13", "P14", "P15",
  "P16", "P18", "P22", "P23", "P26", "P27", "P30", "P31", "P32", "P33",
  "P53", "P55", "P58", "P59", "P60", "P61", "P62", "P63", "P65", "P66",
  "P67", "P69", "P72", "P73", "P74", "P75"
) #36p

INCLUDED_PASSIVE <- c(
  "S01", "S02", "S03", "S04", "S05", "S07", "S08", "S09", "S11", "S14",
  "S15", "S18", "S20", "S21", "S22", "S23", "S24", "S25", "S26", "S27",
  "S29", "S30", "S33", "S34", "S35", "S36", "S37", "S39", "S41", "S42",
  "S43", "S45", "S46", "S47", "S49", "S50", "S54", "S55", "S56", "S58",
  "S60"
) #41p

# =============================================================================
# Condition mapping and colors
# =============================================================================

CONDITION_MAP    <- c("High Flow" = "High Flow", "Low Flow" = "Low Flow")
CONDITION_LEVELS <- c("High Flow", "Low Flow")

CONDITION_COLORS <- c(
  "High Flow" = "#E74C3C",
  "Low Flow"  = "#2ECC71"
)

# =============================================================================
# Electrode clusters
# =============================================================================

CLUSTERS <- list(
  frontal         = c("F1", "Fz", "F2", "FC1", "FCz", "FC2"),
  central         = c("FC1", "FCz", "FC2", "C1", "Cz", "C2"),
  centro_parietal = c("C1", "Cz", "C2", "CP1", "CPz", "CP2"),
  parietal        = c("P1", "Pz", "P2", "POz")
)

# =============================================================================
# Analysis conditions — fill in your confirmed windows
# =============================================================================

CONDITIONS_ACTIVE_RAW <- list(
  list(component = "N1",       stim = "standard", window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",       stim = "target",   window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",       stim = "novel",    window = "90-150ms",  cluster = "frontal"),
  list(component = "N2",       stim = "target",   window = "180-250ms", cluster = "central"),
  list(component = "P3",       stim = "target",   window = "350-750ms", cluster = "parietal"),
  list(component = "Novelty P3",stim = "novel",    window = "180-270ms", cluster = "central")
)

CONDITIONS_ACTIVE_DIFF <- list(
  list(component = "N1",     stim = "target-standard", window = "90-120ms",  cluster = "frontal"),
  list(component = "MMN",    stim = "target-standard", window = "120-180ms", cluster = "frontal"),
  list(component = "P3a",     stim = "target-standard", window = "200-280ms", cluster = "central"),
  list(component = "N1-MMN",  stim = "novel-standard",  window = "120-180ms", cluster = "centro_parietal"),
  list(component = "Novelty P3", stim = "novel-standard",  window = "180-280ms", cluster = "central")
)

CONDITIONS_PASSIVE_RAW <- list(
  list(component = "N1",       stim = "standard", window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",       stim = "deviant",  window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",       stim = "novel",    window = "90-150ms",  cluster = "frontal"),
  list(component = "P3-like",       stim = "deviant",  window = "350-750ms",  cluster = "parietal"),
  list(component = "Novelty P3",   stim = "novel",    window = "180-280ms", cluster = "central")
)

CONDITIONS_PASSIVE_DIFF <- list(
  list(component = "MMN",    stim = "deviant-standard", window = "120-180ms", cluster = "frontal"),
  list(component = "P3a",    stim = "deviant-standard", window = "200-280ms", cluster = "central"),
  list(component = "N1-MMN", stim = "novel-standard",   window = "120-180ms", cluster = "centro_parietal"),
  list(component = "Novelty P3",   stim = "novel-standard",   window = "180-280ms", cluster = "central")
)
