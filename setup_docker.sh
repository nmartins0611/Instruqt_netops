### Prep box

yum remove podman -y
yum install yum-utils wget git -y
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sed -i 's~/rhel/~/centos/~g' /etc/yum.repos.d/docker-ce.repo
yum --noplugins install docker-ce docker-ce-cli containerd.io docker-compose-plugin --allowerasing -y
systemctl enable docker
systemctl start docker
setenforce 0

# Grab sample switch config
rm -rf /tmp/setup ## Troubleshooting step

mkdir /tmp/setup/

git clone https://github.com/nmartins0611/Instruqt_netops.git /tmp/setup/

#systemctl stop firewalld
#systemctl disable firewalld

### Configure containers

docker pull ############## -- CEOS Lab From Arista
docker pull docker.io/nats
docker pull quay.io/nmartins/ansible-rulebook
docker pull docker.io/confluentinc/cp-zookeeper:7.0.1
docker pull docker.io/confluentinc/cp-kafka:7.0.1

## Create Networks

docker network create net1
docker network create net2
docker network create net3
docker network create loop

# Create Zookeeper
docker run -d --name=zookeeper --privileged \
    -e ZOOKEEPER_TICK_TIME=2000 \
    -e ZOOKEEPER_CLIENT_PORT=2182 \
    -p 2181:2181 \
    docker.io/confluentinc/cp-zookeeper:7.0.1 

## Create Kafka 
docker run -d --name=broker --privileged \
    -e KAFKA_BROKER_ID=1 \
    -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://broker:9092,PLAINTEXT_INTERNAL://broker:29092 \
    -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
    -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT \
    -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    -p 9092:9092 \
    -p 29092:29029 \
    docker.io/confluentinc/cp-kafka:7.0.1 

## Create EDA Ansible-rulebook

#podman create --name=ansible-rulebook --privileged quay.io/nmartins/ansible-rulebook
docker run -d --name=ansible-rulebook quay.io/nmartins/ansible-rulebook

## Create Switch configs with Starting config

# podman create --name=ceos1 --privileged -v /tmp/setup/sw01/sw01:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 9092:9092 -p 6031:6030 -p 2001:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=podman
docker create --name=ceos1 --privileged -v /tmp/setup/sw01/sw01:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6031:6030 -p 2001:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker ##
docker create --name=ceos2 --privileged -v /tmp/setup/sw02/sw02:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6032:6030 -p 2002:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker ##systemd.setenv=MGMT_INTF=eth0
docker create --name=ceos3 --privileged -v /tmp/setup/sw03/sw03:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6033:6030 -p 2003:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker ##systemd.setenv=MGMT_INTF=eth0
## Attach Networks

docker network connect loop ceos1
docker network connect net1 ceos1
docker network connect net3 ceos1

docker network connect loop ceos2
docker network connect net1 ceos2
docker network connect net2 ceos2

docker network connect loop ceos3
docker network connect net2 ceos3
docker network connect net3 ceos3

## Start Switches

docker start ceos1
docker start ceos2
docker start ceos3

sleep 120

## Each tab loads a switch

## Install Gmnic
bash -c "$(curl -sL https://get-gnmic.kmrd.dev)"

## Test GMNIC
## gnmic -a localhost:6031 -u ansible -p ansible --insecure subscribe --path   "/interfaces/interface[name=Ethernet1]/state/admin-status"
