param($package)

$runtime = Get-Item "$env:SystemRoot\System32\msvcp140.dll"

# Missing file
if ($runtime -eq $null) { exit 1 }

$expected = [Version]::Parse("$package.0")
$actual = [Version]::Parse($runtime.VersionInfo.FileVersion)

# Out of date
if ($expected -gt $actual) { exit 2 }
