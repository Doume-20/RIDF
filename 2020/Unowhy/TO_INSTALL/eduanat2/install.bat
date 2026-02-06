:realstart
if exist "%userprofile%\AppData\Local\Programs\IFE\EduAnat2\version.txt" goto :check

goto :startInstall

:check
find "2.0.0" "%userprofile%\AppData\Local\Programs\IFE\EduAnat2\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "%userprofile%\AppData\Local\Programs\IFE\EduAnat2" mkdir "%userprofile%\AppData\Local\Programs\IFE\EduAnat2"
"%programfiles%\Unowhy\TO_INSTALL\eduanat2\eduanat2_installer.exe" /S && echo "2.0.0" > "%userprofile%\AppData\Local\Programs\IFE\EduAnat2\version.txt"

if exist "%userprofile%\AppData\Local\Programs\IFE\EduAnat2\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "2.0.0" "%userprofile%\AppData\Local\Programs\IFE\EduAnat2\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\eduanat2\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\eduanat2\KO.ps1"
goto :done

:alreadyInstalled

:done
