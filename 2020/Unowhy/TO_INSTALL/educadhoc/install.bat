:realstart
:check
rem Get EDUCADHOC Version in registry 
FOR /f "tokens=3 skip=2" %%a in ('REG QUERY HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\educadhoc /v DisplayVersion') do set version=%%a
(echo %version% | findstr /i /c:"9.0.19" >nul) &&  goto :alreadyInstalled || goto :startInstall

:startInstall
"%programfiles%\Unowhy\TO_INSTALL\educadhoc\educadhoc_installer.exe" /S 

:checkbeforenotif
FOR /f "tokens=3 skip=2" %%a in ('REG QUERY HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\educadhoc /v DisplayVersion') do set version=%%a
(echo %version% | findstr /i /c:"9.0.19" >nul) && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\educadhoc\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\educadhoc\KO.ps1"
goto :done

:alreadyInstalled

:done
