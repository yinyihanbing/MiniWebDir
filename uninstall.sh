#!/bin/bash

PROJECT_NAME="ggweb"
SERVICE_FILE="/etc/systemd/system/${PROJECT_NAME}.service"

if systemctl list-units --full -all | grep -Fq ${PROJECT_NAME}.service; then
	sudo systemctl stop ${PROJECT_NAME}
	sudo systemctl disable ${PROJECT_NAME}
	sudo rm ${SERVICE_FILE}
	sudo systemctl daemon-reload
else
	echo "${PROJECT_NAME} service not found."
fi
