args = "~" & "-d" & "Ubuntu" & "terminator"
WScript.CreateObject("Shell.Application").ShellExecute "wslg", args, "", "open", 0
