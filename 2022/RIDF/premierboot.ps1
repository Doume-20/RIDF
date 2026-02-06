#Definir une liste d'URL interdites pour EDGE
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\URLBlocklist" /v 1 /t REG_SZ /d "*"

#Definir une liste d'URL autorisées pour EDGE
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\URLAllowlist"  /v 1 /t REG_SZ /d "monlycee.net"
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\URLAllowlist" /v 2 /t REG_SZ /d "iledefrance.fr"
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\URLAllowlist" /v 3 /t REG_SZ /d "http://localhost:7654"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d  1
#activer un script au démarrage
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "watchdog" /t REG_SZ /d "cscript.exe C:\Programdata\ridf\msedgewatchdog.vbs" /f

$username='ENT'
$user = New-Object System.Security.Principal.NTAccount($username)
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier])

set-localUser -Name "ENT" -Fullname "Activation ENT" -PasswordNeverExpires 1

Dism /online /Enable-Feature /all /FeatureName:Client-EmbeddedShellLauncher

Dism /online /Enable-Feature /all /FeatureName:Client-EmbeddedShellLauncher


((Get-Content -path C:\ProgramData\RIDF\KioskModeConfig.reg -Raw) -replace 'REPLACESID', $sid.Value ) | Set-Content -Path C:\ProgramData\RIDF\KioskModeConfig.reg
reg import C:\ProgramData\RIDF\KioskModeConfig.reg


net localgroup Administrateurs ENT /delete
shutdown -r -t 3
Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
