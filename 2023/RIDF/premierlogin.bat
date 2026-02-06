@echo off
set LOGFILE=%UserProfile%\premierlogin.log
if /I  %username% == ent  goto :ent

title Ne pas fermer : initialisation de votre environnement scolaire
MODE CON: COLS=90 LINES=10
color 9f

powershell -windows minimize -command ""


echo Finalisation de la mise en place de votre environnement scolaire
echo Merci de patienter...

copy /Y %ProgramData%\RIDF\shortcut\ %UserProfile%\Desktop\ >> %LOGFILE%
copy /Y C:\Windows\OEM\shortcut\* %UserProfile%\Desktop\ >> %LOGFILE%


%ProgramData%\RIDF\Message_Presidente_Lyceens.mp4


del /Q %ProgramData%\RIDF\premierboot.ps1

exit

:ent

35 
exit
