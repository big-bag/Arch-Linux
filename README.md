# Arch-Linux
Arch Linux installation scripts

This instruction describes complete installation of Arch Linux using bash-scripts.

1. upload both `arch_iso.sh` and `arch_chroot.sh` scrips to FTP-server;
2. download the [official installation image](https://www.archlinux.org/download/);
3. boot the live system from image;
4. set temporary password for root, start ssh service and find IP-address:
```
# echo "root:<password>" | chpasswd
# systemctl start sshd.service
# ifconfig
```
5. connect to live system by ssh (e.g., using PuTTY);
6. download `arch_iso.sh` script from FTP-server, set permissions and run it:
```
# wget ftp://<ftp_server>/arch_iso.sh -P ~/
# chmod +x ~/arch_iso.sh
# ~/arch_iso.sh
```
7. enter information for further system setup. Type `Enter` for three last question. Default parameters are set in `arch_iso.sh` script:
```
System hostname                         : ARCH_VM
Password for root                       : ********
Username for new user                   : username
Password for new user                   : ********
IP-address/mask (e.g. 192.168.0.251/24) : 192.168.0.10/24
Gateway (Enter for default 192.168.0.1) :
DNS (Enter for default 192.168.0.1)     :
HDD (Enter for default /dev/sda)        :
```
8. after the installation is completed, a message will be displayed:
```
1. EJECT INSTALLATION ISO.
2. START MACHINE.
3. CONNECT BY SSH: ssh username@192.168.0.10
```
9. enable [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) under `username` account:
```
git clone https://aur.archlinux.org/package-query.git
cd package-query
yes | makepkg -si
cd ..

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
yes | makepkg -si
cd ..

rm -rf package-query/
rm -rf yaourt/
```
