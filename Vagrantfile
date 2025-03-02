require './modules/templates'
require './modules/providers'

servers = [
  {
    "name" => "server-0",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "10.0.0.100", "public" => nil },
    "ports" => []
  },
  {
    "name" => "server-1",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "10.0.0.110", "public" => nil },
    "ports" => []
  },
  {
    "name" => "server-2",
    "cpus" => "1",
    "memory" => "1024",
    "ip" => { "private" => "10.0.0.120", "public" => nil },
    "ports" => []
  }
]

agents = [
  {
    "name" => "agent-0",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.200", "public" => nil },
    "ports" => []
  },
  {
    "name" => "agent-1",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.210", "public" => nil },
    "ports" => []
  },
  {
    "name" => "agent-2",
    "cpus" => "1",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.220", "public" => nil },
    "ports" => []
  }
]

loadbalancers = [
  {
    "name" => "loadbalancer-0",
    "cpus" => "1",
    "disk" => "512MB",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.20", "public" => nil },
    "ports" => []
  },
  {
    "name" => "loadbalancer-1",
    "cpus" => "1",
    "disk" => "512MB",
    "memory" => "512",
    "ip" => { "private" => "10.0.0.30", "public" => nil },
    "ports" => []
  }
]

machines = servers + agents + loadbalancers

virtuals = {
  "servers" => { "ip" => "10.0.0.10", "mask" => "24", "router" => "10", "interface" => "eth1" }
}

shared = [
  { "host" => "./shared", "guest" => "/shared" }
]

Templates.process("./shared/templates", "./shared/templates/.results", {
  "machines" => machines,
  "virtuals" => virtuals
})

Vagrant.configure("2") do |config|
  machines.each do |spec|
    config.vm.define spec["name"] do |machine|
      machine.vm.box = "generic-x64/alpine319"

      machine.vm.box_download_options = { "ssl-revoke-best-effort" => true }

      machine.vm.hostname = spec["name"]

      machine.vm.network "private_network", ip: spec["ip"]["private"]

      spec["ports"].each do |port|
        machine.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
      end

      Providers.define(machine, spec, shared)

      machine.vm.provision "shell", keep_color: true, inline: <<-SHELL
        bash /shared/scripts/provision.sh hosts

        bash /shared/scripts/provision.sh swapoff

        bash /shared/scripts/provision.sh upgrade

        bash /shared/scripts/provision.sh dependencies

        bash /shared/scripts/provision.sh k3s #{virtuals["servers"]["ip"]} #{virtuals["servers"]["interface"]}
      SHELL

      machine.vm.provision "shell", keep_color: true, run: "always", inline: <<-SHELL
        bash /shared/scripts/provision.sh hosts

        bash /shared/scripts/provision.sh configs

        bash /shared/scripts/provision.sh services
      SHELL
    end
  end
end
