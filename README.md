# Portable Android Emulator Setup

A collection of scripts to set up and manage a portable, isolated Android Emulator environment on Linux.

## Overview

This project provides a fully self-contained Android SDK and emulator environment within the current directory. It handles system dependencies, SDK downloads, and AVD management without polluting global system paths.

## Prerequisites

- **OS**: Linux (64-bit)
- **Hardware**: CPU with virtualization support (Intel VT-x or AMD-V)
- **Docker**: (Optional) For containerized execution
- **Permissions**: `sudo` access for initial dependency installation or Docker group membership

### KVM Setup
Ensure your user has access to `/dev/kvm`:
```bash
sudo usermod -aG kvm $USER
```
*Note: Restart your session after running this command.*

## Usage Examples

This project supports two primary workflows: **Native** (running directly on your host) and **Docker** (running in an isolated container). Both share the same logic and configuration.

### 1. Initial Setup
| Action | Native (Host) | Docker (Container) |
|--------|---------------|--------------------|
| Install Deps | `./setup.sh` | `make docker-build` |
| Install Image | `make install-image` | `make docker-install-image` |

### 2. Creating AVDs
| Action | Native (Host) | Docker (Container) |
|--------|---------------|--------------------|
| Default (API 34) | `make create-avd` | `make docker-create-avd` |
| Custom (e.g. Pixel 6) | `make create-avd AVD_NAME=pixel_6` | `make docker-create-avd AVD_NAME=pixel_6` |

### 3. Launching the Emulator
| Action | Native (Host) | Docker (Container) |
|--------|---------------|--------------------|
| Start Default | `make run` | `make docker-run` |
| Start Specific | `make run AVD_NAME=pixel_6` | `make docker-run AVD_NAME=pixel_6` |

> [!TIP]
> **Architecture Support**: By default, the system uses `x86_64`. You can specify `arm64-v8a` for ARM64 images using the `ABI` variable (e.g., `make create-avd ABI=arm64-v8a`). Note that running ARM64 images on x86_64 hardware works via software emulation but is slower.

> [!NOTE]  
> **Auto-Discovery**: If `AVD_NAME` is not provided, the system will automatically launch the most recently created AVD or fall back to the first one found.

## Practical Scenarios

### Scenario A: Working with Multiple Android Versions
If you need to test your app on both Android 11 (API 30) and Android 14 (API 34):

**1. Install images and create AVDs:**
```bash
# Host
make install-image ANDROID_VERSION=android-30
make create-avd ANDROID_VERSION=android-30 AVD_NAME=legacy_phone

# ARM64 Image on x86_64 Host
make install-image ANDROID_VERSION=android-33 ABI=arm64-v8a
make create-avd ANDROID_VERSION=android-33 ABI=arm64-v8a AVD_NAME=arm_phone

# Docker (Container)
make docker-install-image ANDROID_VERSION=android-30
make docker-create-avd ANDROID_VERSION=android-30 AVD_NAME=legacy_phone

make docker-install-image ANDROID_VERSION=android-34
make docker-create-avd ANDROID_VERSION=android-34 AVD_NAME=latest_phone
```

**2. Run a specific version:**
```bash
# Host
make run AVD_NAME=legacy_phone

# Docker
make docker-run AVD_NAME=latest_phone
```

### Scenario B: Simultaneous Execution
To run two emulators at the same time, you must assign different ADB ports to avoid conflicts:
```bash
# Emulator 1 (Default port 5554/5555)
make run AVD_NAME=emulator_1

# Emulator 2 (Next available ports, e.g., 5556/5557)
make run AVD_NAME=emulator_2 EMULATOR_FLAGS="-port 5556"
```
*(Same logic applies to `make docker-run`)*


## Management Tools
Common commands for both workflows:
- `make list-avds` / `make docker-list-avds`: Show virtual devices.
- `make list-images` / `make docker-list-images`: Show available system images.
- `make clean`: Delete all SDK and AVD data from the host directory.

> [!TIP]
> **Docker GUI**: To see the emulator window when running in Docker, you may need to run `xhost +local:docker` on your host once per session.

## Troubleshooting
### KVM & Permissions
Ensure KVM is accessible and your user has the right permissions:
```bash
lsmod | grep kvm
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
# IMPORTANT: Log out and back in for changes to take effect
```

### Graphics Latency
If the emulator is unstable, try software rendering:
```bash
make run EMULATOR_FLAGS="-gpu swiftshader_indirect"
```
*(Note: You can add `EMULATOR_FLAGS` to any run command above)*

## Directory Structure

- `sdk/`: Android SDK, platform-tools, and emulator binaries.
- `.android/`: Local home directory for AVD configurations and data.
- `setup.sh`: Installation script.
- `Makefile`: Management interface.
