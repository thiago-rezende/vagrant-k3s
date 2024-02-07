.PHONY: up ssh halt destroy ssh attach

up:
	@echo "[ k8s ] starting cluster"
	@vagrant up --provider=virtualbox

halt:
	@echo "[ k8s ] stopping cluster"
	@vagrant halt

destroy:
	@echo "[ k8s ] destroying cluster"
	@vagrant destroy -f

ssh:
	@echo "[ k8s ] acessing cluster nodes"

	@echo "|> [ tmux ] handling multiplexer session"
	@echo "|--> [ delete ] destroying previous session"
	$(shell tmux 2>/dev/null kill-session -t k8s)

	@echo "|--> [ create ] creating current session"
	@tmux new-session -d -s k8s

	@echo "|--> [ window ] handling multiplexer windows"
	@echo "|----> [ rename ] renaming window '0' to 'servers'"
	@tmux rename-window -t k8s:0 servers

	@echo "|----> [ create ] creating window '1' with name 'workers'"
	@tmux new-window -t k8s -n workers

	@echo "|----> [ create ] creating window '2' with name 'loadbalancers'"
	@tmux new-window -t k8s -n loadbalancers

	@echo "|----> [ select ] selecting 'servers' window"
	@tmux select-window -t k8s:servers

	@echo "|> [ servers ] connecting to server nodes"
	@for server in $(shell cat Vagrantfile | grep -o "server-[0-9]"); do \
	echo "|--> [ session ] connecting to $$server node"; \
	tmux select-layout -t k8s:servers tiled; \
	tmux send-keys -t k8s:servers "vagrant ssh $$server" C-m "clear" C-m; \
	tmux split-window -t k8s:servers; \
	done
	@tmux send-keys -t k8s:servers "exit" C-m

	@echo "|> [ workers ] connecting to worker nodes"
	@for worker in $(shell cat Vagrantfile | grep -o "worker-[0-9]"); do \
	echo "|--> [ session ] connecting to $$worker node"; \
	tmux select-layout -t k8s:workers tiled; \
	tmux send-keys -t k8s:workers "vagrant ssh $$worker" C-m "clear" C-m; \
	tmux split-window -t k8s:workers; \
	done
	@tmux send-keys -t k8s:workers "exit" C-m

	@echo "|> [ loadbalancers ] connecting to loadbalancer nodes"
	@for loadbalancer in $(shell cat Vagrantfile | grep -o "loadbalancer-[0-9]"); do \
	echo "|--> [ session ] connecting to $$loadbalancer node"; \
	tmux select-layout -t k8s:loadbalancers tiled; \
	tmux send-keys -t k8s:loadbalancers "vagrant ssh $$loadbalancer" C-m "clear" C-m; \
	tmux split-window -t k8s:loadbalancers; \
	done
	@tmux send-keys -t k8s:loadbalancers "exit" C-m

	@echo "|> [ await ] waiting for all connections to settle"
	@sleep 10

	@echo "|> [ attach ] attaching to tmux session"
	@tmux attach-session -t k8s

attach:
	@echo "[ k8s ] attaching to tmux session"
	@tmux attach-session -t k8s
