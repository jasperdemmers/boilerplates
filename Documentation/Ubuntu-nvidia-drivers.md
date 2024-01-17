# Nvidia drivers installation

1) Find drivers   
Search for nvidia drivers using the `apt` command or `apt-get` command:
```bash
$ sudo apt search nvidia-driver
```
2) Apply pending updates  
Do not skip the following two commands, as you must apply all pending security updates:
```bash
$ sudo apt update
$ sudo apt upgrade
```
3) Installing Nvidia Drivers  
Install nvidia drivers with the latest version found from the search command. At this time, the latest version is 535:
```bash
$ sudo apt install nvidia-driver-535 nvidia-dkms-535
```
4) Reboot
At last reboot the system
```bash
$ sudo reboot
```

# Verification
Run `nvidia-smi` to see GPU info and processes that are using the nvidia GPU:
```bash
$ nvidia-smi
Tue Jan 16 14:31:52 2024
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.146.02             Driver Version: 535.146.02   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  Quadro P400                    Off | 00000000:06:10.0 Off |                  N/A |
| 34%   42C    P8              N/A /  N/A |      2MiB /  2048MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|  No running processes found                                                           |
+---------------------------------------------------------------------------------------+
```