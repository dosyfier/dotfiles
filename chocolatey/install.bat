@echo off

WHERE choco.exe
IF %ERRORLEVEL% EQU 0 goto :install_packages

:install_choco
echo Installing Chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile ^
    -InputFormat None -ExecutionPolicy Bypass ^
    -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
    && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:install_packages
echo Installing Packages...
choco install %~dp0\conf\packages.config

IF %ERRORLEVEL% EQU 0 echo Done! Your Windows OS is fully configured!
