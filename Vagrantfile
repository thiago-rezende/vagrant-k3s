plugins = [
  "vagrant-disksize",
  "vagrant-timezone"
]

plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise "#{plugin} is not installed!"
  end
end

machines = [
  {
    "name" => "server-0",
    "cpus" => "1",
    "memory" => "1024",
    "disk" => "100G",
    "tz" => "America/Sao_Paulo",
    "ip" => { "private" => "10.0.0.10", "public" => "192.168.2.10" },
    "ports" => [
      # { "guest" => "80", "host" => "80" }
    ]
  },
  {
    "name" => "worker-0",
    "cpus" => "1",
    "memory" => "1024",
    "disk" => "100G",
    "tz" => "America/Sao_Paulo",
    "ip" => { "private" => "10.0.0.10", "public" => "192.168.2.10" },
    "ports" => [
      # { "guest" => "80", "host" => "80" }
    ]
  }
]

Vagrant.configure("2") do |config|
  machines.each do |spec|
    config.vm.define spec["name"] do |machine|
      machine.vm.box = "bento/ubuntu-22.04"

      machine.vm.box_download_options = { "ssl-revoke-best-effort" => true }
  
      machine.vm.hostname = spec["name"]

      machine.timezone.value = spec["tz"]

      machine.disksize.size = spec["disk"]
  
      unless spec["ip"]["public"].nil?
        machine.vm.network "public_network", ip: spec["ip"]["public"]
      end
  
      machine.vm.network "private_network", ip: spec["ip"]["private"]
  
      spec["ports"].each do |port|
        machine.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
      end
  
      machine.vm.synced_folder "./shared", "/opt/shared"
  
      machine.vm.provider "virtualbox" do |vb|
        vb.name = spec["name"]
  
        vb.cpus = spec["cpus"]
        vb.memory = spec["memory"]
      end
      
      machine.vm.provision "shell", inline: <<-SHELL
        chmod 755 /opt/shared/provision.sh
      
        bash /opt/shared/provision.sh upgrade
      SHELL
    end
  end  
end
