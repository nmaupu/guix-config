#!/bin/sh

curl https://substitutes.nonguix.org/signing-key.pub > /tmp/key.pub
guix archive --authorize < /tmp/key.pub

herd start cow-store /mnt
cp /etc/channels.scm /mnt/etc/
guix system -L ~/guix-config init --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org" ~/guix-config/nmaupu/systems/${HOSTNAME}.scm /mnt
