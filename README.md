NZB-INSTALL-SCRIPT
==================

Install Script for a clean kvm vps install of ubuntu 12.04 Sabnzb, Headphones, Sickbeard, Couchpotato, LazyLibrarian, Fail2ban setup for ssh
curlftps for mount points back to your local media
UFW for easy firewall config
and other steps to secure your vps

This script attempts to install all necessary components and set them up from the information given in settings.conf.

You will need to fill in settings.conf and place in /tmp/

Before you start you will need two dyndns/no-ip names one for the vps one for your home you will also need to install an ftp server on your file server with port forwarding on your router. With that in place you will (when its working :-) be able to run all your nzb downloads on your vps then once the download is complete post processing will move the files to your media collection on your local storage with the help of curlftps and some mount points this script will create.

As i say this script whilst runs and installs everything isnt ready for my intended audience a few computer shy friends that have a nas so have the required ftp server built in and have a raspberry pi with xbian but dont have a dedicated machine to run sickbeard with sabnzbd. They also have little knowledge of windows never mind linux, so i need to get it to a point where it just works on clean install of ubuntu 12.04 in as few steps as possible.
