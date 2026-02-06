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

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Unrestricted -File "C:\Program Files\Unowhy\HiSqool Manager\data\configurations\payloads\1578\payload\ExecuteWelcome.ps1" "%ProgramData%/RIDF/Message_Presidente_Lyceens_2021.mp4"

  echo Installation de Lelivrescolaire >> %LOGFILE%
%ProgramData%/RIDF/premier_demarrage/Lelivrescolaire.fr.setup_64.exe /S >> %LOGFILE%
  echo result: %ERRORLEVEL% >> %LOGFILE%

  echo Installing MesGranules.fr >> %LOGFILE%
%ProgramData%/RIDF/premier_demarrage/MesGranules.fr.Setup.exe /S >> %LOGFILE%
  echo result: %ERRORLEVEL% >> %LOGFILE%

  echo Installation Educadhoc>> %LOGFILE%
%ProgramData%/RIDF/premier_demarrage/educadhoc_installer_v9.0.8.exe /S >> %LOGFILE%
  echo result: %ERRORLEVEL% >> %LOGFILE%

  echo Installation LibManuels>> %LOGFILE%
%ProgramData%/RIDF/premier_demarrage/Lib_Manuels-4.0.2.exe /S >> %LOGFILE%
  echo result: %ERRORLEVEL% >> %LOGFILE%

del /Q %ProgramData%\RIDF\premierboot.ps1

exit

:ent

exit
