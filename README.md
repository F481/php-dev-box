php-dev-box
===========

PHP (Symfony) development virtual machine based on Vagrant and Chef

Installation
------------
* install vagrant using the installation instractions of the [official vagrant documentation](http://docs.vagrantup.com/v2/installation/index.html)
* add a Ubuntu 12.10 (Quantal Quetzal) from http://www.vagrantbox.es, for example:  
`vagrant box add phpdevbox http://cloud-images.ubuntu.com/quantal/current/quantal-server-cloudimg-vagrant-amd64-disk1.box`  
(make sure it's named 'phpdevbox', note: PHPUnit isn't working with Ubuntu 12.04 via package installation)
* clone this repository
* after running `vagrant up` the box should be set up by vagrant and chef
* now you can connect to your new dev box via `vagrant ssh`.. test it!

Installed components
--------------------
* curl
* vim
* git
* libapache2-mod-php5
* php5-cli
* php5-curl
* php5-mysql
* php5-intl
* php5-xdebug
* php-apc
* mysql-server
* phpunit
* composer
