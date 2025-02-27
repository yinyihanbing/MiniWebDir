#!/bin/bash

ACTION=$1
PROJECT_NAME="ggweb"
BUILD_DIR="bin"
BINARY_NAME="${BUILD_DIR}/${PROJECT_NAME}"
SERVICE_FILE="/etc/systemd/system/${PROJECT_NAME}.service"
CURRENT_DIR=$(pwd)

case $ACTION in
	install)
		if systemctl list-units --full -all | grep -Fq "${PROJECT_NAME}.service"; then
			echo "${PROJECT_NAME} service is already installed. Skipping installation."
			exit 0
		fi

		echo "[Unit]" | tee ${SERVICE_FILE}
		echo "Description=${PROJECT_NAME} service" | tee -a ${SERVICE_FILE}
		echo "After=network.target" | tee -a ${SERVICE_FILE}
		echo "[Service]" | tee -a ${SERVICE_FILE}
		echo "ExecStart=${CURRENT_DIR}/${BINARY_NAME}" | tee -a ${SERVICE_FILE}
		echo "Restart=always" | tee -a ${SERVICE_FILE}
		echo "User=jenkins" | tee -a ${SERVICE_FILE}
		echo "Group=jenkins" | tee -a ${SERVICE_FILE}
		echo "Environment=GO_ENV=production" | tee -a ${SERVICE_FILE}
		echo "WorkingDirectory=${CURRENT_DIR}/${BUILD_DIR}" | tee -a ${SERVICE_FILE}
		echo "[Install]" | tee -a ${SERVICE_FILE}
		echo "WantedBy=multi-user.target" | tee -a ${SERVICE_FILE}

		systemctl daemon-reload
		systemctl enable ${PROJECT_NAME}
		;;
	uninstall)
		if systemctl list-units --full -all | grep -Fq ${PROJECT_NAME}.service; then
			systemctl stop ${PROJECT_NAME}
			systemctl disable ${PROJECT_NAME}
			rm ${SERVICE_FILE}
			systemctl daemon-reload
		else
			echo "${PROJECT_NAME} service not found."
		fi
		;;
	start)
		if systemctl list-units --full -all | grep -Fq ${PROJECT_NAME}.service; then
			systemctl start ${PROJECT_NAME}
		else
			echo "${PROJECT_NAME} service not found. Please install it first."
		fi
		;;
	stop)
		if systemctl list-units --full -all | grep -Fq ${PROJECT_NAME}.service; then
			systemctl stop ${PROJECT_NAME}
		else
			echo "${PROJECT_NAME} service not found."
		fi
		;;
	*)
		echo "Usage: $0 {install|uninstall|start|stop}"
		exit 1
		;;
esac
