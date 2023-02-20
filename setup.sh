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
mkdir /tmp/setup
git clone https://github.com/nmartins0611/Instruqt_netops.git /tmp/setup
chmod -R 777 /tmp/setup


### Configure containers

## Create Networks

docker network create net1
docker network create net2
docker network create net3
docker network create loop

## Create Switch configs with Starting config

docker create --name=ceos1 --privileged -v /tmp/setup/sw01/sw01:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6031:6030 -p 2001:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
docker create --name=ceos1 --privileged -v /tmp/setup/sw02/sw02:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6031:6030 -p 2001:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
docker create --name=ceos1 --privileged -v /tmp/setup/sw03/sw03:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -p 6031:6030 -p 2001:22/tcp -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker

#docker create --name=ceos1 --privileged -v /tmp/setup/sw01/sw01.conf:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
#docker create --name=ceos2 --privileged -v /tmp/setup/sw02/sw02.conf:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker
#docker create --name=ceos3 --privileged -v /tmp/setup/sw03/sw03.conf:/mnt/flash/startup-config -e INTFTYPE=eth -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t quay.io/nmartins/ceoslab-rh /sbin/init systemd.setenv=INTFTYPE=eth systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker

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


docker network connect net1 ceos1
docker network connect net2 ceos1

docker network connect net1 ceos2
docker network connect net2 ceos2

docker network connect net1 ceos3
docker network connect net2 ceos3

## Start Switches

docker start ceos1
docker start ceos2
docker start ceos3

sleep 120

## Each tab loads a switch

#docker exec -it ceos1 Cli
