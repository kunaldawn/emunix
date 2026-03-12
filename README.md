# Portable Android Emulator Setup

A collection of scripts to set up and manage a portable, isolated Android Emulator environment on Linux.

## Overview

This project provides a fully self-contained Android SDK and emulator environment within the current directory. It handles system dependencies, SDK downloads, and AVD management without polluting global system paths.

## Prerequisites

- **OS**: Linux (64-bit)
- **Hardware**: CPU with virtualization support (Intel VT-x or AMD-V)
- **Permissions**: `sudo` access for initial dependency installation

### KVM Setup
Ensure your user has access to `/dev/kvm`:
```bash
sudo usermod -aG kvm $USER
```
*Note: Restart your session after running this command.*

## Get Started

### 1. Installation
Run the setup script to install system libraries and download the Android SDK:
```bash
./setup.sh
```
The script supports `apt` (Ubuntu/Debian), `dnf` (Fedora), and `pacman` (Arch).

### 2. Create Emulator (AVD)
Create a new Android Virtual Device:
```bash
make create-avd
```

### 3. Launch Emulator
```bash
make run
```

## Management

| Command | Description |
|---------|-------------|
| `make create-avd` | Create default AVD (API 34) |
| `make run` | Launch the emulator |
| `make list-avds` | List created virtual devices |
| `make list-images` | List available system images |
| `make clean` | Remove all SDK and AVD data |

## Configuration

You can override default settings via environment variables or Makefile arguments:

```bash
# Example: Create an Android 13 emulator
make create-avd ANDROID_VERSION=android-33 AVD_NAME=pixel_6
```

## Directory Structure

- `sdk/`: Android SDK, platform-tools, and emulator binaries.
- `.android/`: Local home directory for AVD configurations and data.
- `setup.sh`: Installation script.
- `Makefile`: Management interface.
