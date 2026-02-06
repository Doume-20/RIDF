set PATH=c:\xcas;%PATH%
mount -m > c:\xcas\endxcas.bat
mount -f -s -b "C:/xcas/bin" "/usr/bin"
mount -f -s -b "C:/xcas/lib" "/usr/lib"
mount -f -s -b "C:/xcas" "/"
mount -s -b --change-cygdrive-prefix "/cygdrive"
bash.exe '/cygdrive/c/xcas/runxcas.fr'
c:\xcas\endxcas.bat
