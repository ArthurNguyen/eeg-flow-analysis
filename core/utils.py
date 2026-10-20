"""Shared utility functions for EEG Flow / Load analyses.

Contains only pure helpers with no dependency on PAPER, PARADIGM,
or any global config. Import freely from any analysis script.
"""

from __future__ import annotations

import pickle
from pathlib import Path

from mne_lsl.utils.logs import warn


# ==============================================================================
# Filename / title helpers
# ==============================================================================

def tuple_to_string_fname(windows: tuple) -> str:
    """Convert time windows to a filename-safe string.

    Examples
    --------
    >>> tuple_to_string_fname(((90, 150),))
    '90-150'
    >>> tuple_to_string_fname(((90, 130), (200, 350)))
    '90-130_200-350'
    """
    if not windows:
        return "nowindow"
    if isinstance(windows[0], (int, float)):
        windows = (windows,)
    return "_".join(f"{start}-{end}" for start, end in windows)


def tuple_to_string_title(windows: tuple) -> str:
    """Convert time windows to a human-readable title string.

    Examples
    --------
    >>> tuple_to_string_title(((90, 150),))
    '90-150ms'
    >>> tuple_to_string_title(((90, 130), (200, 350)))
    '90-130ms, 200-350ms'
    """
    if not windows:
        return ""
    if isinstance(windows[0], (int, float)):
        windows = (windows,)
    return ", ".join(f"{start}-{end}ms" for start, end in windows)


# ==============================================================================
# Cluster label lookup
# ==============================================================================

KNOWN_CLUSTERS: dict[tuple, str] = {
    ("F1",  "Fz",  "F2",  "FC1", "FCz", "FC2"):              "frontal",
    ("FC1", "FCz", "FC2", "C1",  "Cz",  "C2"):               "central",
    ("C1",  "Cz",  "C2",  "CP1", "CPz", "CP2"):              "centro-parietal",
    ("P1",  "Pz",  "P2",  "POz"):                            "parietal",        
    
}


def get_cluster_label(cluster: list[str]) -> str:
    """Return a human-readable label for a known electrode cluster.

    Falls back to 'custom' if the cluster is not in KNOWN_CLUSTERS.
    """
    return KNOWN_CLUSTERS.get(tuple(cluster), "custom").capitalize()


# ==============================================================================
# I/O helpers
# ==============================================================================

def save_pkl(obj: dict, path: Path, label: str) -> None:
    """Serialize obj to a pickle file, creating parent directories as needed."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "wb") as fh:
        pickle.dump(obj, fh)
    print(f"Saved {label} → {path.name}")


def load_pkl(path: Path) -> dict:
    """Load and return a pickle file, with a clear error if missing."""
    if not path.exists():
        raise FileNotFoundError(f"Expected pickle file not found: {path}")
    with open(path, "rb") as fh:
        return pickle.load(fh)

# ==============================================================================
# Topomap helpers
# ==============================================================================

def window_average_evoked(evoked, tmin_ms: float, tmax_ms: float):
    """Average evoked data within a time window, return as EvokedArray."""
    import mne
    import numpy as np

    t_ms = evoked.times * 1000.0
    mask = (t_ms >= tmin_ms) & (t_ms <= tmax_ms)
    if not np.any(mask):
        raise ValueError(f"No samples inside {tmin_ms}-{tmax_ms} ms")
    data_mean = evoked.data[:, mask].mean(axis=1, keepdims=True)
    center_s  = (tmin_ms + tmax_ms) / 2000.0
    return mne.EvokedArray(
        data_mean, evoked.info.copy(),
        tmin=center_s, nave=evoked.nave,
        comment=f"{tmin_ms}-{tmax_ms} ms",
    )


def get_topomap_image(evoked):
    """Render a topomap invisibly and return the image object for colour scaling."""
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots()
    evoked.plot_topomap(times=evoked.times, axes=ax, show=False, colorbar=False)
    img = ax.images[0]
    plt.close(fig)
    return img


# ==============================================================================
# Retrieve the date of the latest relevant pkl
# ==============================================================================

def show_latest_pkls(
    root: Path,
    paper: str,
    paradigm: str,
    lock: str,
    measure: str,
    baseline: str = "",
    cohort: str | None = None,
    subfolder: str | None = None,
    n: int = 3,
) -> str | None:
    import re

    # Build input_path
    if subfolder:
        folder = subfolder
    elif measure == "diff":
        folder = "diff"
    else:
        folder = "raw"
    
    if cohort:
        input_path = root / "outputs" / "grand_averages" / paper / "_other_cohorts" / cohort / folder
    else:
        input_path = root / "outputs" /  "grand_averages" / paper / folder

    if not input_path.exists():
        print(f"Path not found: {input_path}")
        return None

    if lock == "resp":
        pattern = f"*_{paradigm}_*_resp_{baseline}_*.pkl"
    elif measure == "diff":
        pattern = f"*_{paradigm}_*_stim_diff.pkl"
    else:
        pattern = f"*_{paradigm}_*_stim_raw.pkl"

    files = sorted(
        input_path.glob(pattern),
        key=lambda f: f.stat().st_mtime,
        reverse=True,
    )

    if not files:
        print(f"No matching files in {input_path} for: {pattern}")
        return None

    print(f"\nLatest matching files in {input_path.name}/:")
    for f in files[:n]:
        date_match = re.match(r"(\d{8})_", f.name)
        date = date_match.group(1) if date_match else "unknown"
        print(f"  [{date}] {f.name}")

    date_match = re.match(r"(\d{8})_", files[0].name)
    if date_match:
        latest = date_match.group(1)
        print(f"\n→ Most recent: {latest}")
        return latest
    return None