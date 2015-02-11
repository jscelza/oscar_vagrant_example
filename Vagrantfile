# -*- mode: ruby -*-
# vi: set ft=ruby :


# Plug in check no longer is support.  You will need the following plug-ins for this to work
# oscar
# vagrant-auto_network
# vagrant-config_builder
# vagrant-hosts
# vagrant-pe_build

### Global Veriables
# Need to set pool in this file to ensure it is configured prior to any further commands
AutoNetwork.default_pool = '168.254.50.0/24'

Vagrant.configure('2',&Oscar.run(File.expand_path('../config', __FILE__)))

###  Any additional configuration or override put it in 
###  ~/.vagrant.d/Vagrantfile
