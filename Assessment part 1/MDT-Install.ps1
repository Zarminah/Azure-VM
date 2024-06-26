
#Define the path of the installer

$MDTInstallerPath = "C:\Users\Administrator\Desktop\ADK\MicrosoftDeploymentToolkit_x64.msi"

$ADKInstallerPath = "C:\Users\Administrator\Desktop\ADK\adksetup.exe"

$WinPEInstallerPath = "C:\Users\Administrator\Desktop\ADK\adkwinpesetup.exe"
 
# Install MDT

Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$ADKinstallerPath`" /quiet /norestart" -Wait

# Install ADK

Start-Process -FilePath $ADKInstallerPath -ArgumentList "/quiet /norestart" -Wait

# Install WinPE

Start-Process -FilePath $WinPEInstallerPath -ArgumentList "/quiet /norestart" -Wait
