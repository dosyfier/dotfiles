#!/bin/bash

# Cabal related aliases

if [[ ":$PATH:" != *":$HOME/.cabal/bin:"* ]]; then
  export PATH="$HOME/.cabal/bin:$PATH"
fi
