#!/bin/bash

# Get the current folder name
folder_name="$1"
env=$folder_name"env"

echo "Deactivating service from previous installation..."
service $folder_name stop
systemctl disable $folder_name

echo "Removing service file from previous installation..."
rm /usr/lib/systemd/system/$folder_name.service
rm /etc/systemd/system/$folder_name.service

python3 -m install pip virtualenv
apt update
apt install -y python3-pip python3-venv
python3 -m venv ./$env
source ./$env/bin/activate

echo "Installing pipreqs..."
pip3 install pipreqs

#if requirements.txt is not present, create it
if [ -f "requirements.txt" ]; then
    echo "Installing requirements from requirements.txt..."
    pip3 install -r requirements.txt
else
    echo "Generating requirements.txt..."
    pipreqs . ---ignore bin,etc,include,lib,lib64 # experimental
    pip3 install -r requirements.txt
fi

echo "Configuring service..."
cp ./name.service /usr/lib/systemd/system/$folder_name.service
sed -i "s/FOLDERNAME/$folder_name/g" /usr/lib/systemd/system/$folder_name.service
sed -i "s/ENV/$env/g" /usr/lib/systemd/system/$folder_name.service

ln -s /usr/lib/systemd/system/$folder_name.service /etc/systemd/system/$folder_name.service

echo "Starting service..."
service $folder_name start
systemctl enable $folder_name