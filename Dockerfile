FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget \
    unzip \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    libpulse0 \
    libglu1-mesa \
    libgles2-mesa-dev \
    libgbm-dev \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libncurses6 \
    libstdc++6 \
    lib32z1 \
    tightvncserver \
    novnc \
    python3 \
    make \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_HOME=/app/sdk
ENV ANDROID_SDK_HOME=/app
ENV ANDROID_AVD_HOME=/app/.android/avd
ENV PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

# Working directory
WORKDIR /app

# The user should mount the current directory to /app
# CMD ["make", "run"]
