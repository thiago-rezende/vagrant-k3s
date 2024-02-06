require 'erb'

machines = [
  {
    "name" => "loadbalancer-0",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "192.168.56.10", "public" => nil },
    "ports" => [
      # { "guest" => "80", "host" => "80" }
      # { "guest" => "443", "host" => "443" }
    ]
  },
  {
    "name" => "server-0",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "192.168.56.110", "public" => nil },
    "ports" => []
  },
  {
    "name" => "worker-0",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "192.168.56.210", "public" => nil },
    "ports" => []
  }
]

templates_dir = "./shared/templates"
templates_results_dir = templates_dir + "/.results"

Dir.mkdir(templates_results_dir) unless File.exists?(templates_results_dir)

templates = Dir.glob(templates_dir + "/*.erb")

templates.each do |template|
  template_erb = ERB.new(File.read(template), trim_mode: "-")

  File.write(templates_results_dir + "/" + File.basename(template, ".*"), template_erb.result(binding))
end

Vagrant.configure("2") do |config|
  machines.each do |spec|
    config.vm.define spec["name"] do |machine|
      machine.vm.box = "ubuntu/jammy64"

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
      
      machine.vm.provision "shell", keep_color: true, inline: <<-SHELL
        chmod 755 /opt/shared/scripts/provision.sh
      
        bash /opt/shared/scripts/provision.sh upgrade

        bash /opt/shared/scripts/provision.sh dependencies
      SHELL

      machine.vm.provision "shell", keep_color: true, run: "always", inline: <<-SHELL
        bash /opt/shared/scripts/provision.sh hosts

        bash /opt/shared/scripts/provision.sh configs
      SHELL
    end
  end  
end
