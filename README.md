NZB-INSTALL-SCRIPT
==================
NOT FULLY FUNCTIONAL
What is Working and checked with reboot
Sabnzbdplus
Headphones

Install Script for a clean kvm vps install of ubuntu 12.04 Sabnzb, Headphones, Sickbeard, Couchpotato, LazyLibrarian, Fail2ban setup for ssh
curlftps for mount points back to your local media
UFW for easy firewall config
squidproxy  for anonymous web browsing proxy server useful in the uk
and other steps to secure your vps like changing ssh port

This script attempts to install all necessary components and set them up from the information given in the start of the install.sh.


Before you start you will need atleast one dyndns/no-ip name(s) one for the vps one for your home you will also need to install an ftp server on your file server with port forwarding on your router. With that in place you will (when its working :-) be able to run all your nzb downloads on your vps then once the download is complete post processing will move the files to your media collection on your local storage with the help of curlftps and some mount points this script will create.

To install get a kvm vps from ramnode or another vps provider reinstall the os with ubuntu 12.04 LTS minimal

log on as root you should change the root password now with "passwd" and then copy paste the following:


apt-get install git -y

git clone https://github.com/Brownster/NZB-INSTALL-SCRIPT.git installsh

cd installsh

chmod 777 install.sh

vi install.sh


You will then need to edit the following details:

#! /bin/bash
#by Brownster - use at your own risk
######################SETTINGS to be filled in####################################################

#MUST CHANGE THESE SETTINGS

#DYNDNS / noip host name that resolves into your vps ip address
DYNDNS=someplace.dydns-remote.com

#Please enter a user name for accessing all the web apps
WEBUSER=webuser

#Please enter a password for accessing all the web apps
WEBPASS=webpass

#Please enter a Username for Squid Proxy Server
SQUIDUSER=squid

#Please enter a password for Squid Proxy Server
SQUIDPASS=hideme

#squid Proxy please enter the port for web access
SQUIDPORT=7629

#SSH please enter the port for access
SSHPORT=2022

#FTP server address either ip address if you have static address or 
#dyn dns / no ip account resolving to your home ip if you are dynamic
FTPHOST=somewhere.dyndns-remote.com

#ftp user
FTPUSER=ftpuser

#ftp password
FTPPASS=ftppass

#film ftp location - relative to ftp home directory
FILMFTPDIR=films

#TV ftp location
TVFTPDIR=tvseries

#Music ftp location
MUSICFTPDIR=music

#Books ftp location
BOOKSFTPDIR=ebooks

#films mount location
FILMMNTDIR=/home/media/films

#tv series mount location
TVMNTDIR=/home/media/tv

#music mount location
MUSICMNTDIR=/home/media/music

#books mount location
BOOKSMNTDIR=/home/media/books


#OPTIONAL TO CHANGE BELOW BUT RECOMMENDED

#SABNZB Please enter the port for web access
SABPORT=7960

#SICKBEARD Please enter the port for web access
SICKPORT=7961

#COUCHPOTATO Please enter the port for web access
COUCHPORT=7962

#Headphones Please enter the port for web access
HEADPORT=7963

#Lazy Librarian Please enter the port for web access
BOOKPORT=7964


After that save the file by typing :wq and press enter
then run the script by typing:

./install.sh

You will be prompted for a new username and password this script will create a user to stop havingto use root.

You will also be prompted to confirm a couple of steps but apart form that it will take care of the rest.
