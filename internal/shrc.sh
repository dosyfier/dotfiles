# vim: set ft=bash
# shellcheck disable=SC1090 # This is script is about dynamically sourcing every script under ~/.shell

# ~/.<SHELL>rc: executed for non-login shells by the shell implementation used.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples.

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Force the shell to be a ZSH, even if another one is defined by default for the current user
! [ -v ZSH_NAME ] && [ -e /bin/zsh ] && ! [ "${FORCE_BASH:-}" = true ] && exec /bin/zsh


# -- Constants -- #

DOTFILES_ENV_FILE=$HOME/.dotfiles.env


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
_dotfiles_dist_sourced_scripts="/etc/*shrc /etc/*sh_completion"
for script in $_dotfiles_dist_sourced_scripts; do
  { [ -f "$script" ] || [ -L "$script" ]; } && source "$script"
done

# Then, evaluate dotfiles project's configuration script
if ! [ -f "$DOTFILES_ENV_FILE" ]; then
  echo "ERROR: missing $DOTFILES_ENV_FILE file!" >&2
  return
else
  source "$DOTFILES_ENV_FILE"
fi

# Once base scripts and configuration variables have been evaluated,
# source other scripts in the appropriated order
{
  # - Internal scripts to be sourced in earliest order
  xargs -I % echo "$DOTFILES_DIR/internal/aliases/%.sh" < $DOTFILES_DIR/internal/order/earliest-scripts.txt
  # - Internal scripts without specific ordering for sourcing
  find $DOTFILES_DIR/internal/aliases/ -name '*.sh' | grep -vF \
    -f $DOTFILES_DIR/internal/order/earliest-scripts.txt -f $DOTFILES_DIR/internal/order/latest-scripts.txt
  # - Feature-specific scripts, to be sourced when the associated feature is enabled
  find $DOTFILES_DIR/**/aliases/ -name '*.sh' -not -path '*/internal/*' | \
    grep -E "/($(perl -le 'print join "|",@ARGV' "${DOTFILES_ENABLED_FEATURES[@]}"))/"
  # - Shell completion scripts
  find $DOTFILES_DIR/ -type f -path '*/completions/*' -name "*.sh"
  # - Internal scripts to be sourced after all others
  xargs -I % echo "$DOTFILES_DIR/internal/aliases/%.sh" < $DOTFILES_DIR/internal/order/latest-scripts.txt
} \
  | source_ordered_scripts

# Allow users to define supplementary aliases within ~/.shell_aliases file or ~/.shell_aliases.d directory
# These are evaluated as overriding scripts (i.e. once all other scripts have been processed)
if [ -d ~/.shell_aliases.d/ ]; then
  for script in ~/.shell_aliases.d/*; do source "$script"; done
fi
if [ -f ~/.shell_aliases ]; then
  source ~/.shell_aliases
fi

# In the same way, allow users to define supplementary shell completions
_dotfiles_local_completion_dir="$HOME/.local/share/$CURRENT_SHELL-completion/completions"
if [ -d "$_dotfiles_local_completion_dir" ]; then
  # N.B. Doing this way since the "source" built-in function can't be called via a "find ... -exec ..." construct
  for script in "$_dotfiles_local_completion_dir"/*; do source "$script"; done
fi

