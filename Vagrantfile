machines = [
  { "name" => "server-0", "cpus" => "1", "memory" => "1024",  "ip" => { "private" => "10.0.0.10", "public" => "192.168.2.10" }, "ports" => [] },
  { "name" => "worker-0", "cpus" => "1", "memory" => "1024",  "ip" => { "private" => "10.0.0.20", "public" => "192.168.2.20" }, "ports" => [] }
]

Vagrant.configure("2") do |config|
  machines.each do |spec|
    config.vm.define spec["name"] do |machine|
      machine.vm.box = "bento/ubuntu-22.04"

      config.vm.box_download_options = { "ssl-revoke-best-effort" => true }
  
      machine.vm.hostname = spec["name"]
  
      unless spec["ip"]["public"].nil?
        machine.vm.network "public_network", ip: spec["ip"]["public"]
      end
  
      machine.vm.network "private_network", ip: spec["ip"]["private"]
  
      spec["ports"].each do |port|
        machine.vm.network "forwarded_port", guest: port, host: port
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
