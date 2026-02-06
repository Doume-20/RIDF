param($package)

function GetPackages($name, $architecture, $minimum)
{
	Get-AppxPackage -Name $name | ? { ($_.Architecture -eq $architecture) -and ([Version]::Parse($_.Version) -ge $minimum) }
}

$package = $package -replace "-.*", ""
$version = [Version]::Parse($package)

foreach ($file in @(Get-Item Packages\* ; Get-Item Frameworks\*))
{
	$name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

	if (-not (GetPackages $name "X64" $version)) { exit 1 }
}
