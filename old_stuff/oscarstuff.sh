------------- Inital Installation NO LONGER NEEDED-------------
*** this need to be scripted  ***
<curl with bash run to kick everything off>
<set up vagrant w/ plugins>
Install vagrant plugins
vagrant plugin install oscar
vagrant plugin install vagrant-hostmanager
gem install vagrant-config_builder
vagrant oscar init
vagrant oscar init-vms

------------- Starting VMs -------------
vagrant up 

On master add folowing to puppet.conf (master section)
	/opt/puppet/share/puppet/modules
    service pe-puppet restart

On agents add folowing to puppet.conf (agent section)
    ignorecache = false
   	use_cached_catalog = false
    service pe-puppet restart

Add you roles on master
	/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production nodeclass:add name=<name::of::role>

Add role to your agent1 on master
	/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:addclass name=agent1.localhost class=<name::of::role>


------------- Redoing an agent, keeping master -------------
vagrant destroy agent1

Delete Node from master 
	/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:del name=agent1.localhost

Remove cert from master
	puppet cert clean agent1.localhost

vagrant up agent1

On agents add folowing to puppet.conf (agent section)
    ignorecache = true
   	use_cached_catalog = false
    service pe-puppet restart

Add role to your agent1 on master
	/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:addclass name=agent1.localhost class=<name::of::role>
-------------













vagrant oscar init-vms

	No auto_network pool available, generating a pool with the range 10.20.1.0/24
	Your environment has been initialized with the following configuration:
	masters:

	agents:

	pe_version: 3.1.1


-> % vagrant plugin list
oscar (0.3.1)
vagrant-cachier (0.5.1)
vagrant-config_builder (0.6.0)
vagrant-hostmanager (1.3.0)
vagrant-hosts (2.1.2)
vagrant-pe_build (0.8.3)

Stuff to get our shit together



<setup virtual back (https://www.virtualbox.org/wiki/Downloads)>
	- ON MASTER: update /modules to inlcude -->/opt/puppet/share/puppet/modules
    - ALL AGENTS: turn off cache    
    	ignorecache = false
    	use_cached_catalog = false
<set up r10k>
<start vagrant with whats in role>
<We need delete cert/node in puppet after VM is destroyed>



 mkdir -p ~/pe_manifests mkdir ~/pe_modules/ mkdir ~/repos/
 Then need to clone repos or run r10k


### Helpful links
#
# http://puppet-vagrant-boxes.puppetlabs.com/
# https://github.com/adrienthebo/oscar
# http://yard.ruby-doc.org/gems/docs/v/vagrant-config_builder-0.4.0/frames.html#!
#
# 
