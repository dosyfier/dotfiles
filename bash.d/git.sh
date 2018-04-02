#!/bin/bash

git_branch_name() {
  git symbolic-ref HEAD --short 2> /dev/null
}

PS1="${PS1%\\\$*}$Yellow\$(git_branch_name | sed 's/\(\S\+\)/ \(\1\) /')$NC\$ "

