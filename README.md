# Open AMT Cloud Toolkit MPS Auto Setup Tool


### [How to use]


####  On the MPS server (development system):
  - Copy `openAMT.sh` and `MPS_config` folder to the $HOME directory 
  - Run `./openAMT.sh` as non-root user
  - Enter the correct IP4 address
  - Log in the Sample Web UI (Username=`admin`, Password=`P@ssw0rd`)
  - Add CIRA configs
  - Add Profiles (CCM)

#### On the client (AMT device):
 + Run `sudo snap install lms`
 + Downlaod and copy RPC tool to the $HOME directory 
 + Run `sudo ./rpc activate -u wss://{Server's IP}/activate -n -profile {CCM profile name}` 
 + Run `sudo ./rpc amtinfo` to check status
##


### [Test environment]
Ubuntu 22.04 LTS

##
### 
#### Tutorial
https://open-amt-cloud-toolkit.github.io/docs/2.25/GetStarted/prerequisites/

#### Download RPC tool
https://github.com/open-amt-cloud-toolkit/rpc-go/releases

