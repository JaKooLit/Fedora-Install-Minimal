#!/bin/bash

udevadm trigger

mkdir -p /mnt/{proc,sys,dev,/pts}

mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -B /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts

source /etc/os-release
export VERSION_ID="$VERSION_ID"
dnf --installroot=/mnt --releasever=$VERSION_ID groupinstall -y core
dnf --installroot=/mnt install -y glibc-langpack-en
mv /mnt/etc/resolv.conf /mnt/etc/resolv.conf.orig
cp -L /etc/resolv.conf /mnt/etc

# for genfstab arch tools
dnf install -y arch-install-scripts
genfstab -U /mnt >> /mnt/etc/fstab

# Enter the chroot environment and execute subsequent commands
chroot /mnt /bin/bash <<EOF

# Commands to run within the chroot environment
mount -a
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
fixfiles -F onboot

# Initial install
dnf install -y btrfs-progs efi-filesystem efibootmgr fwupd grub2-common grub2-efi-ia32 grub2-pc grub2-pc-modules grub2-tools grub2-tools-efi grub2-tools-extra grub2-tools-minimal grubby kernel mactel-boot mokutil shim-ia32 shim-x64

EOF




