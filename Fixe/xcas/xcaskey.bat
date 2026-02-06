set ici=%CD%
set lecteur=%CD:~0,1%
set chemin=%CD:~2%
set chemin=%chemin:\=/%
set chemin=%lecteur%%chemin%
set PATH=%ici%;%PATH%
REM mount -m > endxcas
REM addu endxcas endxcas.bat
REM mount -u -f -b "%ici%\bin" "/usr/bin"
REM mount -u -f -b "%ici%\lib" "/usr/lib"
REM mount -u -f -b "%ici%" "/"
bash.exe '/cygdrive/%chemin%/runxcaskey_fr.fr' %chemin% %1
REM endxcas.bat
