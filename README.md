# lorawan

EC2 setup:

---------------Grafana
https://www.radishlogic.com/aws/ec2/how-to-install-grafana-on-ec2-amazon-linux-2/

sudo yum update -y

sudo nano /etc/yum.repos.d/grafana.repo

[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt

sudo yum install grafana

sudo systemctl daemon-reload

sudo systemctl start grafana-server

sudo systemctl status grafana-server

sudo systemctl enable grafana-server.service

	test:18.206.59.38:3000


---------------InfluxDb
	https://techviewleo.com/how-to-install-influxdb-on-amazon-linux/

cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL 7
baseurl = https://repos.influxdata.com/rhel/7/x86_64/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF



sudo yum install influxdb

sudo systemctl start influxdb

sudo systemctl enable influxdb


---------------set up database
	https://aws.amazon.com/blogs/iot/influxdb-and-grafana-with-aws-iot-to-visualize-time-series-data/

influx
create database tracker
create user awsblog with password 'awsblog'


-----------------Telegraf
	https://community.influxdata.com/t/send-sensor-data-to-influxdb-deployed-on-aws-via-mqtt/15393/2
sudo yum install telegraf
sudo systemctl start telegraf
 
sudo systemctl enable telegraf

sudo nano /etc/telegraf/telegraf.conf



[[outputs.influxdb]]
urls = ["http://127.0.0.1:8086"]

database = "tracker"
username = "awsblog"
password = "awsblog"

[[outputs.file]]
  files = ["stdout", "/tmp/metrics.out"]

[[inputs.mqtt_consumer]]
servers = ["tcp://127.0.0.1:1883"]

topics = ["tracker", "tracker/#",]

username = "loriot"
password = "loriot"




-----------------Mosquitto
	https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-centos-7
	https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html#ssl_test

sudo yum -y install epel-release

sudo yum -y install mosquitto

sudo systemctl start mosquitto

sudo systemctl enable mosquitto

sudo mosquitto_passwd -c /etc/mosquitto/passwd loriot

nano /etc/mosquitto/mosquitto.conf

	allow_anonymous false
	password_file /etc/mosquitto/passwd
	/etc/mosquitto/mosquitto.conf

	listener 1883 localhost
	listener 8883

certfile /etc/letsencrypt/live/vitorlasbalaton.hu/cert.pem
cafile /etc/letsencrypt/live/vitorlasbalaton.hu/chain.pem
keyfile /etc/letsencrypt/live/vitorlasbalaton.hu/privkey.pem

sudo nano /etc/systemd/system/multi-user.target.wants/mosquitto.service
	Look for a line that says User=mosquitto and remove it, then save and exit the file.

sudo systemctl restart mosquitto

