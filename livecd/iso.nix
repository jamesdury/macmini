# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.
{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  boot = {
    initrd.availableKernelModules = [
      "ohci_pci"
      "ehci_pci"
      "ahci"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
      "sdhci_pci"
    ];

    initrd.kernelModules = [ ];

    kernelModules = [
      "kvm-intel"
      "wl"
      # https://github.com/torvalds/linux/blob/master/drivers/hwmon/applesmc.c
      # this is really not necessary, but have put it in anyway as its for mac
      # it wouldnt even be required for the NAS
      "applesmc"
    ];
    extraModulePackages = [
      # install broadcom driver for macos wifi
      config.boot.kernelPackages.broadcom_sta
    ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  # You can provide the network details, as described in this blog
  # https://web.archive.org/web/20221213144358/https://mcwhirter.com.au/craige/blog/2019/Setting_Up_Wireless_Networking_with_NixOS/
  # Doing so should connect the macmini without needing to add a keyboard to the
  networking.networkmanager.enable = true;

  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "Europe/London";

  users.users.root.openssh.authorizedKeys.keys = [
    # This is my key https://github.com/jamesdury.keys, replace with yours
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXZBQVUhY3B0TEVGqISYDQwy2t+zCNdPRD2i8vJzsk8"
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  environment.defaultPackages = with pkgs; [
    git
    vim
    htop
  ];

  users.extraUsers.nixos.extraGroups = [ "wheel" ];
  # required for sshing into the machine
  users.extraUsers.nixos.initialPassword = "password";
  # increase build speed - https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
