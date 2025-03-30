Guix Installation

As of 2025-03-30, the install procedure is as follow:

- use system crafters iso installer
- run the installation, choose locale, keyboard, partition, etc.
- at the _configuration file_ step, press Ctrl-Alt-F3.
  ```bash
  herd start cow-store /mnt
  cp /etc/channels.scm /mnt/etc
  chmod +w /mnt/etc/channels.scm
  # Edit /mnt/etc/config.scm
  # import the following module: (nongnu packages linux)
  # After (operating-system, add:
  # (kernel linux)
  # (firmware (list linux-firmware))
  emacs /mnt/etc/config.scm
  ```
- run the installation with:
  ```bash
  guix time-machine -C /mnt/etc/channels.scm -- system init /mnt/etc/config.scm /mnt
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
