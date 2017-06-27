#!/bin/bash

set -o xtrace

yes | pacman -S base-devel --noconfirm
yes | pacman -S core/grub core/openssh extra/wget extra/git community/firewalld

network_interface=$(ip -o -4 route show to default | awk '{print $5}')
cp /etc/netctl/examples/ethernet-static /etc/netctl/$network_interface
sed -i 's/eth0/'$network_interface'/g' /etc/netctl/$network_interface
sed -i "s~192.168.1.23\/24' '192.168.1.87\/24~"$ip_address_mask"~g" /etc/netctl/$network_interface
sed -i '0,/192.168.1.1/s/192.168.1.1/'$gateway'/g' /etc/netctl/$network_interface
sed -i '0,/192.168.1.1/s/192.168.1.1/'$dns'/g' /etc/netctl/$network_interface
netctl enable $network_interface

echo "root:$root_password" | chpasswd
useradd -m -g users -G wheel,storage,power -s /bin/bash $user_username
echo "$user_username:$user_password" | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

grub-install --target=i386-pc --recheck $hdd
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
systemctl enable sshd.service
mkdir /home/$user_username/.ssh
wget ftp://<ftp_server>/authorized_keys -P /home/$user_username/.ssh/

cp /etc/locale.gen /etc/locale.gen.original
sed -i '0,/en_US.UTF-8 UTF-8/! {0,/en_US.UTF-8 UTF-8/ s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/}' /etc/locale.gen
# sed -i '0,/en_US ISO-8859-1/! {0,/en_US ISO-8859-1/ s/#en_US ISO-8859-1/en_US ISO-8859-1/}' /etc/locale.gen
# sed -i 's/#ru_RU.KOI8-R KOI8-R/ru_RU.KOI8-R KOI8-R/g' /etc/locale.gen
# sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
# sed -i 's/#ru_RU ISO-8859-5/ru_RU ISO-8859-5/g' /etc/locale.gen
locale-gen

mv /etc/localtime /etc/localtime.original
ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.original
sed -i 's/#NTP=/NTP=0.ru.pool.ntp.org 1.ru.pool.ntp.org 2.ru.pool.ntp.org 3.ru.pool.ntp.org/g' /etc/systemd/timesyncd.conf
sed -i 's/^#FallbackNTP/FallbackNTP/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd.service

cp /etc/pacman.conf /etc/pacman.conf.original
sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf
awk '/#Include = \/etc\/pacman.d\/mirrorlist/{c++;if(c==4){sub("#Include = \\/etc\\/pacman.d\\/mirrorlist","Include = /etc/pacman.d/mirrorlist");c=0}}1' /etc/pacman.conf > pacman.tmp && mv pacman.tmp /etc/pacman.conf

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.original
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 4 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
sed -i '7,${/##/d;}' /etc/pacman.d/mirrorlist
sed -i -e '7i\\' /etc/pacman.d/mirrorlist
sed -i -e '8i Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sed -i -e '9i Server = https://mirror.yandex.ru/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sed -i -e '10i\\' /etc/pacman.d/mirrorlist

pacman -Sy
pacman-key --refresh-keys

fallocate -l 256M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
cp /etc/fstab /etc/fstab.original
cat >> /etc/fstab << EOF
/swapfile none swap defaults 0 0
EOF

cat >> /etc/hostname << EOF
$hostname
EOF

systemctl enable firewalld.service

exit
