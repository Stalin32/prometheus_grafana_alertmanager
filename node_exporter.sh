#!/bin/bash

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

tar -zxf node_exporter-*.linux-amd64.tar.gz
cd node_exporter-*.linux-amd64
cp node_exporter /usr/local/bin/
cd .. && rm -rf node_exporter-*.linux-amd64/ && rm -f node_exporter-*.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false nodeusr
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

echo "[Unit]" >> ~/node_exporter.service
echo "Description=Node Exporter Service" >> ~/node_exporter.service
echo "After=network.target" >> ~/node_exporter.service
echo "" >> ~/node_exporter.service
echo "[Service]" >> ~/node_exporter.service
echo "User=nodeusr" >> ~/node_exporter.service
echo "Group=nodeusr" >> ~/node_exporter.service
echo "Type=simple" >> ~/node_exporter.service
echo "ExecStart=/usr/local/bin/node_exporter --collector.systemd" >> ~/node_exporter.service
echo "ExecReload=/bin/kill -HUP \$MAINPID" >> ~/node_exporter.service
echo "Restart=on-failure" >> ~/node_exporter.service
echo "" >> ~/node_exporter.service
echo "[Install]" >> ~/node_exporter.service
echo "WantedBy=multi-user.target" >> ~/node_exporter.service

mv ~/node_exporter.service /etc/systemd/system/
systemctl enable node_exporter
systemctl start node_exporter

