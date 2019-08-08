#!/bin/bash

# Create aliases for each Chocolatey program beginning with a 'c'
# (choco, cinst, clist, ...)
if [ -d /mnt/c/ProgramData/chocolatey/bin/ ]; then
  for choco_bin in /mnt/c/ProgramData/chocolatey/bin/c*; do
    choco_name=$(basename "$choco_bin")
    alias "${choco_name/.exe/}"="$choco_bin"
  done
fi

DOTBASHCFG_CHOCO_CONFIG=~/.bash/chocolatey/conf/packages.config

dotbashcfg_choco_inst() {
  choco install "$(wslpath $DOTBASHCFG_CHOCO_CONFIG)"
}

dotbashcfg_choco_up() {
  choco upgrade "$(wslpath $DOTBASHCFG_CHOCO_CONFIG)"
}
