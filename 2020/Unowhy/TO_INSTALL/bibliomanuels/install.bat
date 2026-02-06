:realstart
if exist "C:\Program Files (x86)\Unowhy\Biblio Manuels\version.txt" goto :check

goto :startInstall

:check
find "3.11.0" "C:\Program Files (x86)\Unowhy\Biblio Manuels\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Unowhy\Biblio Manuels" mkdir "C:\Program Files (x86)\Unowhy\Biblio Manuels"
"%programfiles%\Unowhy\TO_INSTALL\bibliomanuels\bibliomanuels_installer.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- && echo "3.11.0" > "C:\Program Files (x86)\Unowhy\Biblio Manuels\version.txt"

if exist "C:\Program Files (x86)\Unowhy\Biblio Manuels\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.11.0" "C:\Program Files (x86)\Unowhy\Biblio Manuels\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\bibliomanuels\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\bibliomanuels\KO.ps1"
goto :done

:alreadyInstalled

:done
