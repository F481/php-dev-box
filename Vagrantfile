# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "phpdevbox"
  config.vm.host_name = "development"
  config.vm.customize ["modifyvm", :id, "--memory", 768]

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  config.vm.network :hostonly, "172.22.22.22"
  config.vm.share_folder "v-root", "/vagrant", ".." , :nfs => false
  # whithout this symlinks can't be created on the shared folder
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]

  # chef solo configuration
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./"
    # chef debug level, start vagrant like this to debug:
    # $ CHEF_LOG_LEVEL=debug vagrant <provision or up>
    chef.log_level = ENV['CHEF_LOG'] || "info"

    # chef recipes
    chef.add_recipe("cookbook")
    chef.add_recipe("cookbook-git")
    chef.add_recipe("cookbook-mysql")
    chef.add_recipe("cookbook-php")
    chef.add_recipe("cookbook-vim")
  end
end
