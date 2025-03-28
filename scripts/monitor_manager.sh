#!/bin/bash

sudo -v
touch /tmp/monitor_manager.service
echo "[Unit]
Description=Monitor Manager
After=graphical-session.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=3
ExecStart=/home/afzal/.scripts/setup_monitors.sh
[Install]
WantedBy=multi-user.target" > /tmp/monitor_manager.service
sudo mv /tmp/monitor_manager.service /etc/systemd/system/monitor_manager.service
sudo systemctl daemon-reload
sudo systemctl enable monitor_manager 
sudo systemctl start monitor_manager 

