NZB-INSTALL-SCRIPT
==================
Install Script for a clean kvm vps install of ubuntu 12.04 Sabnzb, Transmision, Headphones, Sickbeard, Couchpotato, LazyLibrarian, Mylar, Gamez, Maraschino Fail2ban setup for ssh
curlftps for mount points back to your local media
UFW for easy firewall config
squidproxy  for anonymous web browsing proxy server useful in the uk
and other steps to secure your vps like changing ssh port

This script attempts to install all necessary components and set them up from the information given in the start of the install.sh.


Before you start you will need at least one dyndns/no-ip name(s)  for your home you will also need to install an ftp server on your file server with port forwarding on your router. With that in place you will be able to run all your nzb downloads on your vps then once the download is complete post processing will move the files to your media collection on your local storage with the help of curlftps and some mount points this script will create.

To install get a kvm vps from ramnode https://clientarea.ramnode.com/aff.php?aff=838 reinstall the os with ubuntu 12.04 LTS minimal

log on as root you should change the root password now with "passwd" and then copy paste the following:

apt-get install git -y

git clone https://github.com/Brownster/NZB-INSTALL-SCRIPT.git installsh

cd installsh

chmod 777 install.sh

vi install.sh


You will then need to edit the following details:

#############################

DYNDNS=someplace.dydns-remote.com

WEBUSER=webuser

WEBPASS=webpass

SQUIDUSER=squid

SQUIDPASS=hideme

SQUIDPORT=7629

SSHPORT=2022

FTPHOST=somewhere.dyndns-remote.com

FTPUSER=ftpuser

FTPPASS=ftppass

FILMFTPDIR=films

TVFTPDIR=tvseries

MUSICFTPDIR=music

BOOKSFTPDIR=ebooks

FILMMNTDIR=/home/media/films

TVMNTDIR=/home/media/tv

MUSICMNTDIR=/home/media/music

BOOKSMNTDIR=/home/media/books

SABPORT=7960

SICKPORT=7961

COUCHPORT=7962

HEADPORT=7963

BOOKPORT=7964

GAMESPORT=7965

MYLARPORT=7966

MARAPORT=7967
######################

After that save the file by typing :wq and press enter
then run the script by typing:

./install.sh

You will be prompted for a new username and password this script will create a user to stop havingto use root.

You will also be prompted to confirm a couple of steps but apart form that it will take care of the rest. I also recommend you set up the local ftp shares before you start so when we mount the ftp shares it works and doesnt hang for 10 mins


<a href="https://clientarea.ramnode.com/aff.php?aff=838"><img src="http://www.ramnode.com/images/banners/affbannerdark.png" alt="high performance ssd vps" /></a>
