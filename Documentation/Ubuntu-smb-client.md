# Use SMB on a Ubuntu client
This manual is for Ubuntu clients that need access to a samba share.

## Installation
1) **Update system and install cifs-utils**
```bash
$ sudo apt update
$ sudo apt install cifs-utils
```
2) **Directory for NFS share**

To mount an NFS share, you first need to create a directory where you would like the NFS share to be accessible.  
For example, if you want to mount the shared drive under `/mnt/entertainment`, you would run:
```bash
$ sudo mkdir /mnt/entertainment
```
Then you would use the `mount` command to mount the share:
```bash
$ sudo mount -t cifs //[smb-server-ip]/[sambashare] /path/to/share -o username=smbuser,password=smbpassword
```
Replace `/path/to/share`, `[smb-server-ip]` and `[sambashare]` with the correct IP address and path to the samba share on your samba server.  
**Note:** This just mounts the share for the current session. It wont auto-mount after reboot.

3) **Making the Samba share permanently mounted (optional)**
If you want the Samba share to automatically mount on boot, you can set up a credentials file and update the `/etc/fstab` file.  
First, create a credentials file (for example, `/etc/samba/credentials`):
```bash
$ sudo nano /etc/samba/credentials
```
In this file, add two lines (replacing `smbuser` and `smbpassword` with your Sambe username and password):
```
username=smbuser
password=smbpassword
```
Save and close the file, then change its permissions so only root can access it:
```bash
$ sudo chown root /etc/samba/credentials
$ sudo chmod 600 /etc/samba/credentials
```
Then, add a line in `/etc/fstab` for your Samba share:
```bash
//[smb-server-ip]/[sambashare] /path/to/share cifs credentials=/etc/samba/credentials,iocharset=utf8 0 0
```
Replace `/path/to/share`, `[smb-server-ip]` and `[sambashare]` with the correct IP address and path to the samba share on your samba server.  

4) **Testing your Samba mount**
You can use `df -h` or `mount -v` command to check if the NFS share is successfully mounted