sudo apt update

apt install wget tar

wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz

sudo mkdir /etc/prometheus /var/lib/prometheus

tar -zxf prometheus-*.linux-amd64.tar.gz

cd prometheus-*.linux-amd64

sudo cp prometheus promtool /usr/local/bin/

sudo cp -r console_libraries consoles prometheus.yml /etc/prometheus

cd .. && rm -rf prometheus-*.linux-amd64/ && rm -f prometheus-*.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false prometheus

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

sudo echo "[Unit]" >> ~/prometheus.service
sudo echo "Description=Prometheus Service" >> ~/prometheus.service
sudo echo "Documentation=https://prometheus.io/docs/introduction/overview/" >> ~/prometheus.service
sudo echo "After=network.target" >> ~/prometheus.service
sudo echo "" >> ~/prometheus.service
sudo echo "[Service]" >> ~/prometheus.service
sudo echo "User=prometheus" >> ~/prometheus.service
sudo echo "Group=prometheus" >> ~/prometheus.service
sudo echo "Type=simple" >> ~/prometheus.service
sudo echo "ExecStart=/usr/local/bin/prometheus \" >> ~/prometheus.service
sudo echo " --config.file /etc/prometheus/prometheus.yml \" >> ~/prometheus.service
sudo echo " --storage.tsdb.path /var/lib/prometheus/ \" >> ~/prometheus.service
sudo echo " --web.console.templates=/etc/prometheus/consoles \" >> ~/prometheus.service
sudo echo " --web.console.libraries=/etc/prometheus/console_libraries" >> ~/prometheus.service
sudo echo "ExecReload=/bin/kill -HUP $MAINPID" >> ~/prometheus.service
sudo echo "Restart=on-failure" >> ~/prometheus.service
sudo echo "" >> ~/prometheus.service
sudo echo "[Install]" >> ~/prometheus.service
sudo echo "WantedBy=multi-user.target"" >> ~/prometheus.service

sudo mv ~/prometheus.service /etc/systemd/system/
sudo systemctl enable prometheus
sudo systemctl start prometheus