aleph-development
=================

This repository contains a Vagrantfile and a Puppet manifest for creating an [Aleph](https://github.com/tehn/aleph) development environment.  (Vagrant is a tool for creating virtual machines, in this case using VirtualBox, and Puppet is a tool for provisioning systems.)

Here are the steps:

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (get the appropriate VirtualBox platform package). 
* Install [Vagrant](http://www.vagrantup.com/downloads).
* Get the precise64 Vagrant box, which is an Ubuntu 12.04 LTS 64-bit system.  This is a 323MB file.
```
vagrant box add precise64 http://files.vagrantup.com/precise64.box
```
* Get the avr32 toolchain and headers [from Atmel](http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx). Unfortunately, you have to download these by hand, since Atmel wants your email address.  You want "Atmel AVR 32-bit Toolchain 3.4.2 - Linux 64-bit" and "Atmel AVR 8-bit and 32-bit Toolchain (3.4.2) 6.1.3.1475 - Header Files" -- the filenames at the moment are avr32-gnu-toolchain-3.4.2.435-linux.any.x86_64.tar.gz and atmel-headers-6.1.3.1475.zip. 
* Clone this repository:
```
git clone https://github.com/bensteinberg/aleph-development.git
```
* Copy the two Atmel files into the aleph-development/ directory, something like
```
cp ~/Downloads/avr32-gnu-toolchain-3.4.2.435-linux.any.x86_64.tar.gz aleph-development/
cp ~/Downloads/atmel-headers-6.1.3.1475.zip aleph-development/
```
* Change to the aleph-development/ directory, and start the vagrant box:
```
cd aleph-development/
vagrant up
```
The first time you run `vagrant up`, the virtual machine will provision itself with the necessary software and libraries, which can take ten or twenty minutes, depending on your hardware.  Subsequent boots will be much faster.
* Now you can ssh into the virtual machine, and start developing (if you get asked for a password, it's 'vagrant'):
```
vagrant ssh
```
* When you've logged out, stop the virtual machine like this:
```
vagrant halt
```

### Notes
* The virtual machine shares a folder with the host machine: the aleph-development/ directory on the host becomes /vagrant/ on the Vagrant box.  If you need to move files into or out of the virtual machine, putting files in the shared directory is one way to do it.

* The provisioning process clones a copy of the [tehn/aleph](https://github.com/tehn/aleph) repository into /home/vagrant.  You can develop to your heart's content inside this box, but if you want to contribute changes back to tehn/aleph, you'll have to [fork the repository](https://help.github.com/articles/fork-a-repo), clone it here, edit, push back to your forked copy, then send a [pull request](https://help.github.com/articles/using-pull-requests).  You'll have to [create an SSH key](https://help.github.com/articles/generating-ssh-keys) in the virtual machine and add it to your github account.  Also, on first commit, git will prompt you for name and email address.

* Although the puppet manifest updates the list of packages available, it does not upgrade installed packages; this requires some interaction and is left as an exercise for the user.  Start the virtual machine, log in, update, and upgrade like this:
```
vagrant up
vagrant ssh
sudo aptitude update
sudo aptitude safe-upgrade
```
The upgrade will install a new kernel, and will ask if it should install the bootloader GRUB on any partitions.  Don't let it; leave all partitions unchecked.  After the upgrade, you'll see an error message about rebuilding the VirtualBox Guest Additions, reboot and rebuild them like this:
```
exit
vagrant halt
vagrant up
vagrant ssh
sudo /etc/init.d/vboxadd setup
```

* I've included emacs and vim; obviously, you can install whatever you want with `sudo aptitude update ; sudo aptitude install whizbang`, but let me know if there's anything you think should be in environment by default.

### TODO/ISSUES

* In order to get this working, the manifest relies on specific versions of the toolchain files.  It would be much better for it to handle subsequent versions as well.  (However, given a problem with the latest blackfin gcc, maybe it's better to stick with known versions.)
* So far, I have compiled bees, lines, and beekeep.  It's possible that other targets require libraries not yet installed in the virtual machine; please let me know if that's the case.
* Although beekeep requires the libjansson4 package, I also had to compile jansson2.5 in order to get the right libraries and header files.  I've packaged it and included it in the repo as libjansson.tar.gz -- there may be a better way of including this.