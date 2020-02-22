#!/bin/bash

run_docker() {
  # Setup cgroups mounts on the subsystem (this only needs to be done once per reboot)
  sudo cgroupfs-mount
  # Start Docker service
  sudo service docker start
}
