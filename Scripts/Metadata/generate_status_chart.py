#!/usr/bin/env python3
"""
OpsForge Status Dashboard Chart Generator
-----------------------------------------
This script reads milestone progress data from Docs/status.json
and generates a grouped bar chart overlaying current progress
against roadmap targets (always 100%). The chart is saved as
Docs/OpsForge_Status_Dashboard_Overlay.png.

Author: Kevin Crosson (OpsForge)
"""

import json
import os
import matplotlib.pyplot as plt
import numpy as np

# ------------------------------------------------------------
# Step 1: Load milestone data from Docs/status.json
# ------------------------------------------------------------
status_file = os.path.join("Docs", "status.json")

with open(status_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# Expected format in status.json:
# [
#   {"module": "BuildMate", "short": 80, "mid": 40, "long": 20},
#   {"module": "DroneOps", "short": 60, "mid": 50, "long": 30},
#   ...
# ]

modules = [item["module"] for item in data]
short_progress = [item["short"] for item in data]
mid_progress = [item["mid"] for item in data]
long_progress = [item["long"] for item in data]

# Roadmap targets are always 100%
short_targets = [100] * len(modules)
mid_targets = [100] * len(modules)
long_targets = [100] * len(modules)

# ------------------------------------------------------------
# Step 2: Configure chart layout
# ------------------------------------------------------------
x = np.arange(len(modules))  # module positions
bar_width = 0.12             # width of each bar

fig, ax = plt.subplots(figsize=(12, 6))

# ------------------------------------------------------------
# Step 3: Plot grouped bars (progress vs targets)
# ------------------------------------------------------------
# Short-term bars
ax.bar(x - bar_width, short_progress, bar_width, label="Short-Term Progress", color="green")
ax.bar(x - bar_width, short_targets, bar_width, alpha=0.3, label="Short-Term Target", color="lightgreen")

# Mid-term bars
ax.bar(x, mid_progress, bar_width, label="Mid-Term Progress", color="blue")
ax.bar(x, mid_targets, bar_width, alpha=0.3, label="Mid-Term Target", color="lightblue")

# Long-term bars
ax.bar(x + bar_width, long_progress, bar_width, label="Long-Term Progress", color="orange")
ax.bar(x + bar_width, long_targets, bar_width, alpha=0.3, label="Long-Term Target", color="moccasin")

# ------------------------------------------------------------
# Step 4: Customize chart appearance
# ------------------------------------------------------------
ax.set_xlabel("OpsForge Modules", fontsize=12)
ax.set_ylabel("Completion (%)", fontsize=12)
ax.set_title("OpsForge Status Dashboard: Progress vs Roadmap Targets", fontsize=14, fontweight="bold")
ax.set_xticks(x)
ax.set_xticklabels(modules, rotation=30, ha="right")
ax.set_ylim(0, 120)  # allow space above 100% for clarity
ax.legend(loc="upper left", bbox_to_anchor=(1, 1))

plt.tight_layout()

# ------------------------------------------------------------
# Step 5: Save chart to Docs folder
# ------------------------------------------------------------
output_file = os.path.join("Docs", "OpsForge_Status_Dashboard_Overlay.png")
plt.savefig(output_file, dpi=300)

print(f"✅ Status Dashboard chart generated: {output_file}")

