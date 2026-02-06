:realstart
if exist "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64\version.txt" goto :check

goto :startInstall

:check
find "14.29.30133.0" "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64\version.txt" &&  goto :alreadyInstalled || goto :startInstall

:startInstall
if not exist "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64" mkdir "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64"
"%programfiles%\Unowhy\TO_INSTALL\vcredist.x64\vcredist.x64_installer.exe" /install /quiet /norestart && echo "14.29.30133.0" > "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64\version.txt"

if exist "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64\version.txt"  goto :checkbeforenotif
goto :installationKO

:checkbeforenotif
find "14.29.30133.0" "C:\Program Files (x86)\Microsoft Visual C++ Redistributable x64\version.txt" && goto :installationOK || goto :installationKO

:installationOK
goto :done

:installationKO
goto :done

:alreadyInstalled

:done
