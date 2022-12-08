# Mac mini 2012 as a NAS

This project aims to repurpose an old 2012 Mac mini as a Network Attached
Storage ([NAS](https://en.wikipedia.org/wiki/Network-attached_storage)) device.
NixOS was chosen as the operating system due to its ease of installation,
configuration, and the ability to create a live CD beforehand. This is not a
step-by-step guide, but rather an observational guide.

## Inspiration

Some blogs I recommend reading on the same subject.

- https://xeiaso.net/blog/my-homelab-nas-2021-11-29
- https://dataswamp.org/~solene/2020-10-18-nixos-nas.html
- https://www.codedbearder.com/posts/nixos-terramaster-f2-221/

### Why a mac

I already own a Mac mini from 2012 that has been off for a number of years.
Mac minis are known for their quietness, compactness, and the 2012 model can
be upgraded for more storage.

### What to do with a NAS

### Local NPM Cache

Working from home as a developer requires a lot of downloading. As a JavaScript
developer, I often use npm packages, and
[local-npm](https://github.com/local-npm/local-npm) is a great program for
caching npm packages, making downloads nearly instantaneous.

## Steps Summary

1. Unscrew Macmini and upgrade the harddrive to solid state
2. Create a liveCD, create a custom USB Installer with the wifi driver available
3. Tests the liveCD via QEMU
4. Install

## Step One - Replace the hard drive

There are a lot of tutorials on how to do this

- https://www.ifixit.com/Guide/Mac+mini+Late+2012+Hard+Drive+Replacement/11716
- https://www.imore.com/how-upgrade-2012-mac-mini

ifixit includes some tool requirements, I already own this
[https://www.amazon.co.uk/gp/product/B0189YWOIO](https://www.amazon.co.uk/gp/product/B0189YWOIO),
which included everything required.

The best tip I found was making a handle from tape
(https://youtu.be/BP3oPq1I-iQ?t=419) when reinserting the SSD drive.

![Open Mac mini with hard drive missing](https://user-images.githubusercontent.com/97810962/207371479-46ac5ca7-b272-42c9-934d-ec6c1bcdebbb.jpg)

## Step Two - Create a livecd

Nixos has an intuitive API for making livecd's.

[Creating a NixOS livecd](https://nixos.wiki/wiki/Creating_a_NixOS_live_CD)

Creating a USB installer that is custom for the Mac mini has the following
advantages:

- WIFI Broadcom drivers, can be included in the installer
- Can Install over SSH
    - Can set the username/password in the livecd
    - Enable WiFi in the livecd
- Installer can include any additional programs e.g. vim, git

To create an installer I used [QEMU](https://www.qemu.org/) running nixos in a
virtual machine.

### Running QEMU

- The `nixos.iso` is an iso from [Nixos Downloads](https://nixos.org/download.html)
- SSH is enabled, running `passwd` in the vm term to create a password may be
  required

```bash
qemu-system-x86_64 -enable-kvm -boot d \
    -nic user,model=virtio-net-pci,hostfwd=tcp::10022-:22 \
    -cdrom nixos.iso \
    -m 4G -smp 2
```

Cloning this git repository in the VM and navigating to the livecd folder, the
command I used to make the installer (this can be found on the above link):

```bash
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
```

After creating the `.iso` it can be put onto a USB to be installed onto the Mac
mini (using tools like [DD](https://wiki.archlinux.org/title/Dd) or `cp`

```bash
cp installer.iso /dev/sdX
```

#### Testing in QEMU

I tested the iso before directly running on the mac, this gave me the
opportunity to understand what to expect and also what to research before
hand.

The following will create an image to install nixos

```bash
qemu-img create -f qcow2 nixos.img 15g
```

After creating the above image, running the following command with the `iso`
retrieved from the VM:

```bash
qemu-system-x86_64 -enable-kvm -boot d \
    -nic user,model=virtio-net-pci,hostfwd=tcp::10022-:22 \
    -cdrom nixos-macmini-installer.iso \
    -m 4G -smp 2 -hda nixos.img
```

## Step Three - Install

The nixos manual has a great tutorial on how to install:

https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual

Regarding internet, if the iso.nix has not been edited the following commands
can be used to connect to wifi

https://wiki.archlinux.org/title/NetworkManager#nmcli_examples

I have opted for a encrypted drive, and followed this tutorial:

https://gist.github.com/walkermalling/23cf138432aee9d36cf59ff5b63a2a58

And also this command which was missing when retrieving the UUID

```bash
lsblk -o NAME,SIZE,MOUNTPOINT,UUID
```

To opt for a USB drive to decrypt to decrypt the LUKS drive:

- https://dataswamp.org/~solene/2020-10-18-nixos-nas.html
- https://nixos.wiki/wiki/Full_Disk_Encryption
