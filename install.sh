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

#FTP server address eith ip address if you have static address or 
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

##############################################################################################
##############DONT change anything beyond this point##########################################
##############################################################################################

################################start of script###############################################

echo "******************************************************************************************"
echo "******************************************************************************************"
echo "******************************************************************************************"
echo "*************This will install sabnzb, sickbeard, headphones                  ************"
echo "*************couchpotato, lazy librarian, ufw, fail2ban                       ************"
echo "*************,squid proxy server and curlftpfs with mount points for your     ************"
echo "*************home media colletcion this assumes you have the following folders************"
echo "*************kidstv,kidsfilms,dadstv,dadsfilms,music books and 1gig swap file ************"
echo "*************ubuntu 12.04 server this was written and tested on a ramnode vps ************"
echo "*************installed with 12.04 server minimal on a kvm virtual machine     ************"
echo "*************vm matters if you want fuse to work out of the box - curlftpfs   ************"
echo "*************MAKE SURE YOU HAVE FILLED IN settings.conf place everything      ************"
echo "************* in the /tmp/ folder                                             ************"
echo "******************************************************************************************"
echo "******************************************************************************************"
echo "******************************************************************************************"
sleep 5
apt-get update
HOSTIP=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`
echo "i will be using: $HOSTIP"
echo "we will add a user so we can stop using root"
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
	fi

apt-get install git -y
echo "####################"
echo "## installing ufw ##"
echo "####################"
sleep 2
apt-get install ufw -y
echo "opening ports"
echo "###############################"
echo "## opening ports on firewall ##"
echo "###############################"
ufw allow $SSHPORT
echo "opening old ssh port just for now to make sure we dont lose our connetcion"
ufw allow ssh
echo "opening new Sab web UI port"
sudo ufw allow $SABPORT
echo "opening new Sickbeard web UI port"
sudo ufw allow $SICKPORT
echo "opening new Couchpotato web UI port"
sudo ufw allow $COUCHPORT
echo "opening new Headphones web UI port"
sudo ufw allow $HEADPORT
echo "opening new Lazy Librarian web UI port"
sudo ufw allow $BOOKPORT
echo "opening new Squid Proxy server Port"
sudo ufw allow $SQUIDPORT
echo "editing sshd config"
sed -i "s/port 22/port $sshport/" /etc/ssh/sshd_config
sed -i "s/protocol 3,2/protocol 2/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
#sed -i "s/DebianBanner yes/DebianBanner no/" /etc/ssh/sshd_config
echo "restarting ssh"
sleep 2
/etc/init.d/ssh restart -y
echo "enabling firewall"
sleep 2
ufw enable -y

echo "##########################"
echo "## secure shared memory ##"
echo "##########################"
sleep 2
echo "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" >> /etc/fstab
echo "adding admin group"
sleep 2
groupadd admin
usermod -a -G admin $username
echo "protect su by limiting access to admin group only"
dpkg-statoverride --update --add $username admin 4750 /bin/su

echo "############################################"
echo "# adding $username to sudo and fuse groups #"
echo "############################################"
sleep 3
usermod -a -G sudo $username
usermod -a -G fuse $username

echo "ip spoofing"
cat > /etc/host.conf << EOF
order bind,hosts
nospoof on
EOF

echo "##############################"
echo "# Harden Network with sysctl #"
echo "##############################"
sleep 3

cat > /etc/sysctl.conf << EOF
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0 
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Log Martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0 
net.ipv6.conf.default.accept_redirects = 0

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1
EOF
sysctl -p

echo "#######################"
echo "# installing fail2ban #"
echo "#######################"
sleep 3
sudo apt-get install fail2ban -y
echo "setting up fail2ban"
sleep 2
sed -i 's/enabled = false/enabled = true/' /etc/fail2ban/jail.conf
sed -i 's/port = sshd/port = $SSHPORT/' /etc/fail2ban/jail.conf
sed -i 's/port = sshd/port = $SSHPORT/' /etc/fail2ban/jail.conf
sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.conf
echo "###########################################"
echo "#fail2ban installed and configured for ssh#"
echo "###########################################"
sleep 3

echo "###############################"
echo "#installing squid proxy server#"
echo "###############################"
sleep 3
sudo apt-get install squid3 squid3-common -y

cat > /etc/squid3/squid.conf << EOF
http_port $SQUIDPORT
via off
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all 
request_header_access WWW-Authenticate allow all 
request_header_access Proxy-Authorization allow all 
request_header_access Proxy-Authenticate allow all 
request_header_access Cache-Control allow all 
request_header_access Content-Encoding allow all 
request_header_access Content-Length allow all 
request_header_access Content-Type allow all 
request_header_access Date allow all 
request_header_access Expires allow all 
request_header_access Host allow all 
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all 
request_header_access Location allow all 
request_header_access Pragma allow all 
request_header_access Accept allow all 
request_header_access Accept-Charset allow all 
request_header_access Accept-Encoding allow all 
request_header_access Accept-Language allow all 
request_header_access Content-Language allow all 
request_header_access Mime-Version allow all 
request_header_access Retry-After allow all 
request_header_access Title allow all 
request_header_access Connetcion allow all 
request_header_access Proxy-Connetcion allow all 
request_header_access User-Agent allow all 
request_header_access Cookie allow all 
request_header_access All deny all
http_access allow ncsa_auth
EOF

sudo apt-get install apache2-utils -y
sudo echo "" >> /etc/squid3/squid_passwd
sudo touch /etc/squid3/squid_passwd
sudo chmod 777 /etc/squid3/squid_passwd
sudo htpasswd -b -c /etc/squid3/squid_user $SQUIDUSER $SQUIDPASS
echo "######################"
echo "#starting Squid Proxy#"
echo "######################"
sleep 2
service squid3 start
echo "####################################"
echo "# squid started on port $SQUIDPORT #"
echo "####################################"
sleep 3

echo "########################"
echo "# creating Diretcories #"
echo "########################"
sleep 2
mkdir /home/$username/.pid/
mkdir /home/$username/temp
mkdir /home/downloads
mkdir /home/downloads/completed
mkdir /home/downloads/completed/tv
mkdir /home/downloads/completed/films
mkdir /home/downloads/completed/books
mkdir /home/downloads/completed/music
mkdir /home/downloads/ongoing
mkdir /home/media/
mkdir /home/media/kidstv
mkdir /home/media/kidsfilms
mkdir /home/media/dadstv
mkdir /home/media/dadsfilms
mkdir /home/media/music
mkdir /home/media/books
mkdir /home/backups/
mkdir /home/backups/sickbeard
mkdir /home/backups/couchpotato
mkdir /home/backups/headphones
mkdir /home/backups/lazylibrarian
mkdir /home/backups/sabnzbd
chown $username /home/*/*/
chmod 777  /home/*/*

apt-get install python-cheetah -y

echo "######################"
echo "# installing sabnzbd #"
echo "######################"
sleep 3
apt-get install sabnzbdplus -y
mv /etc/default/sabnzbdplus /home/backups/sabnzbd/sabnzbdplus.orig
echo "change sab config"
sleep 2

cat > /etc/default/sabnzbdplus << EOF
USER=$username
CONFIG=
HOST=$HOSTIP
PORT=$SABPORT
EOF

chmod +x /etc/init.d/sabnzbdplus
echo "starting sabnzbplus"
/etc/init.d/sabnzbdplus start
echo "sabnzbdplus is now running on $HOSTIP:$SABPORT"

echo "########################"
echo "# installing sickbeard "
echo "########################"
cd /home/$username/temp
git clone https://github.com/midgetspy/Sick-Beard.git sickbeard
echo "backing up sickbeard"
sleep 2
cp sickbeard /home/backups/sickbeard
mv sickbeard /home/$username/.sickbeard
#cp /home/$username/.sickbeard/config.ini /etc/default/sickbeard
#cp /home/$username/.sickbeard/init.ubuntu /etc/init.d/sickbeard

cat > /etc/init.d/sickbeard << EOF
#! /bin/sh
# Author: daemox
# Basis: Parts of the script based on and inspired by work from
# tret (sabnzbd.org), beckstown (xbmc.org),
# and midgetspy (sickbeard.com).
# Fixes: Alek (ainer.org), James (ainer.org), Tophicles (ainer.org),
# croontje (sickbeard.com)
# Contact: http://www.ainer.org
# Version: 3.1
### BEGIN INIT INFO
# Provides: sickbeard
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Should-Start: $NetworkManager
# Should-Stop: $NetworkManager
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: starts and stops sick beard
# Description: Sick Beard is an Usenet PVR. For more information see:
# http://www.sickbeard.com
### END INIT INFO
#Required -- Must Be Changed!
USER="$username" #Set Linux Mint, Ubuntu, or Debian user name here.

#Required -- Defaults Provided (only change if you know you need to).
HOST="$HOSTIP" #Set Sick Beard address here.
PORT="$SICKPORT" #Set Sick Beard port here.

#Optional -- Unneeded unless you have added a user name and password to Sick Beard.
SBUSR="$WEBUSER" #Set Sick Beard user name (if you use one) here.
SBPWD="$WEBPASS" #Set Sick Beard password (if you use one) here.

#Script -- No changes needed below.
case "$1" in
start)
#Start Sick Beard and send all messages to /dev/null.
cd /home/$USER/.sickbeard
echo "Starting Sick Beard"
sudo -u $USER -EH nohup python /home/$USER/.sickbeard/SickBeard.py -q &gt; /dev/null 2&gt;&amp;1 &amp;
;;
stop)
#Shutdown Sick Beard and delete the index.html files that wget generates.
echo "Stopping Sick Beard"
wget -q --user=$SBUSR --password=$SBPWD "http://$HOST:$PORT/home/shutdown/" --delete-after
sleep 6s
;;
*)
echo "Usage: $0 {start|stop}"
exit 1
esac
exit 0
EOF

chmod +x /etc/init.d/sickbeard
sudo update-rc.d sickbeard defaults
chmod 777 /home/$username/.sickbeard/
sudo /etc/init.d/sickbeard stop
sudo /etc/init.d/sickbeard start
echo "sick beard is now running on $HOSTIP:$SICKPORT"

echo "###########################"
echo "# installling Couchpotato #"
echo "###########################"
sleep 3
cd /home/$username/temp
git clone https://github.com/RuudBurger/CouchPotatoServer.git couchpotato
cp couchpotato /home/$username/backups/couchpotato
mv couchpotato /home/$username/.couchpotato
cp /home/$username/.couchpotato/init/ubuntu /etc/init.d/couchpotato

cat > /etc/default/couchpotato <<EOF
# COPY THIS FILE TO /etc/default/couchpotato 
# OPTIONS: CP_HOME, CP_USER, CP_DATA, CP_PIDFILE, PYTHON_BIN, CP_OPTS, SSD_OPTS

CP_HOME=/home/$username/.couchpotato
CP_USER=$username
CP_DATA=/home/$username/.config/couchpotato
CP_PIDFILE=/home/$username/.pid/couchpotato.pid
EOF

chmod +x /etc/init.d/couchpotato
sudo update-rc.d couchpotato defaults
chmod 777 /home/$username/.couchpotato/
echo "starting couchpotato"
python /home/$username/.couchpotato/CouchPotato.py --daemon
echo "CouchPotato has been started on port $COUCHPORT"

echo "#########################"
echo "# installing Headphones #"
echo "#########################"
sleep 1
cd /home/$username/temp
git clone https://github.com/rembo10/headphones.git  headphones
cp /home/$username/temp/headphones /home/backups/headphones/
mv /home/$username/temp/headphones /home/$username/.headphones
sudo cp /home/$username/.headphones/init.ubuntu /etc/init.d/headphones
mv /home/$username/.headphones/config.ini /home/$username/.headphones/config.orig
touch /home/$username/.headphones/config.ini
chown $username /home/$username/.headphones/*
chown $username /home/$username/.headphones/*/*
echo "will try and move config probably wont be there"
mv /home/$username/.headphones/config.ini /home/$username/.headphones/config.old

cat > /home/$username/.headphones/config.ini << EOF
[General]
config_version = 5
http_port = $HEADPORT
http_host = $HOSTIP
http_username = $WEBUSER
http_password = $WEBPASS
http_root = /
http_proxy = 0
enable_https = 0
https_cert = /home/$username/.headphones/server.crt
https_key = /home/$username/.headphones/server.key
launch_browser = 1
api_enabled = 0
api_key = ""
log_dir = /home/$username/.headphones/logs
cache_dir = /home/$username/.headphones/cache
git_path = ""
git_user = rembo10
git_branch = master
check_github = 1
check_github_on_startup = 1
check_github_interval = 360
music_dir = /home/music
destination_dir = /home/music
lossless_destination_dir = ""
preferred_quality = 0
preferred_bitrate = ""
preferred_bitrate_high_buffer = ""
preferred_bitrate_low_buffer = ""
preferred_bitrate_allow_lossless = 0
detect_bitrate = 0
auto_add_artists = 1
correct_metadata = 1
move_files = 1
rename_files = 1
folder_format = $Artist/$Album [$Year]
file_format = $Track $Artist - $Album ($Year) - $Title
file_underscores = 0
cleanup_files = 1
add_album_art = 1
album_art_format = folder
embed_album_art = 1
embed_lyrics = 0
nzb_downloader = 0
torrent_downloader = 1
download_dir = /home/completed/music
blackhole_dir = ""
usenet_retention = 1200
include_extras = 0
extras = ""
autowant_upcoming = 1
autowant_all = 0
keep_torrent_files = 0
numberofseeders = 10
torrentblackhole_dir = /home/torrents
isohunt = 0
kat = 1
mininova = 0
piratebay = 1
piratebay_proxy_url = ""
download_torrent_dir = /home/completed/music
search_interval = 360
libraryscan = 1
libraryscan_interval = 1800
download_scan_interval = 5
update_db_interval = 24
mb_ignore_age = 365
preferred_words = ""
ignored_words = ""
required_words = ""
lastfm_username = ""
interface = default
folder_permissions = 0755
file_permissions = 0644
music_encoder = 0
encoder = ffmpeg
xldprofile = ""
bitrate = 192
samplingfrequency = 44100
encoder_path = ""
advancedencoder = ""
encoderoutputformat = mp3
encoderquality = 2
encodervbrcbr = cbr
encoderlossless = 1
delete_lossless_files = 1
mirror = headphones
customhost = localhost
customport = 5000
customsleep = 1
hpuser = brownster
hppass = tcwacf1979
[Waffles]
waffles = 0
waffles_uid = ""
waffles_passkey = ""
[Rutracker]
rutracker = 0
rutracker_user = ""
rutracker_password = ""
[What.cd]
whatcd = 0
whatcd_username = ""
whatcd_password = ""
[SABnzbd]
sab_host = http://$HOSTIP:$SABPORT/sabnzbd
sab_username = $WEBUSER
sab_password = $WEBPASS
sab_apikey = 
sab_category = Music
[NZBget]
nzbget_username = nzbget
nzbget_password = ""
nzbget_category = ""
nzbget_host = ""
[Headphones]
headphones_indexer = 1
[Transmission]
transmission_host = http://$HOSTIP:$TRANPORT
transmission_username = $WEBUSER
transmission_password = $WEBPASS
[uTorrent]
utorrent_host = ""
utorrent_username = ""
utorrent_password = ""
[Newznab]
newznab = 1
newznab_host = http://$HOSTIP/
newznab_apikey = 01e7a9d89a824bda0a4d5b37cbeb8f51
newznab_enabled = 1
extra_newznabs = 
[NZBsorg]
nzbsorg = 0
nzbsorg_uid = None
nzbsorg_hash = ""
[NZBsRus]
nzbsrus = 0
nzbsrus_uid = ""
nzbsrus_apikey = ""
[omgwtfnzbs]
omgwtfnzbs = 0
omgwtfnzbs_uid = ""
omgwtfnzbs_apikey = ""
[Prowl]
prowl_enabled = 0
prowl_keys = ""
prowl_onsnatch = 0
prowl_priority = 0
[XBMC]
xbmc_enabled = 0
xbmc_host = ""
xbmc_username = ""
xbmc_password = ""
xbmc_update = 0
xbmc_notify = 0
[NMA]
nma_enabled = 0
nma_apikey = ""
nma_priority = 0
nma_onsnatch = 0
[Pushover]
pushover_enabled = 0
pushover_keys = ""
pushover_onsnatch = 0
pushover_priority = 0
[Synoindex]
synoindex_enabled = 0
[Advanced]
album_completion_pct = 80
cache_sizemb = 32
journal_mode = wal
EOF



cp /home/$username/.headphones/config.ini /etc/default/headphones
chown $username /home/$username/.headphones/
chown $username /home/$username/.headphones/*
chown $username /home/$username/.headphones/*/*
chmod 777 /home/$username/.headphones/*
chown $username /home/$userna
chmod +x /etc/init.d/headphones  
update-rc.d headphones defaults
echo "starting Headphones on port $HEADPORT"   
python /home/$username/.headphones/Headphones.py --daemon
echo "Headphones has started you can try http://$HOSTIP:$HEADPORT"

echo "############################"
echo "# installing Lazylibrarian #"
echo "############################"
cd /home/$username/temp
git clone https://github.com/Conjuro/LazyLibrarian.git lazylibrarian 
cp /home/$username/temp/lazylibrarian /home/backups/lazylibrarian/
mv /home/$username/temp/lazylibrarian  /home/$username/.lazylibrarian 
cp /home/$username/.lazylibrarian/init/ubuntu.initd /etc/init.d/lazylibrarian

cat > /etc/default/lazylibrarian <<EOF
APP_PATH=/home/castro/.lazylibrarian
ENABLE_DAEMON=1
RUN_AS=$user
WEBUPDATE=0
CONFIG=/home/$username/.lazylibrarian/
DATADIR=/home/$username/.lazylibrarian/
PORT=$BOOKPORT
PID_FILE=/home/$username/.pid/lazylibrarian.pid
EOF

chown $username /home/$username/.lazylibrarian
chmod 777 /home/$username/.lazylibrarian
chmod +x /etc/init.d/lazylibrarian  
update-rc.d lazylibrarian  defaults
echo "starting Lazy Librarian on port $BOOKPORT"
echo "Lazy Librarian will start on nect boot you can access the ui via http://$HOSTIP:$BOOKPORT"
sleep 2

echo "########################"
echo "# installing curlftpfs #"
echo "########################"
sleep 2
sudo apt-get install curlftpfs

echo "########################"
echo "#   add mount points   #"
echo "########################"
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$FILMFTPDIR /home/media/films fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$TVFTPDIR /home/media/tv fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$MUSICFTPDIR /home/media/music fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$BOOKFTPDIR /home/books fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab

echo "######################"
echo "# add 1GB swap space #"
echo "######################"
sleep 2
sudo dd if=/dev/zero of=/swapfile bs=1024 count=1024k
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile       none    swap    sw      0       0" >> /etc/fstab
echo 0 | sudo tee /proc/sys/vm/swappiness
echo vm.swappiness = 0 | sudo tee -a /etc/sysctl.conf
echo "mounting ftp locations"
sleep 2
sudo mount -a
echo "Thats it i am done lets check how well we did we will reboot"
echo "then go to your web browser and see if you van get to the web apps"
echo " also try adding you vps ip and proxy port into you web browser proxy" 
echo "settings then go to whatismyip you ip address should show as that of your"
echo "proxy..enjoy hopefully ;-)
sleep 10
ufw deny 22
shutdown -r now
