#pe_vagrant
==========

####Table of Contents

1. [Overview - What is the Adobe_em module?](#overview)
2. [Prerequisites - What you need for this?](#prerequisites)
3. [Master setup ](#master-setup)
4. [Agents Setup](#agents-setup)
5. [Reseting an agent](#Reseting-an-agent)
6. [Helpful Rake API Commands](#helpful-rake-api-commands)
7. [Getting our PE Modules](Getting-our-pe-modules)

## Overview

A vagrant environment for Puppet Enterprise Development.  This configuration is a bit manual currently, but will be
automated 

### Prerequisites

- Install [VirtualBox](https://www.virtualbox.org/)
- Install [Vagrant](http://www.vagrantup.com/)
- Set up Base directory for Repos and master and install the plug
    * ~/pe_modules      => contains combino of working PE modules and r10k moduels used at TWC
    * ~/repos/hieradata => copy of companyies hiera repo

```
mkdir -p ~/pe_modules ~/repos/hieradata
vagrant plugin install oscar
git clone git@github.webapps.rr.com:fylgia/pe_vagrant.git ~/repos/pe_vagrant
```


### Master Setup

A few easy steps to get the master running on your PC

**All command are ran in the pe_vagrant directory**

```
cd ~/repos/pe_vagrant
vagrant up master
```

### Agent Setup 

A few easy steps to get the agents running on your PC.  

**All command are ran in the pe_vagrant directory**

```
vagrant up <name of agent>

Update ~/repos/pe_vagrant/puppet/files/twc.facts with your application followed by

   application = <your app>
   env_type = <your environment>
   application_component = <your component>

vagrant up <machine>
or
vagrant reload --provision 
```
### Reseting an agent

1. Destory you agent: `vagrant destory <agent>` 
2. Delete Node from Master (see RAKE commands)
3. Remove cert from master as root user: `puppet cert clean <agent>`
4. Bring up agent: `vagrant up <agent>`
5. Add setting on agent to disable cache (see above)
6. Add Role to agent (see Rake API commnads)

### Helpful Rake API Commands

The following is a list of commands that I have ran on the Master to set up roles and class

**All commands are ran on the master VM as root**

- Add a role to PE

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production nodeclass:add name=<name::of::role>
```

- Add role to your Node (agent) in PE

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:addclass name=<agent> class=<name::of::role>`
```
- Delete Node (agent) from PE

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:del name=<agent>`
```

- Replace Classes on a Node (agent)

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:classes name=<agent> classes=<name::of::role>
```

- List nodes on master

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:list

```

- List roles for a node

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:listclasses name=<agent>
```

- List all roles on Master

```
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production nodeclass:list
```

### Getting our PE Modules 

Now that we have our vagrant and VMs squared away we need to get our moduels in line so that we can develop 
against them.  I went with using the local machine rather then 

- ability to use your favorite editor set up the way you like
- no need to worry about losing progress when doing vagrant destroy
- use all your Local Development Tools 

```
gem install r10k

```

