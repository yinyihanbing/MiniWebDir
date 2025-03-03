PROJECT_NAME := miniwebdir
GO := go
BUILD_TAGS :=
BUILD_DIR := bin
BINARY_NAME := $(BUILD_DIR)/$(PROJECT_NAME)
SRC_DIR := .
COVERAGE_FILE := coverage.out

build: build-linux
build-linux: BUILD_OS := linux
build-windows: BUILD_OS := windows
build-linux build-windows: build-common

build-common:
	@echo "Building $(PROJECT_NAME) for $(BUILD_OS)..."
	@$(GO) mod tidy
	@mkdir -p $(BUILD_DIR)/
	@GOOS=$(BUILD_OS) GOARCH=amd64 $(GO) build -tags="$(BUILD_TAGS)" -ldflags="-s -w" -o $(BINARY_NAME)$(if $(filter windows,$(BUILD_OS)),.exe) $(SRC_DIR)

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

.DEFAULT_GOAL := help