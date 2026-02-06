$target = "$env:ProgramFiles\Unowhy\HiSqool Manager"

$current = "$target\HiSqoolManager.exe"

Remove-Item "$current\HiSqoolManager.exe.old.*" -Force

$temp = @{
    Old = "$current.old.$(Get-Random)"
    New = "$current.new.$(Get-Random)"
}

Copy-Item HiSqoolManager.exe $temp.New -Force

Move-Item $current $temp.Old -Force

Move-Item $temp.New $current -Force

$nssm = "$target\nssm.exe"

& $nssm reset HiSqoolManager AppRotateOnline

& $nssm reset HiSqoolManager AppRotateBytes
