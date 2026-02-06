del -f c:\windows\system32\OEM\customize.xml
del -f c:\windows\system32\OEM\firstloginplanif.xml
net user defaultuser0 /delete
%windir%\System32\reagentc /disable
schtasks.exe /delete /tn firstlogin /f
powershell.exe enable-ComputerRestore -Drive C:\
del %0