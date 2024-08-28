# Open AMT Cloud Toolkit MPS Auto Setup Tool


### [How to use]


####  On the MPS server (development system):
  - Run `./openAMT.sh` as non-root user
  - Enter IP address
  - Log in the Sample Web UI (Username=`admin`, Password=`P@ssw0rd`)
  - Add CIRA configs
  - Add Profiles (CCM)

#### On the client (AMT device):
 + Run `sudo snap install lms`
 + Downlaod and copy RPC tool to the $HOME directory 
 + Run RPC activate commands depending on DHCP or Static IP network
##


### [Test environment]
Ubuntu 22.04 LTS

##
### 
#### Tutorial
https://open-amt-cloud-toolkit.github.io/docs/2.25/GetStarted/prerequisites/

#### Download RPC tool
https://github.com/open-amt-cloud-toolkit/rpc-go/releases

