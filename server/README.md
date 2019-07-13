# Easy Linux / Node JS / Apache / PHP / MySQL / MongoDB server deployment  

Semi-interactive bash tools for easy Debian or Ubuntu server deployment.     

Deploy your server in less then 5 minutes. 

Currently supported:
* Environment & tools setup
* Node JS v12.x
* Apache2 w/ HTTP2 & Let's Encrypt 
* PHP 7.3
* MySQL 8.0
* MongoDB 4.0
* rsync automatic backup setup 

These tools should only be used on freshly installed or initiated instances of Debian or Ubuntu servers.  
Tested on:
 * Debian 10 \[buster\]
 * Ubuntu 18-04 \[bionic\]
   
-----------

**Use at your own risk.**

-----------

### Default usage

Simply run this on your server
```bash  
bash <curl -s "https://tools.deltazero.cz/server/init.sh")
```

This will give you options to:
* update default username (if currenty: ubuntu, debian, user)
* set up hostname
* set timezone
* dist-upgrade
* install some often used tools (vim, screen, netcat, rsync...)
* set up bash aliases, .profile for screen etc. `s` shortcut for `sudo`
* install Apache
  * move document roots to /home/www
  * server badge as default to /home/www/_default
  * obtain Let's Encrypt certificate for your hostname 
* install PHP7.3 cli & fpm
	* integrate with Apache, if installed
	* adds [/adminer](https://www.adminer.org) to server badge (https://**hostname**/adminer)
* install MySQL 8.0 Community Edition
	* move datadir /home/mysql
* install Node JS 12.x
* install MongoDB 4.0
	* move datadir /home/mongo
* create symlinks to often used data & configs to your homedir

Keep in mind, default gives you _my favourite_ settings incl. my brand logo on http(s) server badge.   

### Customization

Clone & modify the scripts, there are some config options in scripts' first lines.  
Then run `bash init.sh`

-----------


**David Obdržálek**

<a href="https://www.deltazero.cz"><img src="https://www.deltazero.cz/d0.svg" width="130" alt="ΔO"></a>  

www.deltazero.cz
