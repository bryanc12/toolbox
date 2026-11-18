# A Step-By-Step Flow For Provisioning SSH on Fresh Installed or Deployed Ubuntu 26.04 LTS
Adding keys and disable password login.

## Adding public key to the server
1. Generate SSH key pair on your computer. Ed25519 Recommended and safe enough. In OpenSSH format. \
`ssh-keygen -t ed25519`

2. Check if the `~/.ssh/authorized_keys` exists. If don't create it.

- Create the `~/.ssh` folder for the current user. \
`mkdir -p ~/.ssh`

- The permission for the ssh folder and public key file. \
`chmod 700 ~/.ssh`
`chmod 600 ~/.ssh/authorized_keys`

3. Append the public key to the `authorized_keys`. \
The key should be something like this `ssh-ed25519 AAAA...1234`, a 64 characters of hex.

4. Restart the ssh server. \
`sudo systemctl restart ssh`

## Disable password login
1. Get into the ssh configurations folder. \
`cd /etc/ssh`

2. List the configuration files and folders. And take note we are working on files and folders of `sshd`. Which is the SSH Daemon, the SSH Server. \
`ls`

The output should be something like this: \
`moduli` `ssh_host_ecdsa_key` `ssh_host_ed25519_key.pub` `ssh_import_id` `ssh_config` `ssh_host_ecdsa_key.pub` `ssh_host_rsa_key` `sshd_config` `ssh_config.d` `ssh_host_ed25519_key` `ssh_host_rsa_key.pub` `sshd_config.d` \

So in this case we will be focusing on the `sshd_config` file and the `/sshd_config.d` folder.

3. Look for `PubkeyAuthentication yes` in every files(in folders too). \
Starting from `/sshd_config.d` folder is recommended, usually cloud providers inject the configuration to enable password login here. \
Using the command `nano` text editor to inspect and edit. \
`sudo nano sshd_config` or \
`sudo nano sshd_config.d/50-cloud-init.conf` or \
`sudo nano sshd_config.d/60-cloudimg-settings.conf` \

Use these keyboard keys to work with `nano` text editor: \
`Ctrl + S` - Save \
`Ctrl + X` - Exit \
`Arrow Up` and `Arrow Down` - Scroll

5. Update the `PubkeyAuthentication yes` to `PubkeyAuthentication no` for every lines found.

6. Restart the SSH Server with `sudo systemctl restart ssh`.

7. **DON'T CLOSE THE CURRENT SSH CONNECTION FIRST!** \
Open another ssh connection session to check if able to connect to it before closing the current connection. Or else you will be locked out from the server.
