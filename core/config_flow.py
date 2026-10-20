"""Paper-specific configuration for the Flow paper (Paper 1).

Imported by grand_average.ipynb, plots_waveform.ipynb, plots_topomap.ipynb, etc.
Do NOT import grand_average internals here — config only.
"""

# ==============================================================================
# Plot styles
# ==============================================================================

STYLES: dict[str, dict] = {
    "High Flow": {"linestyle": "solid",  "color": "#E74C3C", "linewidth": 2},
    "Low Flow":  {"linestyle": "dashed", "color": "#2ECC71", "linewidth": 2},
}

DEFAULT_YLIM_ACTIVE  = dict(eeg=[-8, 6])
DEFAULT_YLIM_PASSIVE = dict(eeg=[-6, 6])
# ==============================================================================
# Condition mapping  (plot label -> pkl key prefix)
# ==============================================================================

CONDITIONS: dict[str, str] = {
    "High Flow": "highflow",
    "Low Flow":  "lowflow",
}

# ==============================================================================
# Task label mapping  (for filenames)
# ==============================================================================

TASK_LABELS: dict[str, str] = {
    "oddball": "simple",
    "UT":      "complex",
}

# ==============================================================================
# Batch waveform plot configurations
# ==============================================================================

BATCH: dict[tuple, list[dict]] = {

    ("active", "raw"): [
        dict(stim="standard", component="N1",        cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,130),),  ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="target",   component="N1",        cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,130),), ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="novel",    component="N1",        cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,150),),  ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="target",   component="N2",        cluster=["FC1","FCz","FC2","C1","Cz","C2"],   windows=((180,250),), ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="target",   component="P3",        cluster=["P1","Pz","P2","POz"],               windows=((350,750),), ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="novel",    component="Novelty-P3", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((180,270),), ylim=DEFAULT_YLIM_ACTIVE),
    ],

    ("active", "diff"): [
        dict(stim="target-standard", component="N1-MMN",    cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,120),(120,180)),  ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="target-standard", component="P3a",       cluster=["FC1","FCz","FC2","C1","Cz","C2"],   windows=((200,280),), ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="novel-standard",  component="N1-MMN",    cluster=["C1","Cz","C2","CP1","CPz","CP2"],   windows=((120,180),), ylim=DEFAULT_YLIM_ACTIVE),
        dict(stim="novel-standard",  component="Novelty-P3", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((180,280),), ylim=DEFAULT_YLIM_ACTIVE),
    ],

    ("passive", "raw"): [
        dict(stim="standard", component="N1",          cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,130),),  ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="deviant",  component="N1",          cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,130),),  ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="novel",    component="N1",          cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,150),),  ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="deviant",  component="Deviant-P3",  cluster=["P1","Pz","P2","POz"],               windows=((350,750),), ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="novel",    component="Novelty-P3",  cluster=["FC1","FCz","FC2","C1","Cz","C2"],   windows=((180,280),), ylim=DEFAULT_YLIM_PASSIVE),
    ],

    ("passive", "diff"): [
        dict(stim="deviant-standard", component="N1-MMN",       cluster=["F1","Fz","F2","FC1","FCz","FC2"],   windows=((90,120),(120,180),), ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="deviant-standard", component="P3a",       cluster=["FC1","FCz","FC2","C1","Cz","C2"],   windows=((200,280),), ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="novel-standard",   component="N1-MMN",    cluster=["C1","Cz","C2","CP1","CPz","CP2"],   windows=((120,180),), ylim=DEFAULT_YLIM_PASSIVE),
        dict(stim="novel-standard",   component="Novelty-P3", cluster=["FC1","FCz","FC2","C1","Cz","C2"], windows=((180,280),), ylim=DEFAULT_YLIM_PASSIVE),
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
        dict(plot_windows=[("target", 180, 250)],   fname_suffix="target_N2"),
        dict(plot_windows=[("target", 350, 750)],   fname_suffix="target_P3"),
        dict(plot_windows=[("novel",  180, 270)],   fname_suffix="novel_P3"),
    ],
    ("active", "diff"): [
        dict(plot_windows=[("target-standard", 90,  120)], fname_suffix="target-standard_N1"),
        dict(plot_windows=[("target-standard", 120, 180)], fname_suffix="target-standard_MMN"),
        dict(plot_windows=[("target-standard", 200, 280)], fname_suffix="target-standard_P3a"),
        dict(plot_windows=[("novel-standard",  120, 180)], fname_suffix="novel-standard_N1MMN"),
        dict(plot_windows=[("novel-standard",  180, 280)], fname_suffix="novel-standard_P3"),
    ],
    ("passive", "raw"): [
        dict(plot_windows=[("standard", 90, 130),
                           ("deviant",  90, 130),
                           ("novel",    90, 150)],  fname_suffix="N1s"),
        dict(plot_windows=[("deviant", 350, 750)],  fname_suffix="deviant_P3"),
        dict(plot_windows=[("novel",   180, 280)],  fname_suffix="novel_P3"),
    ],
    ("passive", "diff"): [
        dict(plot_windows=[("deviant-standard", 120, 180)], fname_suffix="deviant-standard_MMN"),
        dict(plot_windows=[("deviant-standard", 200, 280)], fname_suffix="deviant-standard_P3a"),
        dict(plot_windows=[("novel-standard",   120, 180)], fname_suffix="novel-standard_N1MMN"),
        dict(plot_windows=[("novel-standard",   180, 280)], fname_suffix="novel-standard_P3"),
    ],
}

# ==============================================================================
# Topomap time windows (used by extract_measures.ipynb)
# ==============================================================================

WINDOWS: dict[tuple, list[tuple]] = {
    ("active",  "stim", "raw"):  [(90, 130), (90, 150), (180, 250), (180, 270), (350, 750)],
    ("active",  "stim", "diff"): [(90, 120), (120, 180), (180, 280), (200, 280)],
    ("passive", "stim", "raw"):  [(90, 130), (90, 150), (120, 180), (180, 280), (350, 750)],
    ("passive", "stim", "diff"): [(120, 180), (180, 280), (200, 280)],
}
