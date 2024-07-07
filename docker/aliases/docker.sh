# Docker shell aliases

run_docker_wsl1() {
  # See https://github.com/Microsoft/WSL/issues/2291#issuecomment-477632663
  # Setup cgroups mounts on the subsystem (this only needs to be done once per reboot,
  # and for WSL1 only)
  sudo cgroupfs-mount
  # Start Docker service
  sudo service docker start
}

alias dk="docker"
alias dk_run_blank="docker run -ti --rm \
-v ~/.bash/docker/conf/run-in-preferred-shell.sh:/usr/local/bin/run-in-preferred-shell:ro \
--entrypoint run-in-preferred-shell"
