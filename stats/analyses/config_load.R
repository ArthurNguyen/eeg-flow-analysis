# =============================================================================
# config_load.R — Paper 2 (Load) configuration
# =============================================================================

# =============================================================================
# Participants
# =============================================================================

INCLUDED_ACTIVE <- c(
  "P01", "P02", "P03", "P04", "P05", "P06", "P07", "P08", "P10", "P11",
  "P12", "P13", "P14", "P15", "P16", "P17", "P18", "P21", "P22", "P23",
  "P24", "P25", "P26", "P27", "P28", "P29", "P30", "P31", "P32", "P33",
  "P53", "P55", "P56", "P58", "P59", "P60", "P61", "P62", "P63", "P64",
  "P65", "P66", "P67", "P69", "P70", "P72", "P73", "P74"
) # 48p

INCLUDED_ACTIVE_N35 <- c(
  "P02", "P04", "P05", "P07", "P08", "P10", "P12", "P13", "P14", "P15",
  "P16", "P18", "P22", "P23", "P26", "P27", "P30", "P31", "P32", "P33",
  "P53", "P55", "P58", "P59", "P60", "P61", "P62", "P63", "P65", "P66",
  "P67", "P69", "P72", "P73", "P74"
)

INCLUDED_PASSIVE <- c(
  "S01", "S02", "S03", "S04", "S05", "S07", "S08", "S09", "S11", "S13",
  "S14", "S15", "S16", "S17", "S18", "S20", "S21", "S22", "S23", "S24",
  "S25", "S26", "S27", "S29", "S30", "S31", "S33", "S34", "S35", "S36",
  "S37", "S41", "S42", "S43", "S45", "S46", "S47", "S49", "S50", "S52", 
  "S54", "S55", "S56", "S58", "S59", "S60"
) # 46p

# =============================================================================
# Condition mapping and colors
# =============================================================================

# Maps pkl/CSV condition keys → plot labels
CONDITION_MAP <- c(Simple = "Simple", Complex = "Complex")

# Order for plots and stats (first = reference in t-test)
CONDITION_LEVELS <- c("Simple", "Complex")

CONDITION_COLORS <- c(
  Complex = "#F39C12",
  Simple  = "#3498DB"
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
# Analysis conditions
# =============================================================================
# Each entry defines one statistical test.
# Fields: component, stim, window, cluster (key into CLUSTERS list)

CONDITIONS_ACTIVE_RAW <- list(
  list(component = "N1",           stim = "standard", window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",           stim = "target",   window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",           stim = "novel",    window = "90-150ms",  cluster = "central"),
  list(component = "N2",           stim = "target",   window = "180-230ms", cluster = "central"),
  list(component = "N2",           stim = "novel",    window = "150-220ms", cluster = "central"),
  list(component = "P3-early",     stim = "target",   window = "280-430ms", cluster = "parietal"),
  list(component = "P3-late",      stim = "target",   window = "500-799ms", cluster = "parietal"),
  list(component = "P3-early",     stim = "novel",    window = "180-270ms", cluster = "central"),
  list(component = "P3-late",      stim = "novel",    window = "300-400ms", cluster = "central")
)

CONDITIONS_ACTIVE_DIFF <- list(
  list(component = "MMN",   stim = "target-standard", window = "130-190ms", cluster = "frontal"),
  list(component = "N1-MMN",stim = "novel-standard",  window = "120-180ms", cluster = "centro_parietal")
)

CONDITIONS_PASSIVE_RAW <- list(
  list(component = "N1",       stim = "standard", window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",       stim = "deviant",  window = "90-130ms",  cluster = "frontal"),
  list(component = "N1",       stim = "novel",    window = "90-150ms",  cluster = "central"),
  list(component = "P3-early", stim = "deviant",  window = "180-260ms", cluster = "central"),
  list(component = "P3-early", stim = "novel",    window = "190-280ms", cluster = "central"),
  list(component = "P3-late",  stim = "novel",    window = "300-380ms", cluster = "central")
)

CONDITIONS_PASSIVE_DIFF <- list(
  list(component = "MMN",    stim = "deviant-standard", window = "130-190ms", cluster = "frontal"),
  list(component = "N1-MMN", stim = "novel-standard",   window = "120-180ms", cluster = "centro_parietal")
)
