p:
set PATH=c:\xcas;%PATH%
mount -m > endxcas
addu endxcas endxcas.bat
mount -u -f -b "c:\xcas\bin" "/usr/bin"
mount -u -f -b "c:\xcas\lib" "/usr/lib"
mount -u -f -b "c:\xcas" "/"
bash.exe '/cygdrive/c/xcas/runxcasn.fr' %1
endxcas.bat
