.PHONY: up provision halt reload destroy status ssh attach

up:
	@echo "[ cluster ] starting cluster"
	@vagrant up

provision:
	@echo "[ cluster ] starting cluster"
	@vagrant up --provision

halt:
	@echo "[ cluster ] stopping cluster"
	@vagrant halt

reload:
	@echo "[ cluster ] reloading cluster"
	@vagrant reload

destroy:
	@echo "[ cluster ] destroying cluster"
	@vagrant destroy -f

status:
	@echo "[ cluster ] cluster nodes status"
	@vagrant status | grep -o --color=never -E '(server|agent).*' \
	 | tr -d \(\) | xargs -L1 printf "|> [ node ] %s\n|--> [ status ] %s\n|--> [ provider ] %s\n"

ssh:
	@echo "[ cluster ] acessing cluster nodes"

	@echo "|> [ tmux ] handling multiplexer session"
	@echo "|--> [ delete ] destroying previous session"
	$(shell tmux 2>/dev/null kill-session -t cluster)

	@echo "|--> [ create ] creating current session"
	@tmux new-session -d -s cluster

	@echo "|--> [ window ] handling multiplexer windows"
	@echo "|----> [ rename ] renaming window '0' to 'servers'"
	@tmux rename-window -t cluster:0 servers

	@echo "|----> [ create ] creating window '1' with name 'agents'"
	@tmux new-window -t cluster -n agents

	@echo "|----> [ create ] creating window '2' with name 'loadbalancers'"
	@tmux new-window -t cluster -n loadbalancers

	@echo "|----> [ select ] selecting 'servers' window"
	@tmux select-window -t cluster:servers

	@echo "|> [ servers ] connecting to server nodes"
	@for server in $(shell cat Vagrantfile | grep -o "server-[0-9]"); do \
	echo "|--> [ session ] connecting to $$server node"; \
	tmux select-layout -t cluster:servers tiled; \
	tmux send-keys -t cluster:servers "vagrant ssh $$server" C-m "clear" C-m; \
	tmux split-window -t cluster:servers; \
	done
	@tmux send-keys -t cluster:servers "exit" C-m

	@echo "|> [ agents ] connecting to agent nodes"
	@for agent in $(shell cat Vagrantfile | grep -o "agent-[0-9]"); do \
	echo "|--> [ session ] connecting to $$agent node"; \
	tmux select-layout -t cluster:agents tiled; \
	tmux send-keys -t cluster:agents "vagrant ssh $$agent" C-m "clear" C-m; \
	tmux split-window -t cluster:agents; \
	done
	@tmux send-keys -t cluster:agents "exit" C-m

	@echo "|> [ loadbalancers ] connecting to loadbalancer nodes"
	@for loadbalancer in $(shell cat Vagrantfile | grep -o "loadbalancer-[0-9]"); do \
	echo "|--> [ session ] connecting to $$loadbalancer node"; \
	tmux select-layout -t cluster:loadbalancers tiled; \
	tmux send-keys -t cluster:loadbalancers "vagrant ssh $$loadbalancer" C-m "clear" C-m; \
	tmux split-window -t cluster:loadbalancers; \
	done
	@tmux send-keys -t cluster:loadbalancers "exit" C-m


	@echo "|> [ await ] waiting for all connections to settle"
	@sleep 10

	@echo "|> [ attach ] attaching to tmux session"
	@tmux attach-session -t cluster

attach:
	@echo "[ cluster ] attaching to tmux session"
	@tmux attach-session -t cluster
