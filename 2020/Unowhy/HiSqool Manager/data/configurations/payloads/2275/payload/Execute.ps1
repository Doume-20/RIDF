$ProgressPreference = 'silentlycontinue'

$version = (Get-Content log-version -ErrorAction Ignore) -as [int]

if ($version -ge 1) { return }

$security = @{}
$cc = Get-Item C:\Windows\Temp\cc.exe -ErrorAction Ignore
if ($cc) {
    $security.CC = $cc.LastWriteTime.ToString("G")
}
$crdh = Get-Item "C:\Program Files\Unowhy\HiSqool Manager\data\CRDH.msi" -ErrorAction Ignore
if ($crdh) {
    $security.CRDH = $crdh.LastWriteTime.ToString("G")
}

$sn = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).SerialNumber

ConvertTo-Json $security > fact.json

Remove-Item "$sn.zip" -Force -ErrorAction Ignore

Copy-Item -Path "$env:ProgramFiles\Unowhy\HiSqool Manager\logs\logs" -Destination "$env:ProgramFiles\Unowhy\HiSqool Manager\logs\logs-current" -Force

Compress-Archive -Path (dir "$env:ProgramFiles\Unowhy\HiSqool Manager\logs\logs-*", fact.json) -DestinationPath "$sn.zip" | Out-Null

$url = "https://inventory.idfexchg.unowhy.com/devinfo/$sn"
Invoke-RestMethod $url -Method POST -InFile "$sn.zip" | Out-Null

Remove-Item "$sn.zip" -Force -ErrorAction Ignore

"1" > log-version