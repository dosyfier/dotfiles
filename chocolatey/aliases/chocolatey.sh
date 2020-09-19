#!/bin/bash

DOTBASHCFG_CHOCO_CONFIG=~/.bash/chocolatey/conf/packages.config

dotbashcfg_choco_inst() {
  choco install "$(wslpath $DOTBASHCFG_CHOCO_CONFIG)"
}

dotbashcfg_choco_up() {
  choco upgrade all
}
