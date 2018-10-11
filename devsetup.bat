@ECHO OFF
@REM
@REM Install Chocolatey
CALL :banner "Installing Chocolatey Windows Package Manager"
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
echo "Done!"

@REM Install Dev Tools
CALL :banner "Installing Dev Tools....."
choco install -y datagrip fiddler filezilla linqpad mongodb nginx nodejs notepadplusplus paint.net postman putty mtputty etbrains-rider sysinternals sql-operations-studio sublimetext3 tortoisegit vscodechefdk    
::choco install git virtualbox virtualbox.extensionpack vagrant putty wget lxrunoffline tightvnc -y
echo "Done!"

:: Functions
:banner
@ECHO =================================================
@ECHO %~1
@ECHO =================================================
