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

build: clean init build-linux

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

run-linux: build-linux
		@echo "Running $(PROJECT_NAME)..."
		@cd $(BUILD_DIR) && ./$(PROJECT_NAME)

run-windows: build-windows
		@echo "Running $(PROJECT_NAME)..."
		@cd $(BUILD_DIR) && ./$(PROJECT_NAME).exe

fmt:
		@echo "Formatting code..."
		@$(GO) fmt ./...

vet:
		@echo "Running vet..."
		@$(GO) vet ./...

help:
		@echo "Available targets:"
		@echo "  build:    Build the binary"
		@echo "  test:     Run unit tests"
		@echo "  coverage: Run unit tests with coverage"
		@echo "  clean:    Clean up build artifacts"
		@echo "  run:      Build and run the binary"
		@echo "  fmt:      Format source code"
		@echo "  vet:      Run static code analysis"
		@echo "  help:     Show this help message"

.DEFAULT_GOAL := help