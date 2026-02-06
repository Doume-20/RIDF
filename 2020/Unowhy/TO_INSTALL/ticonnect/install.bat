:realstart
if exist "C:\Program Files (x86)\TexasInstruments\TIConnectCE\version.txt" goto :check

goto :startInstall

:check
find "3.4.1" "C:\Program Files (x86)\TexasInstruments\TIConnectCE\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\TexasInstruments\TIConnectCE" mkdir "C:\Program Files (x86)\TexasInstruments\TIConnectCE"
msiexec /i "%programfiles%\Unowhy\TO_INSTALL\ticonnect\ticonnect_installer.msi" /qb && echo "3.4.1" > "C:\Program Files (x86)\TexasInstruments\TIConnectCE\version.txt"

if exist "C:\Program Files (x86)\TexasInstruments\TIConnectCE\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.4.1" "C:\Program Files (x86)\TexasInstruments\TIConnectCE\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\ticonnect\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\ticonnect\KO.ps1"
goto :done

:alreadyInstalled

:done
