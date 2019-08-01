Set oWS = WScript.CreateObject("WScript.Shell")
userHome = oWS.ExpandEnvironmentStrings("%USERPROFILE%")
sLinkFile = userHome + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Terminator.LNK"
Set oLink = oWS.CreateShortcut(sLinkFile)
    oLink.TargetPath = "wscript.exe"
    oLink.Arguments = "vbs\start_terminator.vbs"
    oLink.Description = "Terminator"
    oLink.HotKey = "ALT+CTRL+T"
    oLink.IconLocation = WScript.Arguments(0) + "\icons\terminator.ico"
    oLink.WindowStyle = "1"
    oLink.WorkingDirectory = WScript.Arguments(0)
oLink.Save
