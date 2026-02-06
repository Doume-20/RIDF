param ($script)

$data = [Convert]::FromBase64String($script)
$path = [System.IO.Path]::GetTempPath() + "Script.ps1"
Set-Content $path $data -Encoding Byte

Set-ExecutionPolicy -Scope Process Unrestricted
& $path

Remove-Item $path -Force