args = "-c" & " -l " & """source ~/.bash/internal/aliases/distro.sh; cd $WIN_HOME; terminator -m"""
WScript.CreateObject("Shell.Application").ShellExecute "bash", args, "", "open", 0
