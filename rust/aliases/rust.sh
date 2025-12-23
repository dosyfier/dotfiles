#!/bin/bash

# Rust related aliases

if ! command -v cargo > /dev/null && [ -f "$HOME/.cargo/env" ]; then
  # shellcheck disable=SC1091 # Source can't be followed
  source "$HOME/.cargo/env"
fi


