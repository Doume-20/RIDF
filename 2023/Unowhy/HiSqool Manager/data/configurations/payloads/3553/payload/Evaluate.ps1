param($package)

try
{
	$runtimes = dotnet --list-runtimes
	$packages = $runtimes | % { $p = -split $_ ; [pscustomobject]@{ Id = $p[0] ; Version = $p[1]} } | Group-Object -AsHashTable -Property Id

	$expected = @('Microsoft.WindowsDesktop.App', 'Microsoft.AspNetCore.App', 'Microsoft.NETCore.App')

	foreach ($id in $expected)
	{
		$versions = @($packages[$id] | % Version)

		# Missing pack
		if (!$versions.Contains($package)) { exit 2 }
	}
}
catch
{
	# Not available
	exit 1
}
