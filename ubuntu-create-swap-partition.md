# Creating Swap Space on Ubuntu 26.04 LTS 

1. Check if swap space already exists on the system \
`sudo swapon --show` \
`df -h /` 

2. Allocate 5 gigs of storage for swap \
`sudo fallocate -l 5G /swapfile`

3. Change permission to only allow read and write from root \
`sudo chmod 600 /swapfile`

4. Configure the folder as swap space, and enable it \
`sudo mkswap /swapfile`
`sudo swapon /swapfile`

5. Make the swap space permanent, apply on every startup or reboot \
- Backup the default file system table \
`sudo cp /etc/fstab /etc/fstab.bak` \
- Append the swap configuration to the table \
`echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab`

6. Verify swap space \
`free -h`
