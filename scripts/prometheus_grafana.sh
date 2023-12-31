#!/bin/bash

# Create a system user 'prometheus' without a home directory and with /bin/false as the login shell
sudo useradd \
    --system \
    --no-create-home \
    --shell /bin/false prometheus

# Download and extract Prometheus binary release version 2.47.1 for Linux AMD64
wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz
tar -xvf prometheus-2.47.1.linux-amd64.tar.gz

# Create directories for Prometheus configuration and data
sudo mkdir -p /data /etc/prometheus

# Move Prometheus binaries and configuration to appropriate locations
cd prometheus-2.47.1.linux-amd64/
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# Change ownership of configuration and data directories to the 'prometheus' user
sudo chown -R prometheus:prometheus /etc/prometheus/ /data/

# Clean up downloaded Prometheus archive
cd
rm -rf prometheus-2.47.1.linux-amd64.tar.gz

# Create systemd service file for Prometheus
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Enable, start, and check the status of the Prometheus service
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Create a system user 'node_exporter' without a home directory and with /bin/false as the login shell
sudo useradd \
    --system \
    --no-create-home \
    --shell /bin/false node_exporter

# Download and extract Node Exporter binary release version 1.6.1 for Linux AMD64
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz

# Move Node Exporter binary to /usr/local/bin/
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Clean up downloaded Node Exporter archive
rm -rf node_exporter*

# Create systemd service file for Node Exporter
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --collector.logind

[Install]
WantedBy=multi-user.target
EOF

# Enable, start, and check the status of the Node Exporter service
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

# Append the 'node_exporter' scrape configuration to Prometheus configuration
PROMETHEUS_YML="/etc/prometheus/prometheus.yml"
cat <<EOF >> "$PROMETHEUS_YML"
  - job_name: "node_export"
    static_configs:
      - targets: ["localhost:9100"]
EOF

# Check Prometheus configuration for syntax errors
promtool check config /etc/prometheus/prometheus.yml

# Send a POST request to Prometheus to reload its configuration
curl -X POST http://localhost:9090/-/reload

# Install Grafana
sudo apt-get install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get -y install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl status grafana-server
