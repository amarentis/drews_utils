@ECHO OFF
@REM
@REM Author: Andrew Marentis <amarentis@gmail.com>
@REM Date: 5-31-2016
@REM Runas Administrator
@REM 
@REM Sets up basic Chef Dev environment and a few handy tools 

@REM Install Chocolatey
CALL :banner "Installing Chocolatey Windows Package Manager"
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
echo "Done!"

@REM Install Dev Tools
CALL :banner "Installing Dev Tools....."
choco install git virtualbox virtualbox.extensionpack vagrant docker filezilla chefdk putty gradle wget notepadplusplus fiddler4 choco sublimetext3 -y
echo "Done!"

@REM Install Vagrant Plugins
CALL :banner "Installing additional required vagrant plugins needed on windows"
vagrant plugin install vagrant-omnibus
echo "Done!"

:: Functions
:banner
@ECHO =================================================
@ECHO %~1
@ECHO =================================================
