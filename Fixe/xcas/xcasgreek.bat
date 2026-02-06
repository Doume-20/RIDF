set PATH=c:\xcas;%PATH%
mount -m > endxcas
addu endxcas endxcas.bat
mount -u -f -b "c:\xcas\bin" "/usr/bin"
mount -u -f -b "c:\xcas\lib" "/usr/lib"
bash.exe '/cygdrive/c/xcas/runxcas.el' %1
endxcas.bat
