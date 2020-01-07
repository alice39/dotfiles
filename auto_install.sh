#!/bin/bash

help() {
    echo "Usage: auto_install.sh [-d|--disk <disk>] [-p|--partition-table <mbr/gpt>] [-l|--use-lvm] [-h|--hostname <hostname>] [-z|--use-zen] [--dotfiles <?url>] [-u|--username <username>] [-t|--timezone <timezone>]"
    echo "Disk: The disk to install Arch Linux on. WILL BE WIPED COMPLETELY."
    echo "Partition table: The partition table format to use. If unsure, choose gpt."
    echo "LVM: Use LVM with the new installation."
    echo "Hostname: The hostname for the new pc."
    echo "Zen: Use the Zen kernel in the new pc."
    echo "Dotfiles: The Dotfiles repo. Must have the same install.py format as https://github.com/eyedevelop/dotfiles"
    echo "Username: The username for the new system."
    exit 0
}

round() {
    python -c "import math;import sys;sys.stdout.write(str(math.ceil($1)))"
}

calculate_swap() {
    memsize=$(free -h | grep Mem | awk '{print $2}' | sed 's/[A-Za-z]//g')
    memsize=$(round "$memsize")
    memsize=$((memsize*1024+512))

    echo -n "$memsize"
}

partition_mbr_nlvm() {
    parted --script "$DISK" mklabel msdos
    parted --script "$DISK" mkpart primary 1MiB 500MiB
    parted --script "$DISK" set 1 boot on

    memsize=$(calculate_swap)

    parted --script "$DISK" mkpart primary 500MiB "${memsize}MiB"
    parted --script "$DISK" mkpart primary "${memsize}MiB" 100%
}

partition_mbr_lvm() {
    parted --script "$DISK" mklabel msdos
    parted --script "$DISK" mkpart primary 1MiB 500MiB
    parted --script "$DISK" set 1 boot on
    parted --script "$DISK" mkpart primary 500MiB 100%

    (pvcreate "${DISK}p2" || pvcreate "${DISK}2") || (echo "Cannot partition disk." && exit 1)
    vgcreate arch-vg "${DISK}p2" || vgcreate arch-vg "${DISK}2"

    memsize=$(calculate_swap)
    memsize=$((memsize-512))
    lvcreate -L "${memsize}M" -n swap arch-vg
    lvcreate -l 100%FREE -n root arch-vg
}

format_lvm() {
    mkfs.ext4 "${DISK}p1" || mkfs.ext4 "${DISK}1"
    mkswap /dev/mapper/arch-vg-swap
    mkfs.ext4 /dev/mapper/arch-vg-root
}

format_nlvm() {
    mkfs.ext4 "${DISK}p1" || mkfs.ext4 "${DISK}1"
    mkswap "${DISK}p2" || mkswap "${DISK}2"
    mkfs.ext4 "${DISK}p3" || mkfs.ext4 "${DISK}3"
}

partition_gpt_nlvm() {
    parted --script "$DISK" mklabel gpt
    parted --script "$DISK" mkpart primary 1MiB 500MiB
    parted --script "$DISK" set 1 esp on

    memsize=$(calculate_swap)

    parted --script "$DISK" mkpart primary 500MiB "${memsize}MiB"
    parted --script "$DISK" mkpart primary "${memsize}MiB" 100%
}

partition_gpt_lvm() {
    parted --script "$DISK" mklabel gpt
    parted --script "$DISK" mkpart primary 1MiB 500MiB
    parted --script "$DISK" set 1 esp on
    parted --script "$DISK" mkpart primary 500MiB 100%

    (pvcreate "${DISK}p2" || pvcreate "${DISK}2") || (echo "Cannot partition disk." && exit 1)
    vgcreate arch-vg "${DISK}p2" || vgcreate arch-vg "${DISK}2"

    memsize=$(calculate_swap)
    memsize=$((memsize-512))
    lvcreate -L "${memsize}M" -n swap arch-vg
    lvcreate -l 100%FREE -n root arch-vg
}

mount_lvm() {
    mount /dev/mapper/arch-vg-root /mnt
    mkdir -p /mnt/boot
    mount "${DISK}p1" /mnt/boot || mount "${DISK}1" /mnt/boot
    swapon /dev/mapper/arch-vg-swap
}

mount_nlvm() {
    mount "${DISK}p3" /mnt || mount "${DISK}3" /mnt
    mkdir -p /mnt/boot
    mount "${DISK}p1" /mnt/boot || mount "${DISK}1" /mnt/boot
    swapon "${DISK}p2" || swapon "${DISK}2"
}

install_main() {
    if [[ "$ZEN" -eq 1 ]]; then
        KERNEL="linux-zen linux-zen-headers dkms"
    else
        KERNEL="linux linux-headers"
    fi

    pacstrap --confirm -i /mnt base base-devel networkmanager "$KERNEL"
    genfstab -U /mnt > /mnt/etc/fstab

    if [[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
        TIMEZONE="Europe/Amsterdam"
    fi

    arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    arch-chroot /mnt hwclock --systohc
    arch-chroot /mnt sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
    arch-chroot /mnt locale-gen && echo -e "LANG=en_GB.UTF-8\nLANGUAGE=en_US.UTF-8" > /etc/locale.conf
    arch-chroot /mnt echo "$HOSTNAME" > /etc/hostname
    arch-chroot /mnt cat << EOF > /etc/hosts
127.0.0.1 localhost localhost.localdomain
::1 localhost localhost.localdomain
127.0.1.1 $HOSTNAME $HOSTNAME.localdomain
EOF

    if [[ "$LVM" -eq 1 ]]; then
        arch-chroot /mnt sed -i 's/block filesystems/block lvm2 filesystems/g' /etc/mkinitcpio.conf
        arch-chroot /mnt mkinitcpio -p "$(ls /etc/mkinitcpio.d/ | sed 's/.preset//g')"
    fi

    arch-chroot /mnt sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
    arch-chroot /mnt useradd -m -G wheel "$USERNAME"
    arch-chroot /mnt passwd "$USERNAME"
}

bootloader_mbr() {
    arch-chroot /mnt pacman -S --confirm grub
    arch-chroot /mnt grub-install "$DISK"
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

bootloader_gpt() {
    arch-chroot /mnt pacman -S --confirm refind-efi
    arch-chroot /mnt refind-install
}

# Switch cli options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--disk)
        DISK="$2"
        shift
        shift
        ;;

        -p|--partition-table)
        FORMAT="$2"
        shift
        shift
        ;;

        -l|--use-lvm)
        LVM=1
        shift
        shift
        ;;

        -h|--hostname)
        HOSTNAME="$2"
        shift
        shift
        ;;

        -z|--use-zen)
        ZEN=1
        shift
        shift
        ;;

        --dotfiles)
        if [[ -z "$2" ]]; then
            DOTFILES=1
            DOTFILES_URL="https://github.com/eyedevelop/dotfiles"
        else
            DOTFILES=1
            DOTFILES_URL="$2"
        fi
        shift
        shift
        ;;

        -u|--username)
        USERNAME="$2"
        shift
        shift
        ;;

        -t|--timezone)
        TIMEZONE="$2"
        shift
        shift
        ;;

        --help)
        help
        shift
        shift
        ;;

        *)
        echo "Unknown command line argument."
        help
        ;;
    esac
done

# Parse commandline arguments.
if [[ -z "$DISK" || -z "$FORMAT" || -z "$HOSTNAME" || -z "$USERNAME" ]]; then
    echo "The following arguments are required:"
    echo "Disk, Partition table, Hostname, Username."
    exit 1
fi

if [[ "$FORMAT" != "gpt" && "$FORMAT" != "mbr" ]]; then
    echo "Partition table must either be 'gpt' or 'mbr'."
    exit 1
fi

if [[ $(ls "$DISK" >/dev/null 2>&1) ]]; then
    echo "The chosen disk does not exist."
    exit 1
fi

# Ask for user consent.
echo "WARNING: ALL DATA ON DISK $DISK WILL BE DELETED."
echo -n 'DO YOU WISH TO CONTINUE (y|N): '
read -r consent

if [[ "$consent" != "y" ]]; then
    echo "User did not give consent."
    exit 1
fi

# Check internet
if [[ ! $(ping 1.1.1.1) && ! $(ping 8.8.8.8) ]]; then
    echo "Please connect to the internet before you run this script."
    exit 1
fi

# Format the disk
if [[ "$FORMAT" == "gpt" ]]; then
    if [[ "$LVM" -eq 1 ]]; then
        partition_gpt_lvm
        format_lvm
        mount_lvm
    else
        partition_gpt_nlvm
        format_nlvm
        mount_nlvm
    fi
else
    if [[ "$LVM" -eq 1 ]]; then
        partition_mbr_lvm
        format_lvm
        mount_lvm
    else
        partition_mbr_nlvm
        format_nlvm
        mount_nlvm
    fi
fi

# Run the install.
install_main

# Install the bootloader.
if [[ "$FORMAT" == "gpt" ]]; then
    bootloader_gpt
else
    bootloader_mbr
fi

echo -e '\n\nDone!!'
