'*** Déclaration des variables
Dim ObjetRegedit

'*** Permet de continuer le script même s'il y a une erreur
On Error Resume Next

'*** Definition du contenu de la variable
Set ObjetRegedit = CreateObject("WScript.Shell")

'*** Definition du contenu de la variable "CleRegistre"
CleRegistre = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\cache"

'*** Ecriture de la clé de registre avec ces données et son type "REG_SZ".
ObjetRegedit.RegWrite CleRegistre, "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache", "REG_SZ"



'*** Destruction des objets
Set ObjetRegedit = Nothing

WScript.Quit

