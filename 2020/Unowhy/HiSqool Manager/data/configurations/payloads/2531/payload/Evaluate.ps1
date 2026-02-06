param($process, $package)

$target = "$env:ProgramFiles\Unowhy\HiSqool Manager"

# Check all *.exe version
$program = Get-Item HiSqoolManager.exe
$existing = Get-Item "$target\HiSqoolManager.exe" -ErrorAction Ignore

# Missing file
if ($existing -eq $null) { exit 1 }

$expected = [Version]::Parse($package);
$actual = [Version]::Parse($process);

# Outdated file
if ($expected -gt $actual) { exit 2 }
