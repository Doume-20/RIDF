$imagelogo = New-BTImage -Source 'C:\Windows\System32\OEM\unowhy.ico' -AppLogoOverride
$Text1 = New-BTText -Content  "UNOWHY - HiSQOOL"
$text2 = New-BTText -Content "Lelivrescolaire - 4.0.6"
$Text3 = New-BTText -Content "Installation réussie"
$Binding = New-BTBinding -Children $text1, $text2, $text3 -AppLogoOverride $imagelogo
$Visual = New-BTVisual -BindingGeneric $Binding
$Content = New-BTContent -Visual $Visual
Submit-BTNotification -Content $Content
