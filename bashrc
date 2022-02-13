# shellcheck disable=SC1090
# SC1090: This is script is about dynamically sourcing every script under ~/.bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


# --- Functions

source_ordered_scripts() {
  for def_script in "$@"; do
    script_basename="$(basename "$def_script")"

    if [[ "$sourced_scripts" != *"$script_basename"* ]]; then
      source "$def_script"
      sourced_scripts+="${sourced_scripts+ }$script_basename"
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
  echo "ERROR: missing ~/.dotbashcfg file!"
else
  source ~/.dotbashcfg
fi

# Once base scripts and configuration variables have been evaluated,
# source other scripts in the appropriated order
source_ordered_scripts $(xargs -I % echo "$HOME/.bash/internal/aliases/%.sh" < ~/.bash/internal/order/earliest-scripts.txt)
source_ordered_scripts $(find ~/.bash/internal/aliases/ -name '*.sh' | grep -vFf ~/.bash/internal/order/latest-scripts.txt)
source_ordered_scripts $(find ~/.bash/**/aliases/ -name '*.sh' -not -path '*/internal/*' | \
  grep -E "/($(perl -le 'print join "|",@ARGV' "${DOTBASHCFG_ENABLED_FEATURES[@]}"))/")
source_ordered_scripts $(find ~/.bash/ -type f -path '*/completions/*' -name "*.sh")
source_ordered_scripts $(xargs -I % echo "$HOME/.bash/internal/aliases/%.sh" < ~/.bash/internal/order/latest-scripts.txt)

# Allow users to define supplementary aliases within ~/.bash_aliases (file or directory)
# These are evaluated as overriding scripts (i.e. once all other scripts have been processed)
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
elif [ -d ~/.bash_aliases ]; then
  for script in ~/.bash_aliases/*; do source "$script"; done
fi

# In the same way, allow users to define supplementary bash completions
_dotbashcfg_local_completion_dir="$HOME/.local/share/$CURRENT_SHELL-completion/completions"
if [ -d "$_dotbashcfg_local_completion_dir" ]; then
  # N.B. Doing this way since the "source" built-in function can't be called via a "find ... -exec ..." construct
  for script in "$_dotbashcfg_local_completion_dir"/*; do source "$script"; done
fi

