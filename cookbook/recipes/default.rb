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
libapache2-mod-php5
php5-cli
php5-curl
php5-sqlite
php5-intl
php-apc
).each { | pkg | package pkg }


template "/etc/apache2/sites-enabled/vhost.conf" do
  user "root"
  mode "0644"
  source "vhost.conf.erb"
  notifies :reload, "service[apache2]"
end

service "apache2" do
  supports :restart => true, :reload => true, :status => true
  action [ :enable, :start ]
end

{ "/vagrant/app/config/parameters.yml.dist" => "/vagrant/app/config/parameters.yml",
  "/vagrant/app/config/phpcr_jackrabbit.yml.dist" => "/vagrant/app/config/phpcr.yml" }.each do | src, dest |
  file dest do
    content IO.read(src)
  end
end

execute "check if short_open_tag is Off in /etc/php5/apache2/php.ini?" do
  user "root"
  not_if "grep 'short_open_tag = Off' /etc/php5/apache2/php.ini"
  command "sed -i 's/short_open_tag = On/short_open_tag = Off/g' /etc/php5/apache2/php.ini"
end

execute "check if short_open_tag is Off in /etc/php5/cli/php.ini?" do
  user "root"
  not_if "grep 'short_open_tag = Off' /etc/php5/cli/php.ini"
  command "sed -i 's/short_open_tag = On/short_open_tag = Off/g' /etc/php5/cli/php.ini"
end

execute "check if date.timezone is Europe/Berlin in /etc/php5/apache2/php.ini?" do
  user "root"
  not_if "grep '^date.timezone = Europe/Berlin' /etc/php5/apache2/php.ini"
  command "sed -i 's/;date.timezone =.*/date.timezone = Europe\\/Berlin/g' /etc/php5/apache2/php.ini"
end

execute "check if date.timezone is Europe/Berlin in /etc/php5/cli/php.ini?" do
  user "root"
  not_if "grep '^date.timezone = Europe/Berlin' /etc/php5/cli/php.ini"
  command "sed -i 's/;date.timezone =.*/date.timezone = Europe\\/Berlin/g' /etc/php5/cli/php.ini"
end

bash "Running composer install and preparing the phpcr repository" do
  not_if "test -e /vagrant/vendor/symfony/symfony/src/Symfony/Bundle/FrameworkBundle/Resources/public"
  user "vagrant"
  cwd "/vagrant"
  code <<-EOH
set -e
ln -sf /var/tmp/vendor
curl -s https://getcomposer.org/installer | php
COMPOSER_VENDOR_DIR="/var/tmp/vendor" php composer.phar install
app/console doctrine:phpcr:workspace:create sandbox
app/console doctrine:phpcr:register-system-node-types
app/console -v doctrine:phpcr:fixtures:load
EOH
end
