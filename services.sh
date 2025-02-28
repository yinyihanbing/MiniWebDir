#!/bin/bash

ACTION=$1

PROJECT_NAME="ggweb"
SERVICE_FILE="/etc/systemd/system/${PROJECT_NAME}.service"
WORKING_DIRECTORY="$(pwd)/bin/"
APP_PATH="${WORKING_DIRECTORY}/${PROJECT_NAME}"
USER="jenkins"
GROUP="jenkins"

case $ACTION in
	install)
		if systemctl list-units --full -all | grep -Fq "${PROJECT_NAME}.service"; then
			echo "${PROJECT_NAME} service is already installed. Skipping installation."
			exit 0
		fi

		echo "[Unit]" | sudo tee ${SERVICE_FILE}
		echo "Description=${PROJECT_NAME} service" | sudo tee -a ${SERVICE_FILE}
		echo "After=network.target" | sudo tee -a ${SERVICE_FILE}
		echo "[Service]" | sudo tee -a ${SERVICE_FILE}
		echo "ExecStart=${APP_PATH}" | sudo tee -a ${SERVICE_FILE}
		echo "Restart=always" | sudo tee -a ${SERVICE_FILE}
		echo "User=${USER}" | sudo tee -a ${SERVICE_FILE}
		echo "Group=${GROUP}" | sudo tee -a ${SERVICE_FILE}
		echo "Environment=GO_ENV=production" | sudo tee -a ${SERVICE_FILE}
		echo "WorkingDirectory=${WORKING_DIRECTORY}" | sudo tee -a ${SERVICE_FILE}
		echo "[Install]" | sudo tee -a ${SERVICE_FILE}
		echo "WantedBy=multi-user.target" | sudo tee -a ${SERVICE_FILE}

		sudo systemctl daemon-reload
		sudo systemctl enable ${PROJECT_NAME}
		;;
	uninstall)
		if systemctl list-units --full -all | grep -Fq ${PROJECT_NAME}.service; then
			sudo systemctl stop ${PROJECT_NAME}
			sudo systemctl disable ${PROJECT_NAME}
			sudo rm ${SERVICE_FILE}
			sudo systemctl daemon-reload
		else
			echo "${PROJECT_NAME} service not found."
		fi
		;;
	start)
		sudo systemctl start ${PROJECT_NAME}
		;;
	stop)
		if systemctl list-units --full -all | grep -Fq ${PROJECT_NAME}.service; then
			sudo systemctl stop ${PROJECT_NAME}
		else
			echo "${PROJECT_NAME} service not found."
		fi
		;;
	*)
		echo "Usage: $0 {install|uninstall|start|stop}"
		exit 1
		;;
esac
