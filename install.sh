#! /bin/bash
##################  by Brownster - use at your own risk ############################################ 
###################### SETTINGS to be filled in ####################################################

## MUST CHANGE THESE SETTINGS !! ##

#DYNDNS / noip host name that resolves into your vps ip address
DYNDNS=someplace.dydns-remote.com

#Please enter a user name for accessing sickbeard, couchpotato ect
WEBUSER=webuser

#Please enter a password for accessing all the web apps sickbeard, couchpotato ect
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

#Books ftp location
GAMESFTPDIR=games

#Books ftp location
COMICSFTPDIR=comics

#games mount location
GAMESMNTDIR=/home/media/games

#comics mount location
COMICSMNTDIR=/home/media/comics

#films mount location
FILMMNTDIR=/home/media/films

#tv series mount location
TVMNTDIR=/home/media/tv

#music mount location
MUSICMNTDIR=/home/media/music

#books mount location
BOOKSMNTDIR=/home/media/books


## OPTIONAL TO CHANGE BELOW BUT RECOMMENDED ##

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

#Mylar Please enter the port for web access
MYLARPORT=7965

#Gamez Please enter the port for web access
GAMESPORT=7966

#Transmission RPC Port (web ui)
TRANPORT=7967

#Transmission peer port
TRANPPORT=61724

#Maraschino Web UI port
MARAPORT=7979

##############################################################################################
############## DO NOT MAKE ANY CHANGES BEYOND THIS POINT #####################################
##############################################################################################

################################ start of scrip t#############################################

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
add-apt-repository ppa:jcfp/ppa
add-apt-repository ppa:transmissionbt/ppa
apt-get update
HOSTIP=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`
#echo "i will be using: $HOSTIP as the WAN address"

while :
do
 clear
 echo "   M A I N - M E N U"
 echo "1. Install Sabnzbdplus"
 echo "2. Install Couchpotato"
 echo "3. Install Sickbeard"
 echo "4. Install Lazy Librarian"
 echo "5. Install Gamez
 echo "6. Install Mylar"
 echo "7. Install squid Proxy"
 echo "8.  RUN FIRST Harden VPS create new non root user (see read me) - RUN FIRST"
 echo "9. I am scared get me out of here (exit)"
 echo -n "Please enter option [1 - 9]"
 read opt
 case $opt in

8)
echo "#######################"
echo "## create a new user ##"
echo "#######################"

echo "we will add a user so we can stop using root, please provide username and password when prompted"
sleep2
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

#just in case we dont have git
apt-get install git -y
#install python now incase sabnzbsplus install fails
apt-get install python-cheetah -y

echo "####################"
echo "## installing ufw ##"
echo "####################"
sleep 2
apt-get install ufw -y


echo "###############################"
echo "## opening ports on firewall ##"
echo "###############################"
ufw allow $SSHPORT
echo "opening old ssh port just for now to make sure we dont lose our connetcion"
ufw allow ssh
echo "opening new Sab web UI port"
ufw allow $SABPORT
echo "opening new Sickbeard web UI port"
ufw allow $SICKPORT
echo "opening new Couchpotato web UI port"
ufw allow $COUCHPORT
echo "opening new Headphones web UI port"
ufw allow $HEADPORT
echo "opening new Lazy Librarian web UI port"
ufw allow $BOOKPORT
echo "opening new Squid Proxy server Port"
ufw allow $SQUIDPORT
echo "opening new Transmission web UI Port"
ufw allow $TRANPORT
echo "opening port for Maraschino"
ufw allow $MARAPORT
echo "nZEDb web port"
ufw allow 80
echo "editing sshd config"
sed -i "s/port 22/port $sshport/" /etc/ssh/sshd_config
sed -i "s/protocol 3,2/protocol 2/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/DebianBanner yes/DebianBanner no/" /etc/ssh/sshd_config
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


echo "############################"
echo "## ip spoofing protection ##"
echo "############################"
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
sleep 2
sudo apt-get install fail2ban -y
echo "setting up fail2ban"
sed -i 's/enabled = false/enabled = true/' /etc/fail2ban/jail.conf
sed -i 's/port = sshd/port = $SSHPORT/' /etc/fail2ban/jail.conf
sed -i 's/port = sshd/port = $SSHPORT/' /etc/fail2ban/jail.conf
sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.conf


echo "###################################"
echo "## installing squid proxy server ##"
echo "###################################"
sleep 2
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

apt-get install apache2-utils -y
echo "" >> /etc/squid3/squid_passwd
touch /etc/squid3/squid_passwd
chmod 777 /etc/squid3/squid_passwd
htpasswd -b -c /etc/squid3/squid_user $SQUIDUSER $SQUIDPASS
service squid3 stop
service squid3 start
echo "squid started on port $SQUIDPORT #"



echo "##########################"
echo "## creating Diretcories ##"
echo "##########################"
sleep 1
mkdir /home/$username/.pid/
mkdir /home/$username/temp
mkdir /home/downloads
mkdir /home/downloads/completed
mkdir /home/downloads/completed/tv
mkdir /home/downloads/completed/films
mkdir /home/downloads/completed/books
mkdir /home/downloads/completed/music
mkdir /home/downloads/completed/games
mkdir /home/downloads/completed/comics
mkdir /home/downloads/ongoing
mkdir /home/media/
mkdir /home/media/films
mkdir /home/media/tv
mkdir /home/media/music
mkdir /home/media/books
mkdir /home/media/games
mkdir /home/media/comics
mkdir /home/backups/
mkdir /home/backups/sickbeard
mkdir /home/backups/couchpotato
mkdir /home/backups/headphones
mkdir /home/backups/lazylibrarian
mkdir /home/backups/sabnzbd
mkdir /home/backups/comics
mkdir /home/backups/games
chown $username /home/*/*/
chown $username /home/*/*/*
chmod 777  /home/*/*



echo "########################"
echo "## installing sabnzbd ##"
echo "########################"
sleep 2
apt-get install sabnzbdplus -y
mv /etc/default/sabnzbdplus /home/backups/sabnzbd/sabnzbdplus.orig
echo "change sab config"

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



echo "##########################"
echo "## installing sickbeard ##"
echo "##########################"
sleep 2
cd /home/$username/temp
git clone https://github.com/midgetspy/Sick-Beard.git sickbeard
echo "backing up sickbeard"
cp sickbeard /home/backups/sickbeard
mv sickbeard /home/$username/.sickbeard
#cp /home/$username/.sickbeard/config.ini /etc/default/sickbeard
cp /home/$username/.sickbeard/init.ubuntu /etc/init.d/sickbeard

cat > /etc/default/sickbeard << EOF
[General]
config_version = 4
log_dir = Logs
web_port = $SICKPORT
web_host = $HOSTIP
web_ipv6 = 0
web_log = 0
web_root = ""
web_username = $WEBUSER
web_password = $WEBPASS
anon_redirect = http://dereferer.org/?
use_api = 0
api_key = ""
enable_https = 0
https_cert = server.crt
https_key = server.key
use_nzbs = 1
use_torrents = 0
nzb_method = sabnzbd
usenet_retention = 500
search_frequency = 60
download_propers = 1
quality_default = 164
status_default = 5
flatten_folders_default = 0
provider_order = sick_beard_index womble_s_index
version_notify = 1
naming_pattern = Season %0S/%SN %EN S%0SE%0E
naming_custom_abd = 0
naming_abd_pattern = ""
naming_multi_ep = 1
launch_browser = 1
use_banner = 0
use_listview = 0
metadata_xbmc = 0|0|0|0|0|0
metadata_xbmc_12plus = 1|1|1|1|1|1
metadata_mediabrowser = 0|0|0|0|0|0
metadata_ps3 = 0|0|0|0|0|0
metadata_wdtv = 0|0|0|0|0|0
metadata_tivo = 0|0|0|0|0|0
metadata_synology = 0|0|0|0|0|0
cache_dir = cache
root_dirs = 0|/home/tv|
tv_download_dir = ""
keep_processed_dir = 0
move_associated_files = 1
process_automatically = 0
rename_episodes = 1
create_missing_show_dirs = 0
add_shows_wo_dir = 0
extra_scripts = ""
git_path = ""
ignore_words = "german,french,core2hd,dutch,swedish,480p"
[Blackhole]
nzb_dir = ""
torrent_dir = ""
[EZRSS]
ezrss = 0
[HDBITS]
hdbits = 0
hdbits_username = ""
hdbits_passkey = ""
[TVTORRENTS]
tvtorrents = 0
[TVTORRENTS]
tvtorrents = 0
tvtorrents_digest = ""
tvtorrents_hash = ""
[BTN]
btn = 0
btn_api_key = ""
[TorrentLeech]
torrentleech = 0
torrentleech_key = ""
[NZBs]
nzbs = 0
nzbs_uid = ""
nzbs_hash = ""
[Womble]
womble = 1
[omgwtfnzbs]
omgwtfnzbs = 0
omgwtfnzbs_username = ""
omgwtfnzbs_apikey = ""
[SABnzbd]
sab_username = $WEBUSER
sab_password = $WEBPASS
sab_apikey = 
sab_category = tv
sab_host = http://$HOSTIP:$SABPASS/
[NZBget]
nzbget_password = 
nzbget_category = tv
nzbget_host = ""
[XBMC]
use_xbmc = 0
xbmc_notify_onsnatch = 0
xbmc_notify_ondownload = 0
xbmc_update_library = 0
xbmc_update_full = 0
xbmc_update_onlyfirst = 0
xbmc_host = ""
xbmc_username = ""
xbmc_password = ""
[Plex]
use_plex = 0
plex_notify_onsnatch = 0
plex_notify_ondownload = 0
plex_update_library = 0
plex_server_host = ""
plex_host = ""
plex_username = ""
plex_password = ""
[Growl]
use_growl = 0
growl_notify_onsnatch = 0
growl_notify_ondownload = 0
growl_host = ""
growl_password = ""
[Prowl]
use_prowl = 0
prowl_notify_onsnatch = 0
prowl_notify_ondownload = 0
prowl_api = ""
prowl_priority = 0
[Twitter]
use_twitter = 0
twitter_notify_onsnatch = 0
twitter_notify_ondownload = 0
twitter_username = ""
twitter_password = ""
twitter_prefix = Sick Beard
[Boxcar]
use_boxcar = 0
boxcar_notify_onsnatch = 0
boxcar_notify_ondownload = 0
boxcar_username = ""
[Pushover]
use_pushover = 0
pushover_notify_onsnatch = 0
pushover_notify_ondownload = 0
pushover_userkey = ""
[Libnotify]
use_libnotify = 0
libnotify_notify_onsnatch = 0
libnotify_notify_ondownload = 0
[NMJ]
use_nmj = 0
nmj_host = ""
nmj_database = ""
nmj_mount = ""
[Synology]
use_synoindex = 0
[NMJv2]
use_nmjv2 = 0
nmjv2_host = ""
nmjv2_database = ""
nmjv2_dbloc = ""
[Trakt]
use_trakt = 0
trakt_username = ""
trakt_password = ""
trakt_api = ""
[pyTivo]
use_pytivo = 0
pytivo_notify_onsnatch = 0
pytivo_notify_ondownload = 0
pyTivo_update_library = 0
pytivo_host = ""
pytivo_share_name = ""
pytivo_tivo_name = ""
[NMA]
use_nma = 0
nma_notify_onsnatch = 0
nma_notify_ondownload = 0
nma_api = ""
nma_priority = 0
[Newznab]
newznab_data = "Sick Beard Index|http://lolo.sickbeard.com/|0|5030,5040|1!!!NZBs.org|http://nzbs.org/||5030,5040,5070,5090|"
[GUI]
coming_eps_layout = banner
coming_eps_display_paused = 0
coming_eps_sort = date
EOF

mv /home/castro/.sickbeard/config.ini /home/castro/.sickbeard/config.old
cp /etc/default/sickbeard /home/castro/.sickbeard/config.ini
chown $username /etc/init.d/sickbeard
chown $username /home/$username/.sickbeard/*
chmod +x /etc/init.d/sickbeard
sudo update-rc.d sickbeard defaults
chmod 777 /home/$username/.sickbeard/
sudo /etc/init.d/sickbeard stop
sudo /etc/init.d/sickbeard start
echo "sick beard is now running on $HOSTIP:$SICKPORT"



echo "#############################"
echo "## installling Couchpotato ##"
echo "#############################"
sleep 2
cd /home/$username/temp
git clone https://github.com/RuudBurger/CouchPotatoServer.git couchpotato
cp couchpotato /home/$username/backups/couchpotato
mv couchpotato /home/$username/.couchpotato
cp /home/$username/.couchpotato/init/ubuntu /etc/init.d/couchpotato

cat > /etc/default/couchpotato << EOF
# COPY THIS FILE TO /etc/default/couchpotato 
# OPTIONS: CP_HOME, CP_USER, CP_DATA, CP_PIDFILE, PYTHON_BIN, CP_OPTS, SSD_OPTS

CP_HOME=/home/$username/.couchpotato
CP_USER=$username
CP_DATA=/home/$username/.config/couchpotato
CP_PIDFILE=/home/$username/.pid/couchpotato.pid
EOF

cat > /home/castro/.pid/couchpotato.pid << EOF
50004
EOF

chmod +x /etc/init.d/couchpotato
update-rc.d couchpotato defaults
chmod 777 /home/$username/.couchpotato/
echo "starting couchpotato"
python /home/$username/.couchpotato/CouchPotato.py --daemon
echo "CouchPotato has been started on port $COUCHPORT"



echo "###########################"
echo "## installing Headphones ##"
echo "###########################"
sleep 2
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
hpuser = 
hppass = 
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
newznab_host = http://
newznab_apikey = 
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
chmod 777 /home/$username/.headphones/logs/headphones.log
chown $username /home/$userna
chmod +x /etc/init.d/headphones  
update-rc.d headphones defaults
echo "starting Headphones on port $HEADPORT"   
python /home/$username/.headphones/Headphones.py --daemon
echo "Headphones has started you can try http://$HOSTIP:$HEADPORT"



echo "##############################"
echo "## installing Lazylibrarian ##"
echo "##############################"
cd /home/$username/temp
git clone https://github.com/Conjuro/LazyLibrarian.git lazylibrarian 
cp /home/$username/temp/lazylibrarian /home/backups/lazylibrarian/
mv /home/$username/temp/lazylibrarian  /home/$username/.lazylibrarian 
cp /home/$username/.lazylibrarian/init/ubuntu.initd /etc/init.d/lazylibrarian

cat > /etc/default/lazylibrarian << EOF
APP_PATH=/home/castro/.lazylibrarian
ENABLE_DAEMON=1
RUN_AS=$user
WEBUPDATE=0
CONFIG=/home/$username/.lazylibrarian/
DATADIR=/home/$username/.lazylibrarian/
PORT=$BOOKPORT
PID_FILE=/home/$username/.pid/lazylibrarian.pid
EOF

cat < /home/$username/.pid/lazylibrarian.pid << EOF
50005
EOF

chown $username /home/$username/.pid/lazylibrarian.pid
chmod 777 /home/$username/.pid/lazylibrarian.pid
chown $username /home/$username/.lazylibrarian
chmod 777 /home/$username/.lazylibrarian
chmod +x /etc/init.d/lazylibrarian  
update-rc.d lazylibrarian  defaults
echo "Lazy Librarian will start on nect boot you can access the ui via http://$HOSTIP:$BOOKPORT"



echo "###########################"
echo "## installing Maraschino ##"
echo "###########################"
cd /home/$username/temp
git clone https://github.com/mrkipling/maraschino.git maraschino
cp /home/$username/temp/maraschino /home/backups/maraschino/
mv /home/$username/temp/maraschino  /home/$username/.maraschino
cp /home/$username/maraschino/initd /etc/init.d/maraschino

cat >/etc/default/maraschino << EOF
# This file is sourced by /etc/init.d/maraschino
#
# When maraschino is started using the init script
# is started under the account of $USER, as set below.
#
# Each setting is marked either "required" or "optional";
# leaving any required setting unconfigured will cause
# the service to not start.

# [required] set path where maraschino is installed:
APP_PATH=/home/$username/.maraschino

# [optional] change to 1 to enable daemon
ENABLE_DAEMON=1

# [required] user or uid of account to run the program as:
RUN_AS=$username

# [optional] full path for the pidfile
# otherwise, the default location /var/run/maraschino/maraschino.pid is used:
PID_FILE=

# [required] port to listen on (defaults to 7000)
PORT=$MARAPORT
EOF

chmod a+x /etc/init.d/maraschino
update-rc.d maraschino defaults
chown $username /home/$username/.maraschino/
chmod 777 /home/$username/.maraschino/
/etc/init.d/maraschino start

echo "#######################"
echo "## downloading mylar ##"
echo "#######################"
sleep 1
cd /home/$username/temp
git clone https://github.com/evilhero/mylar.git mylar
cp /home/$username/temp/mylar /home/backups/mylar/
mv /home/$username/temp/mylar  /home/$username/.mylar 
chown $username /home/$username/.mylar/
chmod 777 /home/$username/.mylar



echo "#######################"
echo "## downloading gamez ##"
echo "#######################"
sleep 1
cd /home/$username/temp
git clone https://github.com/mdlesk/Gamez.git gamez
cp /home/$username/temp/gamez /home/backups/gamez/
mv /home/$username/temp/gamez  /home/$username/.gamez
chown $username /home/$username/.gamez/
chmod 777 /home/$username/.gamez


echo "##########################"
echo "## install teansmission ##"
echo "##########################"
apt-get install transmission-daemon
mv /etc/transmission-daemon/settings.json /etc/transmission-daemon/settings.old

cat > /etc/transmission-daemon/settings.json << EOF
{
 "alt-speed-down": 50,
 "alt-speed-enabled": false,
 "alt-speed-time-begin": 540,
 "alt-speed-time-day": 127,
 "alt-speed-time-enabled": false,
 "alt-speed-time-end": 1020,
 "alt-speed-up": 50,
 "bind-address-ipv4": "$HOSTIP",
 "bind-address-ipv6": "::",
 "blocklist-enabled": true,
 "blocklist-url": "http://list.iblocklist.com/?list=bt_level1&amp;fileformat=p2p&amp;archiveformat=gz",
 "cache-size-mb": 4,
 "dht-enabled": true,
 "download-dir": "/home/$username/complete/",
 "download-limit": 100,
 "download-limit-enabled": 0,
 "encryption": 2,
 "idle-seeding-limit": 30,
 "idle-seeding-limit-enabled": false,
 "incomplete-dir": "/home/$username/ongoing/",
 "incomplete-dir-enabled": true,
 "lpd-enabled": false,
 "max-peers-global": 200,
 "message-level": 2,
 "peer-congestion-algorithm": "",
 "peer-limit-global": 240,
 "peer-limit-per-torrent": 60,
 "peer-port": $TRANPPORT,
 "peer-port-random-high": 65535,
 "peer-port-random-low": 49152,
 "peer-port-random-on-start": false,
 "peer-socket-tos": "default",
 "pex-enabled": true,
 "port-forwarding-enabled": true,
 "preallocation": 1,
 "prefetch-enabled": 1,
 "ratio-limit": 2,
 "ratio-limit-enabled": false,
 "rename-partial-files": true,
 "rpc-authentication-required": true,
 "rpc-bind-address": "0.0.0.0",
 "rpc-enabled": true,
 "rpc-password": "$WEBPASS",
 "rpc-port": "$TRANPORT",
 "rpc-url": "/transmission/",
 "rpc-username": "$WEBUSER",
 "rpc-whitelist": "127.0.0.1",
 "rpc-whitelist-enabled": false,
 "script-torrent-done-enabled": false,
 "script-torrent-done-filename": "",
 "speed-limit-down": 100,
 "speed-limit-down-enabled": false,
 "speed-limit-up": 100,
 "speed-limit-up-enabled": false,
 "start-added-torrents": true,
 "trash-original-torrent-files": false,
 "umask": 18,
 "upload-limit": 100,
 "upload-limit-enabled": 0,
 "upload-slots-per-torrent": 14,
 "utp-enabled": true
}
EOF

service transmission-daemon reload


echo "######################"
echo "## Installing nzedb ##"
echo "######################"
/etc/init.d/apparmor stop
/etc/init.d/apparmor teardown
update-rc.d -f apparmor remove
apt-get install python-setuptools
python -m easy_install
easy_install cymysql
apt-get install -y php5 php5-dev php-pear php5-gd php5-mysqlnd php5-curl
cp /etc/php5/cli/php.ini /home/backup/nzedb/php.ini.back

cat > /etc/php5/cli/php.ini << EOF

EOF

apt-get install mysql-server mysql-client libmysqlclient-dev
sudo apt-get install apache2

cat > /etc/php5/apache2/php.ini << EOF

EOF

cat > /etc/apache2/sites-available/nZEDb << EOF
<VirtualHost *:80>
     ServerName xxxx
     ServerAdmin xxxxx
     ServerAlias xxxx
     DocumentRoot "/var/www/nZEDb/www"
     ErrorLog /var/log/apache2/error.log
     LogLevel warn
     ServerSignature Off

  <Directory "/var/www/nZEDb/www">
         Options FollowSymLinks
         AllowOverride All
         Order allow,deny
         allow from all
  </Directory>

</VirtualHost>
EOF

a2dissite default
a2ensite nZEDb
a2enmod rewrite
service apache2 restart
add-apt-repository ppa:shiki/mediainfo
apt-get update
apt-get install mediainfo
apt-get install lame
git clone https://github.com/nZEDb/nZEDb.git /var/www/
chmod 777 /var/www/nZEDb
cd /var/www/nZEDb
chmod -R 755
sudo chmod 777 /var/www/nZEDb/www/lib/smarty/templates_c
sudo chmod -R 777 /var/www/nZEDb/www/covers
sudo chmod 777 /var/www/nZEDb/www
sudo chmod 777 /var/www/nZEDb/www/install
sudo chmod -R 777 /var/www/nZEDb/nzbfiles

echo "########################"
echo "# installing curlftpfs #"
echo "########################"
sleep 1
sudo apt-get install curlftpfs


echo "########################"
echo "#   add mount points   #"
echo "########################"
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$FILMFTPDIR /home/media/films fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$TVFTPDIR /home/media/tv fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$MUSICFTPDIR /home/media/music fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$BOOKFTPDIR /home/media/books fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$GAMEFTPDIR /home/media/games fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab
echo "curlftpfs#$FTPUSER:$FTPPASS@$FTPHOST/$COMICSFTPDIR /home/media/comics fuse auto,user,uid=1000,allow_other,_netdev 0 0" >> /etc/fstab


echo "######################"
echo "# add 1GB swap space #"
echo "######################"
sleep 1
sudo dd if=/dev/zero of=/swapfile bs=1024 count=1024k
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile       none    swap    sw      0       0" >> /etc/fstab
echo 0 | sudo tee /proc/sys/vm/swappiness
echo vm.swappiness = 0 | sudo tee -a /etc/sysctl.conf


#echo "mounting ftp locations"
#sudo mount -a
echo "Thats it i am done lets check how well we did we will reboot"
echo "then go to your web browser and see if you van get to the web apps"
echo " also try adding you vps ip and proxy port into you web browser proxy" 
echo "settings then go to whatismyip you ip address should show as that of your"
echo "proxy..enjoy hopefully ;-)"
sleep 10
ufw deny 22
shutdown -r now
