:realstart
if exist "C:\Program Files (x86)\Unowhy\Net 6 Runtime\version.txt" goto :check

goto :startInstall

:check
find "6.0.6" "C:\Program Files (x86)\Unowhy\Net 6 Runtime\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Unowhy\Net 6 Runtime" mkdir "C:\Program Files (x86)\Unowhy\Net 6 Runtime"
"%programfiles%\Unowhy\TO_INSTALL\dotnetruntime6\dotnetruntime6_installer.exe" /install /quiet /norestart && "%programfiles%\Unowhy\TO_INSTALL\dotnetruntime6\aspnetcoreruntime6_installer.exe" /install /quiet /norestart && "%programfiles%\Unowhy\TO_INSTALL\dotnetruntime6\windowsdesktopruntime6_installer.exe" /install /quiet /norestart && echo "6.0.6" > "C:\Program Files (x86)\Unowhy\Net 6 Runtime\version.txt"

if exist "C:\Program Files (x86)\Unowhy\Net 6 Runtime\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "6.0.6" "C:\Program Files (x86)\Unowhy\Net 6 Runtime\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\dotnetruntime6\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\dotnetruntime6\KO.ps1"
goto :done

:alreadyInstalled

:done
