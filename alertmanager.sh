#!/bin/bash

wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
mkdir /etc/alertmanager 
mkdir /var/lib/prometheus/alertmanager
tar -zxf alertmanager-*.linux-amd64.tar.gz
cd alertmanager-*.linux-amd64
cp alertmanager amtool /usr/local/bin/
cp alertmanager.yml /etc/alertmanager
cd .. && rm -rf alertmanager-*.linux-amd64/
useradd --no-create-home --shell /bin/false alertmanager
chown -R alertmanager:alertmanager /etc/alertmanager 
chown -R alertmanager:alertmanager /var/lib/prometheus/alertmanager
chown alertmanager:alertmanager /usr/local/bin/alertmanager
chown alertmanager:alertmanager /usr/local/bin/amtool

echo "[Unit]" >> ~/alertmanager.service
echo "Description=Alertmanager Service" >> ~/alertmanager.service
echo "After=network.target" >> ~/alertmanager.service
echo "" >> ~/alertmanager.service
echo "[Service]" >> ~/alertmanager.service
echo "EnvironmentFile=-/etc/default/alertmanager" >> ~/alertmanager.service
echo "User=alertmanager" >> ~/alertmanager.service
echo "Group=alertmanager" >> ~/alertmanager.service
echo "Type=simple" >> ~/alertmanager.service
echo "ExecStart=/usr/local/bin/alertmanager \\" >> ~/alertmanager.service
echo "          --config.file=/etc/alertmanager/alertmanager.yml \\" >> ~/alertmanager.service
echo "          --storage.path=/var/lib/prometheus/alertmanager \\" >> ~/alertmanager.service
echo "          --cluster.advertise-address=0.0.0.0:9093 \\" >> ~/alertmanager.service
echo "          \$ALERTMANAGER_OPTS" >> ~/alertmanager.service
echo "ExecReload=/bin/kill -HUP \$MAINPID" >> ~/alertmanager.service
echo "Restart=on-failure" >> ~/alertmanager.service
echo "" >> ~/alertmanager.service
echo "[Install]" >> ~/alertmanager.service
echo "WantedBy=multi-user.target" >> ~/alertmanager.service

mv ~/alertmanager.service /etc/systemd/system/
# systemctl enable alertmanager
# systemctl start alertmanager