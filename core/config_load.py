"""Paper-specific configuration for the Load paper (Paper 2).

Imported by grand_average.ipynb, plots_waveform.ipynb, plots_topomap.ipynb, etc.
Do NOT import grand_average internals here — config only.
"""

# ==============================================================================
# Plot styles
# ==============================================================================

STYLES: dict[str, dict] = {
    "Simple":  {"linestyle": "dashed", "color": "#3498DB", "linewidth": 2},
    "Complex": {"linestyle": "solid",  "color": "#F39C12", "linewidth": 2},
}

STYLES_TASKDIFF: dict[str, dict] = {
    "Simple\u2212Complex": {"linestyle": "solid", "color": "#8E44AD", "linewidth": 2},
}

DEFAULT_YLIM = dict(eeg=[-6, 8])

# ==============================================================================
# Condition mapping  (plot label -> pkl key prefix)
# ==============================================================================

CONDITIONS: dict[str, str] = {
    "Simple":  "simple",
    "Complex": "complex",
}

# ==============================================================================
# Task label mapping  (for filenames)
# ==============================================================================

TASK_LABELS: dict[str, str] = {
    "UT":      "complex",
    "oddball": "simple",
}

# ==============================================================================
# Batch waveform plot configurations
# ==============================================================================

BATCH: dict[tuple, list[dict]] = {

    ("active", "raw"): [
        dict(stim="standard", component="N1", cluster=["F1","Fz","F2","FC1","FCz","FC2"], windows=((90,130),),           ylim=DEFAULT_YLIM),
        dict(stim="target",   component="N1", cluster=["F1","Fz","F2","FC1","FCz","FC2"], windows=((90,130),),           ylim=DEFAULT_YLIM),
        dict(stim="novel",    component="N1", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((90,150),),           ylim=DEFAULT_YLIM),
        dict(stim="target",   component="N2", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((180,230),),          ylim=DEFAULT_YLIM),
        dict(stim="novel",    component="N2", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((150,220),),          ylim=DEFAULT_YLIM),
        dict(stim="target",   component="P3-early_late", cluster=["P1","Pz","P2","POz"],             windows=((280,430),(500,800),), ylim=DEFAULT_YLIM),
        dict(stim="novel",    component="P3-early_late", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((180,270),(300,400),), ylim=DEFAULT_YLIM),
    ],

    ("active", "diff"): [
        dict(stim="target-standard", component="MMN",   cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((130,190),), ylim=DEFAULT_YLIM),
        dict(stim="novel-standard",  component="N1-MMN", cluster=["C1","Cz","C2","CP1","CPz","CP2"],  windows=((120,180),), ylim=DEFAULT_YLIM),
    ],

    ("active", "resp"): [
        dict(stim="response", component="response", cluster=["P1","Pz","P2","POz"], windows=((-100,100),), ylim=DEFAULT_YLIM),
    ],

    ("passive", "raw"): [
        dict(stim="standard", component="N1",           cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,130),),           ylim=DEFAULT_YLIM),
        dict(stim="deviant",  component="N1",           cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,130),),           ylim=DEFAULT_YLIM),
        dict(stim="novel",    component="N1",           cluster=["FC1","FCz","FC2","C1","Cz","C2"],   windows=((90,150),),           ylim=DEFAULT_YLIM),
        dict(stim="deviant",  component="P3-early",     cluster=["FC1","FCz","FC2","C1","Cz","C2"],   windows=((180,260),),          ylim=DEFAULT_YLIM),
        dict(stim="novel",    component="P3-early_late", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((190,280),(300,380),), ylim=DEFAULT_YLIM),
    ],

    ("passive", "diff"): [
        dict(stim="deviant-standard", component="MMN",   cluster=["F1","Fz","F2","FC1","FCz","FC2"],  windows=((130,190),), ylim=DEFAULT_YLIM),
        dict(stim="novel-standard",   component="N1-MMN", cluster=["C1","Cz","C2","CP1","CPz","CP2"], windows=((120,180),), ylim=DEFAULT_YLIM),
    ],
}

# Task difference (Simple - Complex): load paper, active only
BATCH_TASKDIFF: dict[tuple, list[dict]] = {
    ("active", "stim"): [
        dict(stim="target", component="N2", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((180,230),), ylim=DEFAULT_YLIM),
        dict(stim="novel",  component="N2", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((150,220),), ylim=DEFAULT_YLIM),
    ],
}

# ==============================================================================
# Batch topomap plot configurations
# ==============================================================================

BATCH_TOPO: dict[tuple, list[dict]] = {
    ("active", "raw"): [
        dict(plot_windows=[("standard", 90, 130),
                           ("target",   90, 130),
                           ("novel",    90, 150)],  fname_suffix="N1s"),
        dict(plot_windows=[("target", 180, 230)],   fname_suffix="target_N2"),
        dict(plot_windows=[("novel",  150, 220)],   fname_suffix="novel_N2"),
        dict(plot_windows=[("target", 280, 430),
                           ("target", 500, 800)],   fname_suffix="target_P3s"),
        dict(plot_windows=[("novel", 180, 270),
                           ("novel", 300, 400)],    fname_suffix="novel_P3s"),
    ],
    ("active", "diff"): [
        dict(plot_windows=[("target-standard", 130, 190)], fname_suffix="target-standard_MMNdiff"),
        dict(plot_windows=[("novel-standard",  120, 180)], fname_suffix="novel-standard_MMNdiff"),
    ],
    ("passive", "raw"): [
        dict(plot_windows=[("standard", 90, 130),
                           ("deviant",  90, 130),
                           ("novel",    90, 150)],  fname_suffix="N1s"),
        dict(plot_windows=[("deviant", 180, 260)],  fname_suffix="deviant_P3early"),
        dict(plot_windows=[("novel", 190, 280),
                           ("novel", 300, 380)],    fname_suffix="novel_P3s"),
    ],
    ("passive", "diff"): [
        dict(plot_windows=[("deviant-standard", 130, 190)], fname_suffix="deviant-standard_MMNdiff"),
        dict(plot_windows=[("novel-standard",   120, 180)], fname_suffix="novel-standard_MMNdiff"),
    ],
}

BATCH_TOPO_RESP: dict[tuple, list[dict]] = {
    ("active", "raw"): [
        dict(plot_windows=[("response", -100, 100)], fname_suffix="response"),
    ],
}

# Task difference topomaps: load paper, active only
BATCH_TOPO_TASKDIFF: dict[tuple, list[dict]] = {
    ("active", "raw"): [
        dict(plot_windows=[("target", 180, 230)], fname_suffix="target_N2"),
        dict(plot_windows=[("novel",  150, 220)], fname_suffix="novel_N2"),
    ],
}

# ==============================================================================
# Topomap time windows (used by plots_topomap.ipynb)
# ==============================================================================

WINDOWS: dict[tuple, list[tuple]] = {
    ("active",  "stim", "raw"):  [(90, 130), (90, 150), (150, 220), (180, 230), (280, 430), (500, 799), (180, 270), (300, 400)],
    ("active",  "stim", "diff"): [(130, 190), (120, 180)],
    ("passive", "stim", "raw"):  [(90, 130), (90, 150), (180, 260), (190, 280), (300, 380)],
    ("passive", "stim", "diff"): [(130, 190), (120, 180)],
}
