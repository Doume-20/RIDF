function CheckNetRuntime()
{
	try
	{
		$runtimes = dotnet --list-runtimes
		$packages = $runtimes | % { $p = -split $_ ; [pscustomobject]@{ Id = $p[0] ; Version = $p[1]} } | Group-Object -AsHashTable -Property Id

		$expected = @('Microsoft.WindowsDesktop.App', 'Microsoft.AspNetCore.App', 'Microsoft.NETCore.App')

		foreach ($id in $expected)
		{
			$versions = @($packages[$id] | % Version | % { @($_ -split '\.')[0] })

			# Missing pack
			if (!$versions.Contains("9")) { return $false }
		}

		return $true
	}
	catch
	{
		# Not available
		return $false
	}
}

# Missing Net Runtime (not yet)
if (!(CheckNetRuntime)) { exit 0 }

$target = "$env:ProgramFiles\Unowhy\HiSqool Manager\sqoolctl"

# Check if first install
if (!(Test-Path $target -PathType Container)) { exit 1 }

$keyPath = "HKLM:\SOFTWARE\Unowhy\HiSqoolManager\confs\sqool-net"

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
