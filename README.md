# Installation

## Archlinux/Manjaro

### Install archlinux-nix and nix from aur.
This will compile nix from source.
```
$ pikaur -S archlinux-nix nix
```

### [Bootstrap the system with archlinux-nix](https://wiki.archlinux.org/index.php/Nix#Installation_using_archlinux-nix)

This adds build groups, proper permissions etc. using an old release of nix.

```
$ sudo archlinux-nix setup-build-group
Creating group 'nixbld' and users ...
Setting group in /etc/nix/nix.conf ...
Killing daemon ...
Setting permissions on nix store ...

$ sudo archlinux-nix bootstrap
Installing sandbox binaries from NixOS-19.09 ...
unpacking 'https://github.com/NixOS/nixpkgs/archive/19.09.tar.gz'...
these derivations will be built:
...
these paths will be fetched ...
...
```


### Add temporary channels to root profile, add nix to default profile:
```
$ sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable

$ sudo nix-channel --update && nix-env -u
unpacking channels...
created 1 symlinks in user environment

# add to default profile
$ source /etc/profile.d/nix{,-daemon}.sh
```


### Upgrade to nixUnstable for flakes

[Flakes](https://nixos.wiki/wiki/Flakes) are a newer nonchannel-based future in
nix. Channels are impure because they refer to global variables `nix-channel --list`, which almost always will be different on every machine.
Flakes lock sources in place and allow for full reproducability everywhere.

```
$ nix-env -iA nixpkgs.nixUnstable nixpkgs.cacert; \
systemctl daemon-reload; systemctl restart nix-daemon
```

Then logout and back into the terminal session and check that `--version` is not `2.3`.
```
$ nix-daemon --version
nix-daemon (Nix) 2.4pre20210326_dd77f71
```


### Setup extra-container

Install at least one package as another user, because extra-container
has a bad check for a multi-user profile:

```
$ sudo nix-env -iA nixpkgs.hello

$ git clone https://github.com/erikarvstedt/extra-container

# is already ran with sudo
$ extra-container/util/install.sh
```

### Add default flags to nix for running with flake support
```
$ echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

Now your nix system, with flakes support and container support, is ready.


# Running/building/developing

Flakes allows one-command setups of projects, and in this instance a desktop.

### Run the desktop:

```
$ nix run 'github:tgunnoe/darktop'
```


### or build it:

```
$ nix build 'github:tgunnoe/darktop'
```

This outputs a symlink `./result` in your current directory so you can inspect the output in the nix store:

```
# launch it
$ ./result/bin/darktop
```


### or drop into a shell with the application available in your PATH

```
$ nix shell 'github:tgunnoe/darktop'
$ darktop
```


### or drop into a shell with the proper environment to build it yourself

```
$ nix develop 'github:tgunnoe/darktop'
```
