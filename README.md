Guix Installation

As of 2025-03-30, the install procedure is as follow:

- use system crafters iso installer
- run the installation, choose locale, keyboard, etc.
- at the _partition step_, press Ctrl-Alt-F3 to open a new shell
- Partition the disk like so (cfdisk):

  - /dev/nvme0n1p1: EFI (512M)
  - /dev/nvme0n1p2: Linux (remaining)

- Configure luks2 on /dev/nvme0n1p2

``` bash
cryptsetup luksFormat --type luks2 --pbkdf pbkdf2 /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 crypt-root
```

- Now, create LVM layer like so:

```bash
pvcreate /dev/nvme0n1p2
vgcreate sys /dev/nvme0n1p2
lvcreate -L50G  -n root     sys
lvcreate -L100G -n docker   sys
lvcreate -L100G -n gnustore sys
lvcreate -L200G -n home     sys
lvcreate -L20G  -n log      sys
lvcreate -L32G  -n swap     sys
```

- Format all the partitions:

```bash
mkfs.xfs /dev/mapper/sys-root
mkfs.xfs /dev/mapper/sys-docker
mkfs.xfs /dev/mapper/sys-gnustore
mkfs.xfs /dev/mapper/sys-home
mkfs.xfs /dev/mapper/sys-log
mkswap   /dev/mapper/sys-swap
mkfs.vfat /dev/nvme0n1p1
```

- Once created, mount all filesystems:

```bash
mount /dev/mapper/sys-root /mnt
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
mkdir -p /mnt/var/lib/docker
mkdir -p /mnt/var/log
mkdir -p /mnt/gnu/store
mount /dev/mapper/sys-docker /mnt/var/lib/docker
mount /dev/mapper/sys-gnustore /mnt/gnu/store
mount /dev/mapper/sys-home /mnt/home
mount /dev/mapper/sys-log /mnt/var/log
mount /dev/nvme0n1p1 /mnt/boot/efi
swapon /dev/mapper/sys-swap # Even if I am not sure this is useful
```

- git pull this very repo

```bash
git clone https://github.com/nmaupu/guix-config
```

- Start the installation with the following commands: (see also `install.sh` at the root of the repository)

```bash
herd start cow-store /mnt
cp /etc/channels.scm /mnt/etc
chmod +w /mnt/etc/channels.scm
guix time-machine -C /mnt/etc/channels.scm -- guix system -L ~/guix-config init --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org" ~/guix-config/nmaupu/systems/${HOSTNAME}.scm /mnt
```

Now, it may take up to 30 minutes to install everything. If installation hangs, ctrl+c and re-run last command.

When finished, reboot.

- Now, switch to a new TTY and login as root (with no password).
- Change the root password
- Change the user password
- Switch back to graphical with Ctrl-Alt-F7 and login
- Configure network
- Open a terminal

```bash
guix install git
git clone https://github.com/nmaupu/guix-config.git ~/.dotfiles
mkdir -p ~/.config/guix
cp ~/.dotfiles/.install/channels.scm ~/.config/guix
guix pull #wait several minutes
```

Create a new _systems_ file for this new system if not already existing.
This new system file has to combine the information from `/etc/config.scm` file (created during the installation) and the base one to inherit from.

Once it's done, run the following command to update the system:

``` bash
sudo guix system -L ~/.dotfiles reconfigure ~/.dotfiles/nmaupu/systems/$(hostname).scm \
  --substitute-urls='https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org'
```

Reboot.

Finally, home user can be installed with:

``` bash
~/.dotfiles/nmaupu/files/guix/.bin/update-home
```
