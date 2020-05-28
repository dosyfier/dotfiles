Set oWS = WScript.CreateObject("WScript.Shell")
userHome = oWS.ExpandEnvironmentStrings("%USERPROFILE%")
args = "-c" & " -l " & """source ~/.bash/internal/aliases/distro.sh; cd `$WIN_HOME; terminator"""
WScript.CreateObject("Shell.Application").ShellExecute "bash", args, "", "open", 0
