@echo off

REM Based on https://stackoverflow.com/questions/4051883/batch-script-how-to-check-for-admin-rights
:check_permissions
net session >nul 2>&1
if not %errorLevel% == 0 (
    echo Please run this script from an elevated shell.
    goto :end
)

:init
set /p choco_config=<%~dp0\conf\default-config.txt
if not %errorLevel% == 0 goto :end
goto :parse_opts

:usage
echo Usage: install.bat {CHOCO_CONFIG}
echo where {CHOCO_CONFIG} may be "home" or "work".
echo (default: %choco_config%)
set errorlevel=1
goto :end

:parse_opts
if not "%1" == "" if not "%1" == "home" if not "%1" == "work" goto :usage
if not "%2" == "" goto :usage
if not "%1" == "" set choco_config=%1
goto :install_start

:install_start
WHERE choco.exe
IF %errorlevel% EQU 0 (
    echo Chocolatey detected. Skipping install.
    goto :install_packages
)

:install_choco
echo Installing Chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile ^
    -InputFormat None -ExecutionPolicy Bypass ^
    -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
    && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
if not %errorLevel% == 0 goto :end

:install_packages
echo Installing Packages (configuration set: %choco_config%)...
choco install %~dp0\conf\packages-%choco_config%.config
if not %errorLevel% == 0 goto :end

echo Done! Your Windows OS is fully configured!

:end
echo.
exit /b %errorlevel%

