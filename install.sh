#!/bin/bash

CURRENT_DIR=$(pwd)
PROJECT_NAME="ggweb"
BUILD_DIR="bin"
BINARY_NAME="${BUILD_DIR}/${PROJECT_NAME}"
SERVICE_FILE="/etc/systemd/system/${PROJECT_NAME}.service"

echo "[Unit]" | sudo tee ${SERVICE_FILE}
echo "Description=${PROJECT_NAME} service" | sudo tee -a ${SERVICE_FILE}
echo "After=network.target" | sudo tee -a ${SERVICE_FILE}
echo "[Service]" | sudo tee -a ${SERVICE_FILE}
echo "ExecStart=${CURRENT_DIR}/${BINARY_NAME}" | sudo tee -a ${SERVICE_FILE}
echo "Restart=always" | sudo tee -a ${SERVICE_FILE}
echo "User=jenkins" | sudo tee -a ${SERVICE_FILE}
echo "Group=jenkins" | sudo tee -a ${SERVICE_FILE}
echo "Environment=GO_ENV=production" | sudo tee -a ${SERVICE_FILE}
echo "WorkingDirectory=${CURRENT_DIR}/${BUILD_DIR}" | sudo tee -a ${SERVICE_FILE}
echo "[Install]" | sudo tee -a ${SERVICE_FILE}
echo "WantedBy=multi-user.target" | sudo tee -a ${SERVICE_FILE}

sudo systemctl daemon-reload
sudo systemctl enable ${PROJECT_NAME}
