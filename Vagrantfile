require 'erb'

machines = [
  {
    "name" => "server-0",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "192.168.56.10", "public" => nil },
    "ports" => [
      # { "guest" => "80", "host" => "80" }
    ]
  },
  {
    "name" => "worker-0",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "192.168.56.20", "public" => nil },
    "ports" => []
  }
]

templates_dir = "./shared/templates"
templates_build_dir = templates_dir + "/.build"

Dir.mkdir(templates_build_dir) unless File.exists?(templates_build_dir)

templates = Dir.glob(templates_dir + "/*.erb")

templates.each do |template|
  template_erb = ERB.new(File.read(template), trim_mode: "-")

  File.write(templates_build_dir + "/" + File.basename(template, ".*"), template_erb.result(binding))
end

Vagrant.configure("2") do |config|
  machines.each do |spec|
    config.vm.define spec["name"] do |machine|
      machine.vm.box = "bento/ubuntu-22.04"

      machine.vm.box_download_options = { "ssl-revoke-best-effort" => true }
  
      machine.vm.hostname = spec["name"]

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

      machine.vm.provision "shell", run: "always", inline: <<-SHELL
        bash /opt/shared/provision.sh hosts
      SHELL
    end
  end  
end
