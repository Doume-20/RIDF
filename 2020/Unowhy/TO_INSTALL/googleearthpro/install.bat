:realstart
if exist "C:\Program Files (x86)\Google\EarthPro\version.txt" goto :check

goto :startInstall

:check
find "7.3.3" "C:\Program Files (x86)\Google\EarthPro\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Google\EarthPro" mkdir "C:\Program Files (x86)\Google\EarthPro"
"%programfiles%\Unowhy\TO_INSTALL\googleearthpro\googleearthpro_installer.exe" OMAHA=1 && echo "7.3.3" > "C:\Program Files (x86)\Google\EarthPro\version.txt"

if exist "C:\Program Files (x86)\Google\EarthPro\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "7.3.3" "C:\Program Files (x86)\Google\EarthPro\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\googleearthpro\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\googleearthpro\KO.ps1"
goto :done

:alreadyInstalled

:done
