"""Participant registries shared across all papers and paradigms.

This file contains no paper-specific logic — it is imported by
grand_average.py, plots_waveform.py, and any future analysis scripts.
"""

# ==============================================================================
# Master participant registry (uid → group)
# ==============================================================================

# fmt: off
ALL_PARTICIPANTS: dict[str, str] = {
    # Active participants #                                            49p total
    "P01": "G1", "P02": "G2", "P03": "G1", "P04": "G3", "P05": "G2", "P06": "G4",
    "P07": "G5", "P08": "G6", "P10": "G8", "P11": "G1", "P12": "G2", "P13": "G3",
    "P14": "G3", "P15": "G4", "P16": "G4", "P17": "G5", "P18": "G6", "P21": "G7", 
    "P22": "G7", "P23": "G7", "P24": "G8", "P25": "G1", "P26": "G2", "P27": "G8", 
    "P28": "G1", "P29": "G3", "P30": "G4", "P31": "G5", "P32": "G6", "P33": "G7",
    "P53": "G8", "P55": "G1", "P56": "G8", "P58": "G5", "P59": "G8", "P60": "G6", 
    "P61": "G4", "P62": "G3", "P63": "G5", "P64": "G3", "P65": "G1", "P66": "G5", 
    "P67": "G3", "P69": "G8", "P70": "G8", "P72": "G1", "P73": "G3", "P74": "G1", 
    "P75": "G1",

    # Passive participants #                                           48p total
    "S01": "G1", "S02": "G2", "S03": "G3", "S04": "G4", "S05": "G5", "S07": "G7",
    "S08": "G8", "S09": "G1", "S10": "G2", "S11": "G3", "S13": "G5", "S14": "G6",
    "S15": "G1", "S16": "G7", "S17": "G8", "S18": "G1", "S20": "G4", "S21": "G7",
    "S22": "G8", "S23": "G3", "S24": "G6", "S25": "G5", "S26": "G2", "S27": "G3",
    "S29": "G6", "S30": "G1", "S31": "G4", "S33": "G8", "S34": "G1", "S35": "G2",
    "S36": "G2", "S37": "G3", "S39": "G3", "S41": "G5", "S42": "G4", "S43": "G6",
    "S45": "G8", "S46": "G1", "S47": "G2", "S49": "G4", "S50": "G5", "S52": "G6",
    "S54": "G8", "S55": "G1", "S56": "G6", "S58": "G2", "S59": "G3", "S60": "G5",
}
# fmt: on

# ==============================================================================
# Inclusion registry (which participants are included per paper / paradigm)
# ==============================================================================

INCLUSION_REGISTRY: dict[str, dict[str, list[str]]] = {
    "flow": {
        "active": [                                                        # 36p
            "P02", "P04", "P05", "P07", "P08", "P10", "P12", "P13", "P14", "P15",
            "P16", "P18", "P22", "P23", "P26", "P27", "P30", "P31", "P32", "P33",
            "P53", "P55", "P58", "P59", "P60", "P61", "P62", "P63", "P65", "P66",
            "P67", "P69", "P72", "P73", "P74", "P75",
        ],
        "passive": [                                                       # 41p
            "S01", "S02", "S03", "S04", "S05", "S07", "S08", "S09", "S11", "S14",
            "S15", "S18", "S20", "S21", "S22", "S23", "S24", "S25", "S26", "S27",
            "S29", "S30", "S33", "S34", "S35", "S36", "S37", "S39", "S41", "S42",
            "S43", "S45", "S46", "S47", "S49", "S50", "S54", "S55", "S56", "S58",
            "S60",
        ],
    },
    "load": {
        "active": [                                                        # 48p
            "P01", "P02", "P03", "P04", "P05", "P06", "P07", "P08", "P10", "P11",
            "P12", "P13", "P14", "P15", "P16", "P17", "P18", "P21", "P22", "P23",
            "P24", "P25", "P26", "P27", "P28", "P29", "P30", "P31", "P32", "P33",
            "P53", "P55", "P56", "P58", "P59", "P60", "P61", "P62", "P63", "P64",
            "P65", "P66", "P67", "P69", "P70", "P72", "P73", "P74",
        ],
        "active-n35": [                                                    # 35p (pour Manon)
            "P02", "P04", "P05", "P07", "P08", "P10", "P12", "P13", "P14", "P15",
            "P16", "P18", "P22", "P23", "P26", "P27", "P30", "P31", "P32", "P33",
            "P53", "P55", "P58", "P59", "P60", "P61", "P62", "P63", "P65", "P66",
            "P67", "P69", "P72", "P73", "P74",
        ],
        "passive": [                                                       # 47p
            "S01", "S02", "S03", "S04", "S05", "S07", "S08", "S09", "S11", "S13",
            "S14", "S15", "S16", "S17", "S18", "S20", "S21", "S22", "S23", "S24",
            "S25", "S26", "S27", "S29", "S30", "S31", "S33", "S34", "S35", "S36",
            "S37", "S39", "S41", "S42", "S43", "S45", "S46", "S47", "S49", "S50",
            "S52", "S54", "S55", "S56", "S58", "S59", "S60",
        ],
    },
}


def get_participants(paper: str, paradigm: str) -> dict[str, str]:
    """Return {uid: gid} for the given paper and paradigm."""
    allowed = INCLUSION_REGISTRY[paper][paradigm]
    return {pid: ALL_PARTICIPANTS[pid] for pid in allowed if pid in ALL_PARTICIPANTS}
