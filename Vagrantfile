require './modules/templates'

servers = [
  {
    "name" => "server-0",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "10.0.0.100", "public" => nil },
    "ports" => []
  }
]

workers = [
  {
    "name" => "worker-0",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.200", "public" => nil },
    "ports" => []
  }
]

loadbalancers = [
  {
    "name" => "loadbalancer-0",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.10", "public" => nil },
    "ports" => [
      # { "guest" => "80", "host" => "80" }
      # { "guest" => "443", "host" => "443" }
    ]
  }
]

machines = servers + workers + loadbalancers

Templates.process("./shared/templates", "./shared/templates/.results", {
  machines: machines,
  domain: "localhost"
})

Vagrant.configure("2") do |config|
  machines.each do |spec|
    config.vm.define spec["name"] do |machine|
      machine.vm.box = "generic/alpine319"

      machine.vm.box_download_options = { "ssl-revoke-best-effort" => true }

      machine.vm.hostname = spec["name"]

      unless spec["ip"]["public"].nil? || spec["ip"]["public"].empty?
        machine.vm.network "public_network", ip: spec["ip"]["public"]
      end

      machine.vm.network "private_network", ip: spec["ip"]["private"]

      spec["ports"].each do |port|
        machine.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
      end

      machine.vm.synced_folder "./shared", "/shared"

      machine.vm.provider "virtualbox" do |vbox|
        vbox.name = spec["name"]

        vbox.cpus = spec["cpus"]
        vbox.memory = spec["memory"]

        vbox.customize ["modifyvm", :id, "--groups", "/K8s"]
      end

      machine.vm.provision "shell", keep_color: true, inline: <<-SHELL
        bash /shared/scripts/provision.sh swapoff

        bash /shared/scripts/provision.sh upgrade

        bash /shared/scripts/provision.sh dependencies

        if [ $(hostname | grep -oE '[0-9]$') = '0' ]; then
          bash /shared/scripts/certificates.sh $(hostname | grep -oE '^[a-z]+')s
        fi
      SHELL

      machine.vm.provision "shell", keep_color: true, run: "always", inline: <<-SHELL
        bash /shared/scripts/provision.sh hosts

        bash /shared/scripts/provision.sh configs

        bash /shared/scripts/provision.sh services
      SHELL
    end
  end
end
