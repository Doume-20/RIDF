:realstart
if exist "C:\Program Files (x86)\Gnuplot\version.txt" goto :check

goto :startInstall

:check
find "3.4.1" "C:\Program Files (x86)\Gnuplot\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Gnuplot" mkdir "C:\Program Files (x86)\Gnuplot"
"%programfiles%\Unowhy\TO_INSTALL\gnuplot\gnuplot_installer.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- && echo "3.4.1" > "C:\Program Files (x86)\Gnuplot\version.txt"

if exist "C:\Program Files (x86)\Gnuplot\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "3.4.1" "C:\Program Files (x86)\Gnuplot\version.txt" && goto :installationOK || goto :installationKO

:installationOK
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\gnuplot\OK.ps1"
goto :done

:installationKO
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Unowhy\TO_INSTALL\gnuplot\KO.ps1"
goto :done

:alreadyInstalled

:done
