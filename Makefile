PROJECT_NAME := ggweb

GO := go

BUILD_TAGS :=

BUILD_DIR := bin

BINARY_NAME := $(BUILD_DIR)/$(PROJECT_NAME)

SRC_DIR := .

COVERAGE_FILE := coverage.out

PID_FILE := $(BUILD_DIR)/$(PROJECT_NAME).pid

SERVICE_FILE := /etc/systemd/system/$(PROJECT_NAME).service

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

install-service:
		@echo "Installing systemd service for $(PROJECT_NAME)..."
		@echo "[Unit]" > $(SERVICE_FILE)
		@echo "Description=$(PROJECT_NAME) service" >> $(SERVICE_FILE)
		@echo "After=network.target" >> $(SERVICE_FILE)
		@echo "[Service]" >> $(SERVICE_FILE)
		@echo "ExecStart=$(shell pwd)/$(BINARY_NAME)" >> $(SERVICE_FILE)
		@echo "Restart=always" >> $(SERVICE_FILE)
		@echo "User=$(shell whoami)" >> $(SERVICE_FILE)
		@echo "Group=$(shell whoami)" >> $(SERVICE_FILE)
		@echo "Environment=GO_ENV=production" >> $(SERVICE_FILE)
		@echo "WorkingDirectory=$(shell pwd)" >> $(SERVICE_FILE)
		@echo "[Install]" >> $(SERVICE_FILE)
		@echo "WantedBy=multi-user.target" >> $(SERVICE_FILE)
		@systemctl daemon-reload
		@systemctl enable $(PROJECT_NAME)
		@systemctl start $(PROJECT_NAME)

uninstall-service:
		@echo "Uninstalling systemd service for $(PROJECT_NAME)..."
		@systemctl stop $(PROJECT_NAME)
		@systemctl disable $(PROJECT_NAME)
		@rm $(SERVICE_FILE)
		@systemctl daemon-reload

run: install-service

run-linux: build-linux
		@echo "Running $(PROJECT_NAME) in the background..."
		@cd $(BUILD_DIR) && nohup ./$(PROJECT_NAME) & echo $$! > $(PID_FILE)

run-windows: build-windows
		@echo "Running $(PROJECT_NAME) in the background..."
		@cd $(BUILD_DIR) && start $(BUILD_DIR)/$(PROJECT_NAME).exe

stop: uninstall-service

stop-linux:
		@echo "Stopping $(PROJECT_NAME)..."
		@if [ -f $(PID_FILE) ]; then \
				kill $(shell cat $(PID_FILE)); \
				rm $(PID_FILE); \
		else \
				echo "PID file not found. $(PROJECT_NAME) might not be running."; \
		fi

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
		@echo "  build:   Build the binary"
		@echo "  test:    Run unit tests"
		@echo "  coverage: Run unit tests with coverage"
		@echo "  clean:   Clean up build artifacts"
		@echo "  run:     Build and run the binary"
		@echo "  stop:    Stop the running binary"
		@echo "  fmt:     Format source code"
		@echo "  vet:     Run static code analysis"
		@echo "  help:    Show this help message"

.DEFAULT_GOAL := help