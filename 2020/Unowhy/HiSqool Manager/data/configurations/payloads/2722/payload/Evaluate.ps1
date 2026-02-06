param($package)

$target = "C:\Program Files\Drive monlycee.net"

# Check if first install
if (!(Test-Path $target -PathType Container)) { exit 1 }

# Check all binary version
$existingInstaller = Get-Item "C:\Program Files\Drive monlycee.net\drivemonlyceenet.exe" -ErrorAction Ignore
$existingUninstaller = Get-Item "C:\Program Files\Drive monlycee.net\uninstall000.exe" -ErrorAction Ignore

# Missing file
if ($null -eq $existingInstaller ) { exit 2 }
if ($null -eq $existingUninstaller) { exit 2 }

$cleanVersion = $package -replace "-.*", ""

$expected = [Version]::Parse("$cleanVersion");
$actual = [Version]::Parse($existingInstaller.VersionInfo.ProductVersion);

# Outdated file
if ($expected -gt $actual) { exit 3 }
