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
| `make install-image` | Install system image for `ANDROID_VERSION` |
| `make create-avd` | Create AVD using specific system image |
| `make run` | Launch the emulator |
| `make list-avds` | List created virtual devices |
| `make list-images` | List available system images |
| `make clean` | Remove all SDK and AVD data |

## Examples

### Basic Setup (Android 14)
The default setup uses Android 14 (API 34).
```bash
./setup.sh        # Install dependencies and SDK
make create-avd   # Create 'test_emulator'
make run          # Start the emulator
```

### Setup a Specific Version (e.g., Android 11)
You can specify the version at any step.
```bash
# 1. Install the system image
make install-image ANDROID_VERSION=android-30

# 2. Create the AVD
make create-avd ANDROID_VERSION=android-30 AVD_NAME=android_11_tablet

# 3. Run it
make run AVD_NAME=android_11_tablet
```

### Managing Multiple Emulators
```bash
# List what you have installed
make list-avds

# List what images you can install
make list-images

# Run the first one found (auto-discovery)
make run

# Run a specific one
make run AVD_NAME=pixel_6
```

### Cleaning Up
To delete everything and start fresh:
```bash
make clean
```

## Troubleshooting

### KVM / Acceleration Issues
If the emulator is slow, ensure KVM is enabled:
```bash
lsmod | grep kvm
```
If you get a "Permission Denied" error for `/dev/kvm`, add your user to the `kvm` group and **re-log**:
```bash
sudo usermod -aG kvm $USER
```

### Graphics Issues
If the emulator fails to start due to graphics drivers, you can try software rendering:
```bash
# Edit Makefile or run manually:
./sdk/emulator/emulator -avd [name] -gpu swiftshader_indirect
```

## Directory Structure

- `sdk/`: Android SDK, platform-tools, and emulator binaries.
- `.android/`: Local home directory for AVD configurations and data.
- `setup.sh`: Installation script.
- `Makefile`: Management interface.
