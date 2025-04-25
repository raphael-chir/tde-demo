Vagrant.configure("2") do |config|

  config.vm.define "vault" do |vault|
    vault.vm.box = "generic/rocky9"
    vault.vm.hostname = "vault"
    vault.vm.network "private_network", ip: "192.168.56.20"
    vault.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 2048
    end
    vault.vm.provision "shell", inline: <<-SHELL
      set -e
      bash /vagrant/01-install-vault.sh
    SHELL
  end

  config.vm.define "epas" do |epas|
    epas.vm.box = "generic/rocky9"
    epas.vm.hostname = "epas"
    epas.vm.network "private_network", ip: "192.168.56.22"
    epas.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 2048
    end
    epas.vm.provision "shell", inline: <<-SHELL
      set -e
      bash /vagrant/02-install-epas.sh
    SHELL
  end

  config.vm.define "pg" do |pg|
    pg.vm.box = "generic/rocky9"
    pg.vm.hostname = "pg"
    pg.vm.network "private_network", ip: "192.168.56.22"
    pg.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 2048
    end
    pg.vm.provision "shell", inline: <<-SHELL
      set -e
      bash /vagrant/03-install-pg.sh
    SHELL
  end

  # Shared folder
  config.vm.synced_folder ".", "/vagrant"
end