foreach ($framework in Get-Item Frameworks\*)
{
	try
	{
		Add-AppxPackage -Path $framework -ErrorAction SilentlyContinue
	}
	catch
	{ }
}

foreach ($package in Get-Item Packages\*)
{
	try
	{
		Add-AppxPackage -Path $package -ErrorAction SilentlyContinue
	}
	catch
	{ }
}