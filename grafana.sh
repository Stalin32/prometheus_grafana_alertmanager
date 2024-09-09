#!/bin/bash

apt install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_10.2.3_amd64.deb
dpkg -i grafana_*_amd64.deb
systemctl enable grafana-server
systemctl start grafana-server
rm grafana_*_amd64.deb
