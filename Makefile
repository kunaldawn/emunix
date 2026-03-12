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

.PHONY: help create-avd run clean list-images list-avds install-image

help:
	@echo "Available targets:"
	@echo "  make create-avd      - Create a new AVD (Default: $(AVD_NAME))"
	@echo "  make install-image   - Install the system image for $(ANDROID_VERSION)"
	@echo "  make run             - Launch the emulator"
	@echo "  make list-images     - List available system images"
	@echo "  make list-avds       - List created AVDs"
	@echo "  make clean           - Remove SDK and .android directories (DANGER)"
	@echo ""
	@echo "Docker Targets (Prefixed with docker-):"
	@echo "  make docker-build    - Build the environment image"
	@echo "  make docker-create-avd"
	@echo "  make docker-run"
	@echo "  make docker-install-image"
	@echo "  make docker-list-avds"

install-image:
	@echo "Installing $(SYSTEM_IMAGE)..."
	$(SDK_MANAGER) "$(SYSTEM_IMAGE)"

create-avd:
	@if [ ! -d "$(SDK_ROOT)/system-images/$(ANDROID_VERSION)" ]; then \
		echo "Error: System image for $(ANDROID_VERSION) not found."; \
		echo "Run 'make install-image' first."; \
		exit 1; \
	fi
	@echo "Creating AVD $(AVD_NAME) for $(ANDROID_VERSION)..."
	@echo "no" | $(AVD_MANAGER) create avd -n $(AVD_NAME) -k "$(SYSTEM_IMAGE)" --force
	@echo "$(AVD_NAME)" > .android/last_avd

run:
	@AVD_TO_RUN=$(AVD_NAME); \
	if [ "$$AVD_TO_RUN" = "test_emulator" ]; then \
		if [ -f .android/last_avd ]; then \
			AVD_TO_RUN=$$(cat .android/last_avd); \
		else \
			FIRST_AVD=$$( $(AVD_MANAGER) list avd | grep "Name:" | head -n 1 | awk '{print $$2}' ); \
			if [ -n "$$FIRST_AVD" ]; then \
				AVD_TO_RUN=$$FIRST_AVD; \
			fi; \
		fi; \
	fi; \
	echo "Starting emulator $$AVD_TO_RUN..."; \
	$(EMULATOR) -avd $$AVD_TO_RUN -no-snapshot-save -gpu host $(EMULATOR_FLAGS)

list-images:
	$(SDK_MANAGER) --list | grep "system-images"

list-avds:
	$(AVD_MANAGER) list avd

clean:
	@echo "Cleaning up..."
	@rm -rf $(SDK_ROOT) $(ANDROID_USER_HOME)

# Docker Configuration
DOCKER_IMAGE := android-emulator-local
DOCKER_RUN := docker run -it --rm \
	--device /dev/kvm \
	-v $(shell pwd):/app \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=$(DISPLAY) \
	-u $(shell id -u):$(shell id -g) \
	-e HOME=/app \
	$(DOCKER_IMAGE)

docker-build:
	docker build -t $(DOCKER_IMAGE) .

# Docker targets matching native commands
docker-install-image:
	$(DOCKER_RUN) make install-image ANDROID_VERSION=$(ANDROID_VERSION)

docker-create-avd:
	$(DOCKER_RUN) make create-avd ANDROID_VERSION=$(ANDROID_VERSION) AVD_NAME=$(AVD_NAME)

docker-run:
	$(DOCKER_RUN) make run AVD_NAME=$(AVD_NAME) EMULATOR_FLAGS="$(EMULATOR_FLAGS)"

docker-list-images:
	$(DOCKER_RUN) make list-images

docker-list-avds:
	$(DOCKER_RUN) make list-avds
