try{
    Install-ProvisioningPackage -PackagePath ".\sortieparcetape2.ppkg" -QuietInstall
}
catch{
    write-host "PPKG de Etape 2 droits Admin et BIOS déjà installé. Error: $($_.Exception.Message)"
}