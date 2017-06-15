# Arch-Linux
Arch Linux installation scripts

This instruction describes complete installation of Arch Linux using bash-scripts.

1. upload both `arch_iso.sh` and `arch_chroot.sh` scrips to FTP-server;
2. download the official installation image from https://www.archlinux.org/download/ ;
3. boot the live system from image;
4. set temporary password for root, start ssh service and find IP-address:
```
# echo "root:<password>" | chpasswd
# systemctl start sshd.service
# ifconfig
```
5. download `arch_iso.sh` script from FTP-server, set permissions to run script and run it:
```
wget ftp://<ftp_server>/arch_iso.sh -P ~/
chmod +x ~/arch_iso.sh
~/arch_iso.sh
```
6.
