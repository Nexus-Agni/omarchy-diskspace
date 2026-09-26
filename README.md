# Omarchy Disk Space Widget

A native, interactive disk space monitor plugin for [Omarchy](https://github.com/basecamp/omarchy).

![Disk Space Widget](https://img.shields.io/badge/Omarchy-Plugin-blue?style=for-the-badge)

This plugin adds a `󰋊` icon to your Omarchy bar. It natively integrates with the shell, matching your active theme perfectly.

- **At a glance:** The bar icon changes color if any disk exceeds 70% (warning) or 85% (critical) usage.
- **Detailed Popup:** Click the icon to open a native floating panel showing every mounted disk, its mount point, filesystem type, and a visual usage bar.
- **Native Wayland:** Built natively on Quickshell and Wayland Layer-Shell. It won't tile, steal focus, or shift your windows.

## Installation

You can install this plugin directly from this Git repository using Omarchy's built-in plugin manager:

```bash
omarchy plugin add https://github.com/Nexus-Agni/omarchy-diskspace
```

This will automatically clone the plugin, validate it, and install it to `~/.config/omarchy/plugins/`.

## Configuration

After installing, add it to your bar layout. Open your `~/.config/omarchy/shell.json` and add the plugin ID `agnibha.diskspace` to your preferred section (for example, next to bluetooth in the right section):

```json
      "right": [
        { "id": "omarchy.tray" },
        { "id": "omarchy.agents" },
        { "id": "omarchy.bluetooth" },
        { "id": "agnibha.diskspace" },
        { "id": "omarchy.network" },
        // ...
      ]
```

Save the file and Omarchy will automatically hot-reload the bar and show the widget!

## Updates

To update to the latest version of the plugin, simply run:

```bash
omarchy plugin update agnibha.diskspace
```
