PROJECT_NAME := ggweb
GO := go
BUILD_TAGS :=
BUILD_DIR := bin
BINARY_NAME := $(BUILD_DIR)/$(PROJECT_NAME)
SRC_DIR := .
COVERAGE_FILE := coverage.out

build: clean build-linux
build-linux: BUILD_OS := linux
build-windows: BUILD_OS := windows
build-linux build-windows: build-common

build-common:
	@echo "Building $(PROJECT_NAME) for $(BUILD_OS)..."
	@$(GO) mod tidy
	@mkdir -p $(BUILD_DIR)/
	@GOOS=$(BUILD_OS) GOARCH=amd64 $(GO) build -tags="$(BUILD_TAGS)" -o $(BINARY_NAME)$(if $(filter windows,$(BUILD_OS)),.exe) $(SRC_DIR)
	@cp -r www $(BUILD_DIR)/

test:
	@echo "Running tests..."
	@$(GO) test -v ./...

coverage:
	@echo "Running tests with coverage..."
	@$(GO) test -v -coverprofile=$(COVERAGE_FILE) ./...
	@$(GO) tool cover -html=$(COVERAGE_FILE)

clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR) $(COVERAGE_FILE)

fmt:
	@echo "Formatting code..."
	@$(GO) fmt ./...

vet:
	@echo "Running vet..."
	@$(GO) vet ./...

install:
	@echo "Installing service..."
	@SERVICE_FILE="/etc/systemd/system/$(PROJECT_NAME).service"
	@echo "[Unit]" | sudo tee $${SERVICE_FILE}
	@echo "Description=$(PROJECT_NAME) service" | sudo tee -a $${SERVICE_FILE}
	@echo "After=network.target" | sudo tee -a $${SERVICE_FILE}
	@echo "[Service]" | sudo tee -a $${SERVICE_FILE}
	@echo "ExecStart=$$(pwd)/$(BINARY_NAME)" | sudo tee -a $${SERVICE_FILE}
	@echo "Restart=always" | sudo tee -a $${SERVICE_FILE}
	@echo "User=jenkins" | sudo tee -a $${SERVICE_FILE}
	@echo "Group=jenkins" | sudo tee -a $${SERVICE_FILE}
	@echo "Environment=GO_ENV=production" | sudo tee -a $${SERVICE_FILE}
	@echo "WorkingDirectory=$$(pwd)/$(BUILD_DIR)" | sudo tee -a $${SERVICE_FILE}
	@echo "[Install]" | sudo tee -a $${SERVICE_FILE}
	@echo "WantedBy=multi-user.target" | sudo tee -a $${SERVICE_FILE}
	@sudo systemctl daemon-reload
	@sudo systemctl enable $(PROJECT_NAME)

uninstall:
	@echo "Uninstalling service..."
	@SERVICE_FILE="/etc/systemd/system/$(PROJECT_NAME).service"
	@if systemctl list-units --full -all | grep -Fq $(PROJECT_NAME).service; then \
		sudo systemctl stop $(PROJECT_NAME); \
		sudo systemctl disable $(PROJECT_NAME); \
		sudo rm $${SERVICE_FILE}; \
		sudo systemctl daemon-reload; \
	else \
		echo "$(PROJECT_NAME) service not found."; \
	fi

help:
	@echo "Available targets:"
	@echo "  build:       Build the binary"
	@echo "  build-linux: Build the binary for Linux"
	@echo "  build-windows: Build the binary for Windows"
	@echo "  test:        Run unit tests"
	@echo "  coverage:    Run unit tests with coverage"
	@echo "  clean:       Clean up build artifacts"
	@echo "  fmt:         Format source code"
	@echo "  vet:         Run static code analysis"
	@echo "  install-service: Install the service"
	@echo "  uninstall-service: Uninstall the service"

.DEFAULT_GOAL := help