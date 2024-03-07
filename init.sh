#!/bin/bash

# Get the current folder name
folder_name="$1"
env=$folder_name+"env"

python3 -m install pip virtualenv
apt install python3-pip python3-venv
cd $folder_name
python3 -m venv ./$env
source ./$env/bin/activate
apt update
pip3 install -r requirements.txt

#open file and replace the name with the folder name
cp ./name.service /usr/lib/systemd/system/$folder_name.service
sed -i "s/FOLDERNAME/$folder_name/g" /usr/lib/systemd/system/$folder_name.service
sed -i "s/ENV/$env/g" /usr/lib/systemd/system/$folder_name.service

ln -s /usr/lib/systemd/system/$folder_name.service /etc/systemd/system/$folder_name.service

service $folder_name start