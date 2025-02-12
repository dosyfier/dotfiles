args = "-c" & " -l " & """source ~/.dotfiles.env; source $DOTFILES_DIR/internal/aliases/distro.sh; cd $WIN_HOME; terminator -m"""
WScript.CreateObject("Shell.Application").ShellExecute "bash", args, "", "open", 0
