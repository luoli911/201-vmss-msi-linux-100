#!/bin/bash
#startuptime1=$(date +%s%3N)

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
machineName=$(hostname)
sudo mkdir /mnt/azurefiles
sudo mount -t cifs //acrtestlogs.file.core.windows.net/logshare /mnt/azurefiles -o vers=3.0,username=acrtestlogs,password=ZIisPCN0UrjLfhv6Njiz0Q8w9YizeQgIm6+DIfMtjak4RJrRlzJFn4EcwDUhNvXmmDv5Axw9yGePh3vn1ak8cg==,dir_mode=0777,file_mode=0777,sec=ntlmssp
sudo mkdir /mnt/azurefiles/$today
sudo mkdir /mnt/azurefiles/$today/$machineName

sudo systemctl stop docker
sudo mkdir /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/docker.conf
echo -e [Service]\\nExecStart=\\nExecStart=/usr/bin/dockerd --graph=\"/mnt/new_volume\" --storage-driver=aufs |sudo tee /etc/systemd/system/docker.service.d/docker.conf
sudo systemctl daemon-reload
sudo systemctl start docker

sleep 5
#startuptime2=$(date +%s%3N)
#sleeptime=$((600-(startuptime2-startuptime1)/1000))
#sleep $sleeptime

echo "---docker pull dotnet from eus.mcr.microsoft.com---"
pullbegin=$(date +%s%3N)
PullStartTime=$(date +%H:%M:%S)
sudo docker pull eus.mcr.microsoft.com/dotnet
pullend=$(date +%s%3N)
PullEndTime=$(date +%H:%M:%S)
pulltime=$((pullend-pullbegin))
echo "---nslookup eus.mcr.microsoft.com---"
nslookup=$(nslookup eus.mcr.microsoft.com)
echo registry,region,starttime,endtime,pulltime:eus.mcr.microsoft.com,eastus,$PullStartTime,$PullEndTime,$pulltime >> /mnt/azurefiles/$today/$machineName/mcr-output.log
echo $nslookup >> /mnt/azurefiles/$today/$machineName/mcr-output.log

echo "---Sort out Logs---"
filePath="/mnt/azurefiles/$today/"

function getAllFiles()
{
fileList=`ls $filePath`
for fileName in $fileList
    do
      if [ -f $fileName ];then
          echo `find $filePath|xargs grep -ri "pulltime"` >> /mnt/azurefiles/$today/mcr-output-all.log
      elif test -d $fileName; then
          cd $fileName
          filePath=`pwd`
          getAllFiles
          cd ..
       else
          echo "$filePath is a invalid path"
       fi
     done
}

cd $filePath
getAllFiles
echo "DONE"
