p:
set PATH=j:\xcas;%PATH%
mount -m > endxcas
addu endxcas endxcas.bat
mount -u -f -b "j:\xcas\bin" "/usr/bin"
mount -u -f -b "j:\xcas\lib" "/usr/lib"
mount -u -f -b "j:\xcas" "/"
bash.exe '/cygdrive/j/xcas/runxcasj.fr' %1
endxcas.bat
