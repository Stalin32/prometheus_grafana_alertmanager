
#!/bin/bash

#установка Prometheus с базовой аутентификацией
#пароль шифровать на сайте https://bcrypt-generator.com/
 
apt update
apt install wget tar
wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz
mkdir /etc/prometheus /var/lib/prometheus
tar -zxf prometheus-*.linux-amd64.tar.gz
cd prometheus-*.linux-amd64
cp prometheus promtool /usr/local/bin/
cp -r console_libraries consoles prometheus.yml /etc/prometheus
cd .. && rm -rf prometheus-*.linux-amd64/ && rm -f prometheus-*.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /etc/prometheus 
chown -R prometheus:prometheus /var/lib/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

echo "[Unit]" >> ~/prometheus.service
echo "Description=Prometheus Service" >> ~/prometheus.service
echo "Documentation=https://prometheus.io/docs/introduction/overview/" >> ~/prometheus.service
echo "After=network.target" >> ~/prometheus.service
echo "" >> ~/prometheus.service
echo "[Service]" >> ~/prometheus.service
echo "User=prometheus" >> ~/prometheus.service
echo "Group=prometheus" >> ~/prometheus.service
echo "Type=simple" >> ~/prometheus.service
echo "ExecStart=/usr/local/bin/prometheus \\" >> ~/prometheus.service
echo " --config.file /etc/prometheus/prometheus.yml \\" >> ~/prometheus.service
echo " --web.config.file=/etc/prometheus/web.yml \\" >> ~/prometheus.service
echo " --storage.tsdb.path /var/lib/prometheus/ \\" >> ~/prometheus.service
echo " --web.console.templates=/etc/prometheus/consoles \\" >> ~/prometheus.service
echo " --web.console.libraries=/etc/prometheus/console_libraries" >> ~/prometheus.service
echo "ExecReload=/bin/kill -HUP \$MAINPID" >> ~/prometheus.service
echo "Restart=on-failure" >> ~/prometheus.service
echo "" >> ~/prometheus.service
echo "[Install]" >> ~/prometheus.service
echo "WantedBy=multi-user.target" >> ~/prometheus.service

mv ~/prometheus.service /etc/systemd/system/

echo "basic_auth_users:" >> /etc/prometheus/web.yml
echo "  monitoring: \$2a$12$ZT1iX9dlqQPQZVOWiBIPdOihUgNgMcxQj4aqcK.QIBNQvV6N8YDnS" >> /etc/prometheus/web.yml #в этой строчке содержится логин:шифрованный_пароль


systemctl enable prometheus
systemctl start prometheus

#установка Grafana

apt install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_10.2.3_amd64.deb
dpkg -i grafana_*_amd64.deb
systemctl enable grafana-server
systemctl start grafana-server
rm grafana_*_amd64.deb

#установка Alertmanager

wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
mkdir /etc/alertmanager 
mkdir /var/lib/prometheus/alertmanager
tar -zxf alertmanager-*.linux-amd64.tar.gz
cd alertmanager-*.linux-amd64
cp alertmanager amtool /usr/local/bin/
cp alertmanager.yml /etc/alertmanager
cd .. && rm -rf alertmanager-*.linux-amd64/ && rm -f alertmanager-*.linux-amd64.tar.gz
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
echo "          --web.config.file=/etc/prometheus/web.yml \\" >> ~/alertmanager.service
echo "          --storage.path=/var/lib/prometheus/alertmanager \\" >> ~/alertmanager.service
echo "          --cluster.advertise-address=0.0.0.0:9093 \\" >> ~/alertmanager.service
echo "          \$ALERTMANAGER_OPTS" >> ~/alertmanager.service
echo "ExecReload=/bin/kill -HUP \$MAINPID" >> ~/alertmanager.service
echo "Restart=on-failure" >> ~/alertmanager.service
echo "" >> ~/alertmanager.service
echo "[Install]" >> ~/alertmanager.service
echo "WantedBy=multi-user.target" >> ~/alertmanager.service

mv ~/alertmanager.service /etc/systemd/system/
systemctl enable alertmanager
systemctl start alertmanager

#установка Node_exporter

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
echo "ExecStart=/usr/local/bin/node_exporter" >> ~/node_exporter.service
echo "ExecReload=/bin/kill -HUP \$MAINPID" >> ~/node_exporter.service
echo "Restart=on-failure" >> ~/node_exporter.service
echo "" >> ~/node_exporter.service
echo "[Install]" >> ~/node_exporter.service
echo "WantedBy=multi-user.target" >> ~/node_exporter.service

mv ~/node_exporter.service /etc/systemd/system/
systemctl enable node_exporter
systemctl start node_exporter

#удаление скрипта

rm prometheus_grafana_alertmanager.sh