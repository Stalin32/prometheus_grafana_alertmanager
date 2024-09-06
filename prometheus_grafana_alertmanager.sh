
#!/bin/bash
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
echo "ExecStart=/usr/local/bin/prometheus \ " >> ~/prometheus.service
echo " --config.file /etc/prometheus/prometheus.yml \ " >> ~/prometheus.service
echo " --storage.tsdb.path /var/lib/prometheus/ \ " >> ~/prometheus.service
echo " --web.console.templates=/etc/prometheus/consoles \ " >> ~/prometheus.service
echo " --web.console.libraries=/etc/prometheus/console_libraries" >> ~/prometheus.service
echo "ExecReload=/bin/kill -HUP $MAINPID" >> ~/prometheus.service
echo "Restart=on-failure" >> ~/prometheus.service
echo "" >> ~/prometheus.service
echo "[Install]" >> ~/prometheus.service
echo "WantedBy=multi-user.target" >> ~/prometheus.service

mv ~/prometheus.service /etc/systemd/system/
systemctl enable prometheus
systemctl start prometheus