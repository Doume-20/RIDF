Write-Host "Remove old script"
Remove-Item "inventory.ps1" -Force -ErrorAction Ignore
Write-Host "Download latest script"
Invoke-WebRequest "https://inventory.idfexchg.unowhy.com/static/inventory_latest.ps1" -OutFile "inventory.ps1"
Write-Host "Set script execution policy"
Set-ExecutionPolicy Unrestricted -Scope Process
Write-Host "Execute script"
.\inventory.ps1
Write-Host "Remove script"
Remove-Item "inventory.ps1" -Force -ErrorAction Ignore