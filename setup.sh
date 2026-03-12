#!/bin/bash

# Exit on error
set -e

echo "Starting Android Emulator Setup..."

# Function to install dependencies for different distros
install_dependencies() {
    if [ -f /etc/debian_version ]; then
        echo "Detected Debian/Ubuntu-based system."
        sudo apt update
        sudo apt install -y openjdk-17-jdk wget unzip qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libpulse0 libglu1-mesa libgles2-mesa-dev libgbm-dev libncurses6
    elif [ -f /etc/fedora-release ]; then
        echo "Detected Fedora-based system."
        sudo dnf install -y java-17-openjdk wget unzip qemu-kvm libvirt bridge-utils libpulse mesa-libGLU
    elif [ -f /etc/arch-release ]; then
        echo "Detected Arch-based system."
        sudo pacman -Sy --noconfirm jdk17-openjdk wget unzip qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libpulse libglvnd
    else
        echo "Unsupported distribution. Please install openjdk-17, wget, unzip, and KVM manually."
    fi
}

# Create local directories
mkdir -p sdk/cmdline-tools
mkdir -p .android

# Set up environment variables for the script
export ANDROID_HOME="$(pwd)/sdk"
export ANDROID_SDK_HOME="$(pwd)"
export ANDROID_AVD_HOME="$(pwd)/.android/avd"

# Download Command Line Tools if not already present
CMD_LINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
if [ ! -d "sdk/cmdline-tools/latest" ]; then
    echo "Downloading Android Command Line Tools..."
    wget -q --show-progress "$CMD_LINE_TOOLS_URL" -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    mv cmdline-tools sdk/cmdline-tools/latest
    rm cmdline-tools.zip
fi

# Use sdkmanager to install required packages
SDK_MANAGER="sdk/cmdline-tools/latest/bin/sdkmanager"

echo "Accepting licenses..."
yes | $SDK_MANAGER --sdk_root=$ANDROID_HOME --licenses

echo "Installing platform-tools, emulator, and system image..."
$SDK_MANAGER --sdk_root=$ANDROID_HOME "platform-tools" "emulator" "system-images;android-34;google_apis;x86_64"

echo "Setup complete!"
echo "You can now use the Makefile to create and run the emulator."
echo "Note: Ensure your user is in the 'kvm' and 'libvirt' groups for hardware acceleration."
