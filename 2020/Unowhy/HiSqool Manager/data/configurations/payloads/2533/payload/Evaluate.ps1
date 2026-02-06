$target = "$env:ProgramFiles\Unowhy\HiSqool Manager\sqoolctl"

# Check if first install
if (!(Test-Path $target -PathType Container)) { exit 1 }

$keyPath = "HKLM:\SOFTWARE\Unowhy\HiSqoolManager\confs\sqool-rs"

# Check all *.exe version
foreach ($program in Get-Item Tools\*.exe)
{
	$existing = Get-Item "$target\$($program.Name)" -ErrorAction Ignore

	# Missing file
	if ($null -eq $existing) { exit 2 }

	$expected = [Version]::Parse($program.VersionInfo.FileVersion);
	$actual = [Version]::Parse($existing.VersionInfo.FileVersion);

	# Outdated file
	if ($expected -gt $actual) { exit 3 }

	# Check in registry
	$versionInRegistry = Get-ItemPropertyValue -Path $keyPath -Name $program.Name -ErrorAction Ignore;

	# Missing entry
	if ($null -eq $versionInRegistry) { exit 4 }

	try
	{
		$actual = [Version]::Parse($versionInRegistry)
	}
	catch
	{
		# Incorrect value in registry
		exit 5
	}

	# Outdated file
	if ($expected -gt $actual) { exit 6 }
}
