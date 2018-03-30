#!/bin/bash

while getopts ":i:a:c:r:" opt; do
  case $opt in
    i) docker_image="$OPTARG"
    ;;
    a) storage_account="$OPTARG"
    ;;
    c) container_name="$OPTARG"
    ;;
    r) resource_group="$OPTARG"
    ;;
    p) port="$OPTARG"
    ;;
    t) script_file="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z $docker_image ]; then
    docker_image="azuresdk/azure-cli-python:latest"
fi

if [ -z $script_file ]; then
    script_file="writeblob.sh"
fi

for var in storage_account resource_group
do

    if [ -z ${!var} ]; then
        echo "Argument $var is not set" >&2
        exit 1
    fi 

done

# Install Docker and then run docker image with cli

sudo apt-get -y update
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce

sudo apt-get -y update
sudo apt-get install cifs-utils


today=$(date +%Y-%m-%d)
sudo mkdir /mnt/azurefiles
sudo mount -t cifs //acrtestlogs.file.core.windows.net/logshare /mnt/azurefiles -o vers=3.0,username=acrtestlogs,password=ZIisPCN0UrjLfhv6Njiz0Q8w9YizeQgIm6+DIfMtjak4RJrRlzJFn4EcwDUhNvXmmDv5Axw9yGePh3vn1ak8cg==,dir_mode=0777,file_mode=0777,sec=ntlmssp
sudo mkdir /mnt/azurefiles/$today

echo "---docker pull dotnet from wus.mcr.microsoft.com---"
pullbegin=$(date +%s%3N)
PullStartTime=$(date +%H:%M:%S)
sudo docker pull wus.mcr.microsoft.com/dotnet
pullend=$(date +%s%3N)
PullEndTime=$(date +%H:%M:%S)
pulltime=$((pullend-pullbegin))
echo "---nslookup wus.mcr.microsoft.com---"
nslookup=$(nslookup wus.mcr.microsoft.com)
echo registry,region,starttime,endtime,pulltime:mcr,westus,$PullStartTime,$PullEndTime,$pulltime >> /mnt/azurefiles/$today/mcr-output.log
echo $nslookup >> /mnt/azurefiles/$today/mcr-output.log