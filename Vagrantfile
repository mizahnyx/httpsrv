# vagrant box add vivid https://cloud-images.ubuntu.com/vagrant/vivid/current/vivid-server-cloudimg-amd64-vagrant-disk1.box
Vagrant.configure(2) do |config|
  config.vm.box = "vivid"
  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.synced_folder "./source", "/home/vagrant/source"
   config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
   end
   config.vm.provision "shell", inline: <<-SHELL
     wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
     sudo apt-key add erlang_solutions.asc
     sudo apt-get update
     sudo apt-get -y install erlang rebar git
   SHELL
end
