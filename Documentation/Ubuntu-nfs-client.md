# Use NFS on a Ubuntu client
This manual is for Ubuntu clients that need access to a NFSv3 server.

## Installation
1) **Update system and install NFS client**
```bash
$ sudo apt update
$ sudo apt install nfs-common
```
2) **Directory for NFS share**

To mount an NFS share, you first need to create a directory where you would like the NFS share to be accessible.  
For example, if you want to mount the shared drive under `/mnt/entertainment`, you would run:
```bash
$ sudo mkdir /mnt/entertainment
```
Then you would use the `mount` command to mount the share:
```bash
$ sudo mount -t nfs -o proto=tcp,port=2049 <NFS-SERVER-IP>:/path/to/share /mnt/nfs
```
Replace `<NFS-SERVER-IP>` and `/path/to/share` with the correct IP address and path to the NFS share on your NFS server.  
**Note:** This just mounts the share for the current session. It wont auto-mount after reboot.

3) **Making the NFS share permanently mounted (optional)**
If you want the NFS share to automatically mount on boot, you should add the following line into the `/etc/fstab` file:
```bash
<NFS-SERVER-IP>:/path/to/share /mnt/entertainment nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```
Replace `<NFS-SERVER-IP>` and `/path/to/share` with the correct IP address and path to the NFS share on your NFS server.  
When using `fstab` make sure to reboot.

4) **Testing your NFS mount**
You can use `df -h` or `mount -v` command to check if the NFS share is successfully mounted