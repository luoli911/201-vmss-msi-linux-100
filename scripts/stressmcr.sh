#!/bin/bash
today=$(date +%Y-%m-%d)
sudo mkdir ~/logshare
sudo mount -t cifs //acrtestlogs.file.core.windows.net/logshare logshare -o vers=3.0,username=acrtestlogs,password=ZIisPCN0UrjLfhv6Njiz0Q8w9YizeQgIm6+DIfMtjak4RJrRlzJFn4EcwDUhNvXmmDv5Axw9yGePh3vn1ak8cg==,dir_mode=0777,file_mode=0777,sec=ntlmssp
sudo mkdir ~/logshare/$today

echo "---docker pull dotnet from mcr.microsoft.com---"
pullbegin=$(date +%s%3N)
PullStartTime=$(date +%H:%M:%S)
sudo docker pull mcr.microsoft.com/dotnet
pullend=$(date +%s%3N)
PullEndTime=$(date +%H:%M:%S)
pulltime=$((pullend-pullbegin))
echo "---nslookup mcr.microsoft.com---"
nslookup=$(nslookup mcr.microsoft.com)
echo registry,region,starttime,endtime,pulltime:mcr,eastus,$PullStartTime,$PullEndTime,$pulltime >> ~/logshare/$today/mcr-output.log
