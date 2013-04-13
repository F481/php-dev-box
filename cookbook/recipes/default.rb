# Run apt-get update to create the stamp file
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
  not_if do ::File.exists?('/var/lib/apt/periodic/update-success-stamp') end
end

# For other recipes to call to force an update
execute "apt-get update" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end

# provides /var/lib/apt/periodic/update-success-stamp on apt-get update
package "update-notifier-common" do
  notifies :run, resources(:execute => "apt-get-update"), :immediately
end

execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

# install the software we need
%w(
curl
vim
git
nginx
php5-cli
php5-curl
php5-mysql
php5-sqlite
php5-intl
php5-xdebug
php5-fpm
php-apc
mysql-server
).each { | pkg | package pkg }


execute "remove/uninstall apache2 package" do
  user "root"
  command "apt-get remove apache2 -y"
end

execute "check if short_open_tag is Off in /etc/php5/fpm/php.ini?" do
  user "root"
  not_if "grep 'short_open_tag = Off' /etc/php5/fpm/php.ini"
  command "sed -i 's/short_open_tag = On/short_open_tag = Off/g' /etc/php5/fpm/php.ini"
end

execute "check if short_open_tag is Off in /etc/php5/cli/php.ini?" do
  user "root"
  not_if "grep 'short_open_tag = Off' /etc/php5/cli/php.ini"
  command "sed -i 's/short_open_tag = On/short_open_tag = Off/g' /etc/php5/cli/php.ini"
end

execute "check if date.timezone is Europe/Berlin in /etc/php5/fpm/php.ini?" do
  user "root"
  not_if "grep '^date.timezone = Europe/Berlin' /etc/php5/fpm/php.ini"
  command "sed -i 's/;date.timezone =.*/date.timezone = Europe\\/Berlin/g' /etc/php5/fpm/php.ini"
end

execute "check if date.timezone is Europe/Berlin in /etc/php5/cli/php.ini?" do
  user "root"
  not_if "grep '^date.timezone = Europe/Berlin' /etc/php5/cli/php.ini"
  command "sed -i 's/;date.timezone =.*/date.timezone = Europe\\/Berlin/g' /etc/php5/cli/php.ini"
end

execute "install composer" do
  user "root"
  command "curl -s http://getcomposer.org/installer | php -- --install-dir=/usr/bin"
end
