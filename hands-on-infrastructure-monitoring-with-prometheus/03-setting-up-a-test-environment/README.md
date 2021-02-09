### Step 1 - Setup PROMETHEUS

```
vagrant up --no-provision --provider virtualbox

```

Log in to the Prometheus guest instance:

```
vagrant ssh prometheus
sudo -i
```

Add all the guests' addresses to the instance host's file:

```
cat <<EOF >/etc/hosts
127.0.0.1       localhost
192.168.42.10   prometheus.prom.inet    prometheus
192.168.42.11   grafana.prom.inet       grafana
192.168.42.12   alertmanager.prom.inet  alertmanager


# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
```

Create a new system user:

```
useradd --system prometheus
```

Go into /tmp and download the Prometheus archive:

```

curl -sLO "https://github.com/prometheus/prometheus/releases/download/v2.9.2/prometheus-2.9.2.linux-amd64.tar.gz"

tar zxvf prometheus-2.9.2.linux-amd64.tar.gz -C /tmp && cd /tmp

```

Place every file in its correct location:

```
install -m 0644 -D -t /usr/share/prometheus/consoles prometheus-2.9.2.linux-amd64/consoles/*

install -m 0644 -D -t /usr/share/prometheus/console_libraries prometheus-2.9.2.linux-amd64/console_libraries/*

install -m 0755 prometheus-2.9.2.linux-amd64/prometheus prometheus-2.9.2.linux-amd64/promtool /usr/bin/

install -d -o prometheus -g prometheus /var/lib/prometheus   

install -m 0644 -D /vagrant/03-setting-up-a-test-environment/configs/prometheus/prometheus.yml /etc/prometheus/prometheus.yml

install -m 0644 -D /vagrant/03-setting-up-a-test-environment/configs/prometheus/first_rules.yml /etc/prometheus/first_rules.yml
```

Setup prometheus services:

```
install -m 0644 /vagrant/03-setting-up-a-test-environment/configs/prometheus/prometheus.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
```

### Step 2 - Setup GRAFANA

Login into grafana:

```
vagrant ssh grafana
sudo -i
```

Add all the guests' addresses to the instance host's file:

```
cat <<EOF >/etc/hosts
127.0.0.1       localhost
192.168.42.10   prometheus.prom.inet    prometheus
192.168.42.11   grafana.prom.inet       grafana
192.168.42.12   alertmanager.prom.inet  alertmanager


# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

```

Go into /tmp and download the Grafana archive:

```

curl -sLO "https://dl.grafana.com/oss/release/grafana_6.1.6_amd64.deb"
DEBIAN_FRONTEND=noninteractive apt-get install -y libfontconfig
dpkg -i "grafana_6.1.6_amd64.deb"

```

Setup and run Grafana service:

```
rsync -ru /vagrant/03-setting-up-a-test-environment/configs/grafana/{dashboards,provisioning} /etc/grafana/
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
```

### Step 2 - Setup ALERTMANAGER

Login into alertmanager:

```
vagrant ssh alertmanager 
sudo -i
```

Add all the guests' addresses to the instance host's file:

```
cat <<EOF >/etc/hosts
127.0.0.1       localhost
192.168.42.10   prometheus.prom.inet    prometheus
192.168.42.11   grafana.prom.inet       grafana
192.168.42.12   alertmanager.prom.inet  alertmanager


# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

```

Create a new system user:

```
useradd --system alertmanager
```

Go into /tmp and download the Alertmanager archive:

```
curl -sLO "https://github.com/prometheus/alertmanager/releases/download/v0.17.0/alertmanager-0.17.0.linux-amd64.tar.gz"

tar zxvf alertmanager-0.17.0.linux-amd64.tar.gz -C /tmp && cd /tmp

```

Place every file in its correct location:

```
install -m 0755 alertmanager-0.17.0.linux-amd64/{alertmanager,amtool} /vagrant/03-setting-up-a-test-environment/configs/alertmanager/alertdump /usr/bin/

install -d -o alertmanager -g alertmanager /var/lib/alertmanager

install -m 0644 -D /vagrant/03-setting-up-a-test-environment/configs/alertmanager/alertmanager.yml /etc/alertmanager/alertmanager.yml
```

Setup and run Alertmanager service:

```
install -m 0644 /vagrant/03-setting-up-a-test-environment/configs/alertmanager/alertmanager.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager
```

### Step 2 - Setup Node Exporter

To ensure that system-level metrics will be collected, Node Exporter must be installed in all three virtual machines.

```
sudo -i
useradd --system node_exporter
cd /tmp
curl -sLO "https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz"
tar zxvf "node_exporter-0.17.0.linux-amd64.tar.gz" -C /usr/bin --strip-components=1 --wildcards */node_exporter
```

Add a systemd unit file for the Node Exporter service:

```
install -m 0644 /vagrant/03-setting-up-a-test-environment/configs/node_exporter/node-exporter.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable node-exporter
systemctl start node-exporter
```