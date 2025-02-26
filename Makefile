PROJECT_NAME := ggweb

GO := go

BUILD_TAGS :=

BUILD_DIR := bin

BINARY_NAME := $(BUILD_DIR)/$(PROJECT_NAME)

SRC_DIR := .

COVERAGE_FILE := coverage.out

init:
		@echo "Initializing project..."
		@$(GO) mod tidy

build: stop clean init build-linux

build-linux:
		@echo "Building $(PROJECT_NAME) for Linux..."
		@mkdir -p $(BUILD_DIR)/
		@GOOS=linux GOARCH=amd64 $(GO) build -tags="$(BUILD_TAGS)" -o $(BUILD_DIR)/$(PROJECT_NAME) $(SRC_DIR)
		@cp -r www $(BUILD_DIR)/

build-windows:
		@echo "Building $(PROJECT_NAME) for Windows..."
		@mkdir -p $(BUILD_DIR)/
		@GOOS=windows GOARCH=amd64 $(GO) build -tags="$(BUILD_TAGS)" -o $(BUILD_DIR)/$(PROJECT_NAME).exe $(SRC_DIR)
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

run: run-linux

run-linux:
		@echo "Starting $(PROJECT_NAME) service..."
		@systemctl start $(PROJECT_NAME)

run-windows:
		@echo "Running $(PROJECT_NAME) in the background..."
		@cd $(BUILD_DIR) && start $(BUILD_DIR)/$(PROJECT_NAME).exe

stop: stop-linux

stop-linux:
		@echo "Stopping $(PROJECT_NAME) service..."
		@systemctl stop $(PROJECT_NAME)

stop-windows:
		@echo "Stopping $(PROJECT_NAME)..."
		@taskkill /F /IM $(PROJECT_NAME).exe

fmt:
		@echo "Formatting code..."
		@$(GO) fmt ./...

vet:
		@echo "Running vet..."
		@$(GO) vet ./...

help:
		@echo "Available targets:"
		@echo "  build:       Build the binary"
		@echo "  build-linux: Build the binary for Linux"
		@echo "  build-windows: Build the binary for Windows"
		@echo "  test:        Run unit tests"
		@echo "  coverage:    Run unit tests with coverage"
		@echo "  clean:       Clean up build artifacts"
		@echo "  run:         Build and run the binary"
		@echo "  run-linux:   Run the binary on Linux"
		@echo "  run-windows: Run the binary on Windows"
		@echo "  stop:        Stop the running binary"
		@echo "  stop-linux:  Stop the running binary on Linux"
		@echo "  stop-windows: Stop the running binary on Windows"
		@echo "  fmt:         Format source code"
		@echo "  vet:         Run static code analysis"
		@echo "  help:        Show this help message"

.DEFAULT_GOAL := help