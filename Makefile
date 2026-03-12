# Android Emulator Makefile

# Directories
SDK_ROOT := $(shell pwd)/sdk
ANDROID_USER_HOME := $(shell pwd)/.android

# Tools
SDK_MANAGER := $(SDK_ROOT)/cmdline-tools/latest/bin/sdkmanager
AVD_MANAGER := $(SDK_ROOT)/cmdline-tools/latest/bin/avdmanager
EMULATOR := $(SDK_ROOT)/emulator/emulator
ADB := $(SDK_ROOT)/platform-tools/adb

# Configuration
AVD_NAME ?= test_emulator
ANDROID_VERSION ?= android-34
SYSTEM_IMAGE ?= system-images;$(ANDROID_VERSION);google_apis;x86_64

# Env
export ANDROID_HOME := $(SDK_ROOT)
export ANDROID_SDK_HOME := $(shell pwd)
export ANDROID_AVD_HOME := $(shell pwd)/.android/avd

.PHONY: help create-avd run clean list-images list-avds

help:
	@echo "Available targets:"
	@echo "  make create-avd      - Create a new AVD (Default: $(AVD_NAME))"
	@echo "  make run             - Launch the emulator"
	@echo "  make list-images     - List available system images"
	@echo "  make list-avds       - List created AVDs"
	@echo "  make clean           - Remove SDK and .android directories (DANGER)"

create-avd:
	@echo "Creating AVD $(AVD_NAME) for $(ANDROID_VERSION)..."
	@echo "no" | $(AVD_MANAGER) create avd -n $(AVD_NAME) -k "$(SYSTEM_IMAGE)" --force

run:
	@echo "Starting emulator $(AVD_NAME)..."
	@$(EMULATOR) -avd $(AVD_NAME) -no-snapshot-save -gpu host

list-images:
	$(SDK_MANAGER) --list | grep "system-images"

list-avds:
	$(AVD_MANAGER) list avd

clean:
	@echo "Cleaning up..."
	@rm -rf $(SDK_ROOT) $(ANDROID_USER_HOME)
