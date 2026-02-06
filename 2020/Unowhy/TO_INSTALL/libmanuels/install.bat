:realstart

:check
CALL :checkVersion && goto :alreadyInstalled || goto :startInstall

:checkVersion
rem Get version in registry
FOR /f "tokens=3 skip=2" %%a in ('REG QUERY HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\4e8d4f2c-769a-5800-924a-22a94ab38cbe /v DisplayVersion') do set fullVersion=%%a
IF [%fullVersion%] == [] EXIT /B 1

FOR /F tokens^=2skip^=2delims^=^" %%e in ('REG QUERY HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\4e8d4f2c-769a-5800-924a-22a94ab38cbe /v QuietUninstallString') do set uninstallPath=%%e
IF NOT EXIST "%uninstallPath%" EXIT /B 1

FOR /f "tokens=1,2,3 delims=." %%b in ("%fullVersion%") do (
	set majorVersion=%%b 
	set minorVersion=%%c 
	set buildVersion=%%d
)
IF 5 GTR %majorVersion% EXIT /B 1
EXIT /B 0

:startInstall
"%programfiles%\Unowhy\TO_INSTALL\libmanuels\libmanuels_installer.exe" /S

:checkbeforenotif
CALL :checkVersion && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\libmanuels\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\libmanuels\KO.ps1"
goto :done

:alreadyInstalled
rem Already Installed

:done
