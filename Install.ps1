#Requires -RunAsAdministrator

#
# API-Enabler is a script tool to install and patch NetLimiter for API beginners.
# It is design by the Genius Warlock who also developed Final Solution.
#
# This script is licensed under WTFPL.
# Feel free to do anything.
#


#
#                  DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                          Version 2, December 2004
#
#       Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
#
#       Everyone is permitted to copy and distribute verbatim or modified
#       copies of this license document, and changing it is allowed as long
#       as the name is changed.
#
#                  DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#         TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#        0. You just DO WHAT THE FUCK YOU WANT TO.
#

Write-Host "API-Enabler v1.0 by the Genius Warlock" -BackgroundColor Green

# configurations

# this is the title of the console when running this script
# I hope that you don't change this. but whatever.
$TITLE = "API-Enabler by the Genius Warlock"

# this is the prefix of the script outputs, no trailling space.
$LOG_LABEL = "[API-Enabler]"

# this is the version of the NetLimiter.
# I prefer 5.2.6.0 as my works are based on it.
# you can change to whatever you wanted if existent.
$NL_VERSION = "5.2.6.0"

# don't modify! this is the default installer download url.
$NL_DOWNLOAD_URL = "https://www.netlimiter.com/files/download/nl/netlimiter-$NL_VERSION.exe"
# don't modify! this is the default installer exe name.
$NL_INSTALLER_PATH = "netlimiter-$NL_VERSION.exe"

# this is the folder that contains all the patching DLL files, like "NLClientApp.Core.dll" or "NetLimiter.dll".
$NL_PATCH_PATH = "./patch"

# this is the installation folder of NetLimiter.
# by default, it is located here on my environment.
# I did not test on other computers, but I believe it is the only path.
$NL_INSTALLATION_PATH = "C:\Program Files\Locktime Software\NetLimiter"

# configuration end

$host.UI.RawUI.WindowTitle = $TITLE

# don't modify!
# the phase argument is used to control the script entry
# default is empty.
# "/retry" is used to continue the patching phase after installation.
$PHASE = $args[0]

#
# request admin privilege
#
# this part the script requires the administrator privileges, because both installation and patching (stop and restart the service)
# requires it.
#

$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -match "S-1-5-32-544")
if (-Not ($isAdmin))
{
    Write-Error "You need elevated privileges to run this script!"
    exit(1)
}

#
# function definitions
#

function InstallNetLimiter
{

    # download installer if not existent
    if (!(Test-Path $NL_INSTALLER_PATH))
    {
        try
        {
            Write-Host "$LOG_LABEL Downloading NetLimiter $NL_VERSION Installer"
            Invoke-WebRequest -Uri $NL_DOWNLOAD_URL -OutFile $NL_INSTALLER_PATH
        }
        catch
        {
            Write-Host $_.Exception.Message -ForegroundColor Red
            Write-Host "$LOG_LABEL Failed to download NetLimiter Installer." -ForegroundColor Red
            exit(1)
        }
    }
    # or print ok if installer is there
    else
    {
        Write-Host "$LOG_LABEL NetLimiter $NL_VERSION Installer Found! Skipping download." -ForegroundColor Gray
    }

    # install the hive magic
    try
    {
        Write-Host "$LOG_LABEL Starting Installer Background. Please be patient."
        Write-Host "$LOG_LABEL If UAC prompt window pops, please select Yes." -ForegroundColor Yellow
        Start-Process -FilePath "./$NL_INSTALLER_PATH" -ArgumentList "/exenoui /qn /norestart /l*v installer.log" -Wait -Verb RunAs
        Write-Host "$LOG_LABEL Installation has ended successfully." -ForegroundColor Green
    }
    # print error messages if installation is failed
    catch
    {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "$LOG_LABEL Installation Failed! Please try again. If this happens continuously, please contact the author." -ForegroundColor Red
        exit(1)
    }
}

function PatchNetLimiter
{
    # stop the service nlsvc
    try
    {
        # stop the service only if running
        if ((Get-Service -Name "nlsvc").Status -eq "Running")
        {
            Write-Host "$LOG_LABEL Stopping NLSVC for patching."
            Stop-Service -Name "nlsvc"
        }
        else
        {
            Write-Host "$LOG_LABEL NLSVC is not running. This is wierd, but ok." -ForegroundColor Yellow
        }
    }
    # print error messages if failed to stop the service
    catch
    {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "$LOG_LABEL Failed to stop NLSVC. See https://github.com/Taskeren/API-Enabler/ for help." -ForegroundColor Red
        exit(1)
    }

    # print debug messages
    Write-Host "$LOG_LABEL Patching NetLimiter"
    Write-Host "$LOG_LABEL Patch Src: $NL_PATCH_PATH" -ForegroundColor Gray
    Write-Host "$LOG_LABEL Patch Dest: $NL_INSTALLATION_PATH" -ForegroundColor Gray
    try
    {
        # apply patching files
        Copy-Item -Path $NL_PATCH_PATH -Destination $NL_INSTALLATION_PATH -Recurse -Force
        # rename the main app if exists
        if(Test-Path "$NL_INSTALLATION_PATH/NLClientApp.exe") {
            Move-Item -Path "$NL_INSTALLATION_PATH/NLClientApp.exe" -Destination "$NL_INSTALLATION_PATH/NL.exe" -Force
        }
        Write-Host "$LOG_LABEL NetLimiter Patched"
        Write-Host "$LOG_LABEL Notice that NLClientApp.exe, the NetLimiter application, has renamed to NL.exe for BattlEye bypass." -ForegroundColor Yellow
        Write-Host "$LOG_LABEL The shortcut in the Desktop is incorrect, and you need to replace it with correct one." -ForegroundColor Yellow
        Write-Host "$LOG_LABEL Also notice that DO NOT open the installtion folder when playing game, because it is called NetLimiter." -ForegroundColor Yellow
    }
    # print error message if failed to patch
    catch
    {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "$LOG_LABEL Patching Failed!" -ForegroundColor Red
    }

    # restart the service nlsvc
    try
    {
        # restart only if not running
        if((Get-Service -Name "nlsvc").Status -ne "Running")
        {
            Write-Host "$LOG_LABEL Starting NLSVC."
            Start-Service -Name "nlsvc"
        }
        else
        {
            Write-Host "$LOG_LABEL NLSVC is running? How? This could be the problem causing patching failure." -ForegroundColor Yellow
        }
    }
    # print error message if failed to start
    # also tell the user that he/she can start the service manually
    catch
    {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "$LOG_LABEL Failed to start NLSVC! You can type 'net start nlsvc' in command prompt to start it manually." -ForegroundColor Red
        exit(1)
    }
}

#
# main
#

if ($PHASE -eq "/patch")
{
    Write-Host "$LOG_LABEL Installation is skipped." -ForegroundColor Gray
    PatchNetLimiter
}
else
{
    InstallNetLimiter
    PatchNetLimiter
}

Write-Host "$LOG_LABEL API-Enabler has reached the End." -BackgroundColor Green

