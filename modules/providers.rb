class Providers
  def self.define(machine, spec, shared)
    self.define_libvirt(machine, spec, shared)

    self.define_virtualbox(machine, spec, shared)
  end

  def self.define_libvirt(machine, spec, shared)
    machine.vm.provider "virtualbox" do |libvirt|
      libvirt.title = spec["name"]
      libvirt.default_prefix = ""

      libvirt.cpus = spec["cpus"]
      libvirt.memory = spec["memory"]
      libvirt.cputopology :sockets => '1', :cores => spec["cpus"], :threads => '1'

      shared.each do |folder|
        machine.vm.synced_folder folder["host"], folder["guest"], type: "rsync"
      end
    end
  end

  def self.define_virtualbox(machine, spec, shared)
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = spec["name"]

      vbox.cpus = spec["cpus"]
      vbox.memory = spec["memory"]

      shared.each do |folder|
        machine.vm.synced_folder folder["host"], folder["guest"]
      end

      unless spec["ip"]["public"].nil? || spec["ip"]["public"].empty?
        machine.vm.network "public_network", ip: spec["ip"]["public"]
      end

      if spec["name"].include? "server"
        vbox.customize ["modifyvm", :id, "--groups", "/cluster/servers"]
      end

      if spec["name"].include? "agent"
        vbox.customize ["modifyvm", :id, "--groups", "/cluster/agents"]
      end
    end
  end
end
