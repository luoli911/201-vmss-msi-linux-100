#!/bin/bash
today=$(date +%Y-%m-%d)
#sudo mkdir ~/logshare
sudo mkdir /mnt/azurefiles/$today

echo "---docker pull dotnet from mcr.microsoft.com---"
pullbegin=$(date +%s%3N)
PullStartTime=$(date +%H:%M:%S)
sudo docker pull mcr.microsoft.com/dotnet
pullend=$(date +%s%3N)
PullEndTime=$(date +%H:%M:%S)
pulltime=$((pullend-pullbegin))
echo "---nslookup mcr.microsoft.com---"
nslookup=$(nslookup mcr.microsoft.com)
echo registry,region,starttime,endtime,pulltime:mcr,eastus,$PullStartTime,$PullEndTime,$pulltime >> /mnt/azurefiles/$today/mcr-output.log
