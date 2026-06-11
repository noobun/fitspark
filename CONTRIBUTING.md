# FitSpark

A Garmin Connect IQ application source tree for the `FitSpark` experience.

## Overview

This repository contains the Connect IQ project assets, source code, resources, and generated build artifacts for the `FitSpark` watch app.

## Repository structure

- `source/` — Connect IQ source files (`.mc`) organized by feature and app pages.
- `resources/` — UI definitions, strings, layouts, and drawable assets.
- `bin/` — Generated build output, app packages, debug metadata, and build resources.
- `manifest.xml` — Connect IQ app metadata and module definitions.
- `monkey.jungle` — Build configuration file used by the Connect IQ packaging tool.

## Key directories

- `source/pages/` — app page controllers and views for overview, weight, water, macro, and trends.
- `source/managers/` — shared request and view manager logic.
- `source/glance/` — glance view components.
- `resources/strings/` — localized string resources.
- `resources/layouts/` — UI layout definitions.
- `resources/images/` — image assets used by the app.

## Requirements

- Garmin Connect IQ SDK installed -> https://developer.garmin.com/connect-iq/sdk/.
- A compatible Garmin device or emulator.
- A working SparkyFitness backend for runtime integration -> https://github.com/CodeWithCJ/SparkyFitness.
- HTTPS access to your SparkyFitness server from the watch.

## Development setup

1. Install the Garmin Connect IQ SDK and any required CLI tools.
2. Open the project with the Garmin Connect IQ IDE or an editor that supports Connect IQ development.
3. Confirm that `manifest.xml` and `monkey.jungle` match the target device and app metadata.
4. Create your own developer_key to be able to compile

## Building the app

> [!NOTE]
> I do recomend the VS Code Monkey C Extention that handles the key, build, debug.

1. Use the Connect IQ build tools to compile the project.
2. The packaged `.prg` file and build artifacts appear in the `bin/` directory.
3. If you need to rebuild, remove stale generated files from `bin/` before starting.

## Deploying and sideloading

- Deploy to a simulator or compatible Garmin device using the Connect IQ tools.
- For sideloading, copy the generated `.prg` file from `bin/` into the watch's `GARMIN/APPS` folder.
- After sideloading, configure the app settings from the watch itself.

## Contributing

- Open issues for bugs, feature requests, or compatibility reports.
- **For now i do not accept PRs**

## Notes

- Keep generated files under `bin/` out of source control if rebuilding frequently.
- Use `manifest.xml` and `monkey.jungle` to manage app metadata, permissions, and packaging.
- Link back to `README.md` for user-facing setup and compatibility information.
