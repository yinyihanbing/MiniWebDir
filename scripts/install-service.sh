#!/bin/sh

PROJECT_NAME="ggweb"
SERVICE_FILE="/etc/systemd/system/$PROJECT_NAME.service"

echo "[Unit]" | sudo tee $SERVICE_FILE
echo "Description=$PROJECT_NAME service" | sudo tee -a $SERVICE_FILE
echo "After=network.target" | sudo tee -a $SERVICE_FILE
echo "[Service]" | sudo tee -a $SERVICE_FILE
echo "ExecStart=$(pwd)/$PROJECT_NAME" | sudo tee -a $SERVICE_FILE
echo "Restart=always" | sudo tee -a $SERVICE_FILE
echo "User=$(whoami)" | sudo tee -a $SERVICE_FILE
echo "Group=$(whoami)" | sudo tee -a $SERVICE_FILE
echo "Environment=GO_ENV=production" | sudo tee -a $SERVICE_FILE
echo "WorkingDirectory=$(pwd)" | sudo tee -a $SERVICE_FILE
echo "[Install]" | sudo tee -a $SERVICE_FILE
echo "WantedBy=multi-user.target" | sudo tee -a $SERVICE_FILE

sudo systemctl daemon-reload
sudo systemctl enable $PROJECT_NAME
sudo systemctl start $PROJECT_NAME
