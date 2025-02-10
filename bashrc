# shellcheck disable=SC1090 # This is script is about dynamically sourcing every script under ~/.bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Force the shell to be a ZSH, even if another one is defined by default for the current user
! [ -v ZSH_NAME ] && [ -e /bin/zsh ] && ! [ "${FORCE_BASH:-}" = true ] && exec /bin/zsh


# --- Functions

source_ordered_scripts() {
  local sourced_scripts
  while read -r script; do
    script_abspath="$(readlink -f "$script")"

    if [[ ":$sourced_scripts:" =~ :$script_abspath: ]]; then
      echo "WARNING: Following script has already been sourced: $script_abspath" >&2
      echo "WARNING: It won't be sourced once again" >&2
    else
      source "$script_abspath"
      sourced_scripts+="${sourced_scripts+:}$script_abspath"
    fi
  done
}


# --- Script core

# First, evaluate any global scripts packaged with OS distribution
_dotbashcfg_dist_sourced_scripts="/etc/bashrc /etc/bash.bashrc /etc/bash_completion"
for script in $_dotbashcfg_dist_sourced_scripts; do
  { [ -f "$script" ] || [ -L "$script" ]; } && source "$script"
done

# Then, evaluate dotbashconfig project's configuration script
if ! [ -f ~/.dotbashcfg ]; then
  echo "ERROR: missing ~/.dotbashcfg file!" >&2
else
  source ~/.dotbashcfg
fi

# Once base scripts and configuration variables have been evaluated,
# source other scripts in the appropriated order
{
  # - Internal scripts to be sourced in earliest order
  xargs -I % echo "$HOME/.bash/internal/aliases/%.sh" < ~/.bash/internal/order/earliest-scripts.txt
  # - Internal scripts without specific ordering for sourcing
  find ~/.bash/internal/aliases/ -name '*.sh' | grep -vF \
    -f ~/.bash/internal/order/earliest-scripts.txt -f ~/.bash/internal/order/latest-scripts.txt
  # - Feature-specific scripts, to be sourced when the associated feature is enabled
  find ~/.bash/**/aliases/ -name '*.sh' -not -path '*/internal/*' | \
    grep -E "/($(perl -le 'print join "|",@ARGV' "${DOTBASHCFG_ENABLED_FEATURES[@]}"))/"
  # - Shell completion scripts
  find ~/.bash/ -type f -path '*/completions/*' -name "*.sh"
  # - Internal scripts to be sourced after all others
  xargs -I % echo "$HOME/.bash/internal/aliases/%.sh" < ~/.bash/internal/order/latest-scripts.txt
} \
  | source_ordered_scripts

# Allow users to define supplementary aliases within ~/.bash_aliases file or ~/.bash_aliases.d directory
# These are evaluated as overriding scripts (i.e. once all other scripts have been processed)
if [ -d ~/.bash_aliases.d/ ]; then
  for script in ~/.bash_aliases.d/*; do source "$script"; done
fi
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

# In the same way, allow users to define supplementary bash completions
_dotbashcfg_local_completion_dir="$HOME/.local/share/$CURRENT_SHELL-completion/completions"
if [ -d "$_dotbashcfg_local_completion_dir" ]; then
  # N.B. Doing this way since the "source" built-in function can't be called via a "find ... -exec ..." construct
  for script in "$_dotbashcfg_local_completion_dir"/*; do source "$script"; done
fi

