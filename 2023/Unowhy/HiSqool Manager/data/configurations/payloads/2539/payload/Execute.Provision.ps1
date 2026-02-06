foreach ($framework in Get-Item Frameworks\*)
{
	try
	{
		Add-AppxPackage -Path $framework -Stage -ErrorAction SilentlyContinue
	}
	catch
	{ }
}

foreach ($package in Get-Item Packages\*)
{
	try
	{
		Add-AppxProvisionedPackage -PackagePath $package -Online -SkipLicense -ErrorAction SilentlyContinue
	}
	catch 
	{ }
}