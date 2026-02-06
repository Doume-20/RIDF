:realstart
if exist "C:\Program Files (x86)\Pronote\version.txt" goto :check

goto :startInstall

:check
find "0.2.7" "C:\Program Files (x86)\Pronote\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Pronote" mkdir "C:\Program Files (x86)\Pronote"
"%programfiles%\Unowhy\TO_INSTALL\pronote\pronote_installer.exe" -s -f1"%programfiles%\Unowhy\TO_INSTALL\pronote\ClientPRONOTE.iss" && echo "0.2.7" > "C:\Program Files (x86)\Pronote\version.txt"

if exist "C:\Program Files (x86)\Pronote\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "0.2.7" "C:\Program Files (x86)\Pronote\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\pronote\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\pronote\KO.ps1"
goto :done

:alreadyInstalled

:done
