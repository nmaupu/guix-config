#!/bin/sh

curl https://substitutes.nonguix.org/signing-key.pub > /tmp/key.pub
guix archive --authorize < /tmp/key.pub

if ! mount | grep -q sys-docker; then
  cryptsetup luksOpen /dev/nvme0n1p2 crypt-root
  mount /dev/mapper/sys-root     /mnt
  mount /dev/nvme0n1p1           /mnt/boot/efi
  mount /dev/mapper/sys-docker   /mnt/var/lib/docker
  mount /dev/mapper/sys-home     /mnt/home
  mount /dev/mapper/sys-log      /mnt/var/log
  mount /dev/mapper/sys-gnustore /mnt/gnu/store
  swapon /dev/mapper/sys-swap
fi

herd start cow-store /mnt
cp /etc/channels.scm /mnt/etc/
guix system -L ~/guix-config init --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org" ~/guix-config/nmaupu/systems/${HOSTNAME}.scm /mnt
