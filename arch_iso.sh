#!/bin/bash

read -p 'System hostname                         : ' hostname

unset password
echo -ne 'Password for \e[1mroot\e[0m                       : '
while IFS= read -p "$prompt" -r -s -n 1 char
do
    # Enter - accept password
    if [[ $char == $'\0' ]] ; then
        break
    fi
    # Backspace
    if [[ $char == $'\177' ]] ; then
        prompt=$'\b \b'
        root_password="${password%?}"
    else
        prompt='*'
        root_password+="$char"
    fi
done
echo

read -p 'Username for new user                   : ' user_username

unset password
unset prompt
echo -n 'Password for new user                   : '
while IFS= read -p "$prompt" -r -s -n 1 char
do
    # Enter - accept password
    if [[ $char == $'\0' ]] ; then
        break
    fi
    # Backspace
    if [[ $char == $'\177' ]] ; then
        prompt=$'\b \b'
        user_password="${password%?}"
    else
        prompt='*'
        user_password+="$char"
    fi
done
echo

read -p 'IP-address/mask (e.g. 192.168.0.251/24) : ' ip_address_mask

read -p 'Gateway (Enter for default 192.168.0.1) : ' gateway
gateway=${gateway:-192.168.0.1}

read -p 'DNS (Enter for default 192.168.0.1)     : ' dns
dns=${dns:-192.168.0.1}

read -p 'HDD (Enter for default /dev/sda)        : ' hdd
hdd=${hdd:-/dev/sda}

set -o xtrace

echo -e "o\nn\np\n\n\n\nw" | fdisk $hdd
mkfs.ext4 "$hdd"1
mount "$hdd"1 /mnt/

yes | pacstrap -i /mnt base --noconfirm
genfstab -U -p /mnt >> /mnt/etc/fstab

wget ftp://<ftp_server>/arch_chroot.sh -P /mnt/
chmod +x /mnt/arch_chroot.sh

export hostname
export root_password
export user_username
export user_password
export ip_address_mask
export gateway
export dns
export hdd

arch-chroot /mnt ./arch_chroot.sh

rm /mnt/arch_chroot.sh

ip_address=${ip_address_mask%/*}

set +o xtrace
echo
echo -e "\e[91m1. EJECT INSTALLATION ISO.
2. START MACHINE.
3. CONNECT BY SSH: ssh $user_username@$ip_address\e[0m"
echo
set -o xtrace

# umount /mnt
/sbin/shutdown -h now
