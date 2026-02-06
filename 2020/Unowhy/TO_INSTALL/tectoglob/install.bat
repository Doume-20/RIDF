:realstart
if exist "%userprofile%\AppData\Local\Programs\Tectoglob\version.txt" goto :check

goto :startInstall

:check
find "1.47" "%userprofile%\AppData\Local\Programs\Tectoglob\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\Tectoglob" mkdir "%userprofile%\AppData\Local\Programs\Tectoglob"
"%programfiles%\Unowhy\TO_INSTALL\tectoglob\tectoglob_installer.exe" /VERYSILENT && echo "1.47" > "%userprofile%\AppData\Local\Programs\Tectoglob\version.txt"

if exist "%userprofile%\AppData\Local\Programs\Tectoglob\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "1.47" "%userprofile%\AppData\Local\Programs\Tectoglob\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\tectoglob\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\tectoglob\KO.ps1"
goto :done

:alreadyInstalled

:done
