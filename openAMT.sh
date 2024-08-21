#!/usr/bin/env bash


# CREATOR: mike.lu@hp.com
# CHANGE DATE: 2024/8/21
__version__="1.0"


# Tutorial
# https://open-amt-cloud-toolkit.github.io/docs/2.25/GetStarted/prerequisites/

# Download RPC tool
# https://github.com/open-amt-cloud-toolkit/rpc-go/releases


# How To Use
# On the MPS server (development system):
#   1) Copy openAMT.sh and MPS_config folder to the $HOME directory 
#   2) Run `./openAMT.sh` as non-root user
#   3) Enter the correct IP4 address
#   4) Log in the Sample Web UI (Username=admin, Password=P@ssw0rd)
#   5) Add CIRA configs
#   6) Add Profiles (CCM)

# On the client (AMT device):
#   1) Run `sudo snap install lms`
#   2) Downlaod and copy RPC tool to the $HOME directory 
#   3) Run `sudo ./rpc activate -u wss://{Server's IP}/activate -n -profile {CCM profile name}` 
#   4) Run `sudo ./rpc amtinfo` to check status



# Restrict user account
[[ $EUID == 0 ]] && echo -e "⚠️ Please run as non-root user.\n" && exit


# Ensure Internet is connected
! nslookup google.com > /dev/null && echo "❌ No Internet connection! Please check your network" && exit
! dpkg -l | grep -w ca-certificates > /dev/null && sudo apt update && sudo apt install ca-certificates -y
[[ ! -f /usr/bin/curl ]] && sudo apt update && sudo apt install curl -y
[[ ! -f /usr/bin/git ]] && sudo apt update && sudo apt install git -y
# sudo snap install go --classic


# Check the update and download MPS Config
Update_script() {
    release_url=https://api.github.com/repos/DreamCasterX/OpenAMT-mps-setup/releases/latest
    new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    release_note=$(curl -s "${release_url}" | grep '"body":' | awk -F\" '{print $4}')
    tarball_url="https://github.com/DreamCasterX/OpenAMT-mps-setup/archive/refs/tags/${new_version}.tar.gz"
    if [[ $new_version != $__version__ ]]; then
        echo -e "⭐️ New version found!\n\nVersion: $new_version\nRelease note:\n$release_note"
        sleep 2
        echo -e "\nDownloading update..."
        pushd "$PWD" > /dev/null 2>&1
        curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".OpenAMT-mps-setup.tar.gz" "${tarball_url}"
        if [[ -e ".OpenAMT-mps-setup.tar.gz" ]]; then
	    tar -xf .OpenAMT-mps-setup.tar.gz -C "$PWD" --strip-components 1 > /dev/null 2>&1
	    rm -f .OpenAMT-mps-setup.tar.gz
            rm -f README.md
            popd > /dev/null 2>&1
            sleep 3
            sudo chmod 755 openAMT.sh
            echo -e "Successfully updated! Please run openAMT.sh again.\n\n" ; exit 1
        else
            echo -e "\n❌ Error occurred while downloading" ; exit 1
        fi 
    else
        if [[ ! -d ./MPS_config ]]; then
            echo -e "\nDownloading MPS Config....\n"
            pushd "$PWD" > /dev/null 2>&1
            wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".OpenAMT-mps-setup.tar.gz" "${tarball_url}"
            if [[ -e ".OpenAMT-mps-setup.tar.gz" ]]; then
	        tar -xf .OpenAMT-mps-setup.tar.gz -C "$PWD" --strip-components 1 OpenAMT-mps-setup-$new_version/MPS_config > /dev/null 2>&1
                rm -f .OpenAMT-mps-setup.tar.gz
                popd > /dev/null 2>&1
                sleep 3
                sudo chmod 755 -R ./MPS_config
                echo -e "\e[32mDone!\e[0m"
            else
                echo -e "\n\e[31mDownload MPS config failed.\e[0m" ; exit 1
            fi	
        fi		
    fi
}
Update_script


# Set IP to env file
[[ ! -f ./MPS_config/env.HP ]] && echo "❌ Env file is not found in MPS Config folder!" && exit
read -p 'Enter IP address: ' IP
sed -i '15s/.*/MPS_COMMON_NAME='$(echo $IP)'/g' ./MPS_config/env.HP


Install_docker() {	
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER && sudo chmod a+rw /var/run/docker.sock
}
Install_docker


# Download Toolkit and set environment
git clone https://github.com/open-amt-cloud-toolkit/open-amt-cloud-toolkit --branch v2.25.0 --recursive
[[ -d ./open-amt-cloud-toolkit ]] && cp ./MPS_config/env.HP ./open-amt-cloud-toolkit/.env
[[ -d ./open-amt-cloud-toolkit ]] && cp ./MPS_config/kong.yaml.HP ./open-amt-cloud-toolkit/kong.yaml
[[ -d ./open-amt-cloud-toolkit ]] && cp ./MPS_config/docker-compose.yml.HP ./open-amt-cloud-toolkit/docker-compose.yml


# Run container
cd ./open-amt-cloud-toolkit
sudo docker compose pull
sudo docker compose up -d
sudo docker ps --format "table {{.Image}}\t{{.Status}}\t{{.Names}}"


# Open browser
firefox https://$IP


# Rebuild the contaniner & image
# sudo docker compose down -v && sudo docker system prune -a --volumes


# ===========================[For reference ]===============================
# Activate
# sudo ./rpc activate -u wss://10.1.1.1/activate -n -profile myCCM

# Deactivate 
# sudo ./rpc deactivate -u wss://10.1.1.1/activate -n -password P@ssw0rd

# Get RPS log (from MPS server)
# sudo docker logs {RPS container ID} > rps.log 2>&1

# Get RPC log (from client - manually save the output to rpc.log)
# sudo ./rpc activate -u wss://10.1.1.1/activate -n -profile myCCM -v  

# Change NIC Mac address
# sudo ifconfig eno1 hw ether 0c:72:5c:0f:80:73


