### `config-add-sshkey.ansible.yaml`
```zsh
ansible-playbook Configuration/config-add-sshkey.ansible.yaml --ask-pass
```
If the following error appears:
```zsh
fatal: [worker10.aquabrain.lan]: FAILED! => {"msg": "to use the 'ssh' connection type with passwords or pkcs11_provider, you must install the sshpass program"}
```
Make sure to install sshpass:  
**Ubuntu/Debian**
```zsh
sudo apt-get install sshpass
```
**CentOS/Red Hat**
```zsh
sudo yum install sshpass
```
**MacOS (using Homebrew)**
```zsh
brew install hudochenkov/sshpass/sshpass
```