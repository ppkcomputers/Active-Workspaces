# Active-Workspaces  


# Hyprland Workspace Overview OSD

A full-screen, responsive, and animated workspace switcher OSD built for Hyprland using **Quickshell** (v0.55+ / Lua config generation era). 

This OSD lists all your active workspaces in a left-justified horizontal flow, reads and prints the application classes (`appId`/`title`) currently running inside them, features a pulsing Catppuccin-themed outline, and supports smooth animation toggles via an IPC Unix socket hook.

## Features
* **Full-Screen Canvas:** Blurs/dims the backdrop while maintaining a centered dashboard.
* **Dynamic Window Tracking:** Uses native `modelData.toplevels` mappings to see what apps are open on which workspace at a glance.
* **Interactive Navigation:** Left-clicking a workspace card triggers a slide-out animation and then immediately activates that workspace.
* **Zero-Dependency Toggle:** Uses native Quickshell `LocalServerSocket` to communicate exit animations between your hotkey script and the running QML engine—no stale flag files required.

---

## Installation & Setup

### 1. File Structure
Place the files inside your `.config` directory like this:
```text
~/.config/quickshell/ActiveWorkspaces/
├── shell.qml
└── toggle_overview.sh
