param($settings)

function Add($ssid, $security, $password, $hidden) {
	[xml] $document = Get-Content Profile.xml
	$profile = $document.LastChild

	$encoding = [System.Text.Encoding]::UTF8
	$hex = -join ($encoding.GetBytes($ssid) | % { "{0:X2}" -f $_ })

	# name
	$profile.name = $ssid

	# SSID
	$identity = $profile.SSIDConfig
	$identity.SSID.hex = $hex
	$identity.SSID.name = $ssid
	if (-not $hidden)
	{
		[void] $identity.RemoveChild($identity["nonBroadcast"])
	}

	# Security
	$encryption = $profile.MSM.security.authEncryption
	switch ($security)
	{
		"none"
		{
			$encryption.authentication = "open"
			$encryption.encryption = "none"
		}
		"WPA/WPA2 PSK"
		{
			$encryption.authentication = "WPA2PSK"
			$encryption.encryption = "AES"
			$profile.MSM.security.sharedKey.keyMaterial = $password
		}
		"WEP"
		{
			$encryption.authentication = "open"
			$encryption.encryption = "WEP"
			$profile.MSM.security.sharedKey.keyMaterial = $password
		}
		default
		{
			$encryption.RemoveAll()
		}
	}

	# Secret
	if ($security -in "WPA/WPA2 PSK", "WEP")
	{
		$profile.MSM.security.sharedKey.keyMaterial = $password
	}
	else
	{
		[void] $profile.MSM.security.RemoveChild($profile.MSM.security.sharedKey)
	}

	# Save
	$path = "$hex.xml"
	Set-Content $path $document.OuterXml

	# Add profile API
	netsh wlan add profile filename="$path"

	if ($LASTEXITCODE -ne 0)
	{
		throw "Could not add the profile"
	}

	# Clean
	Remove-Item $path
}

function Connect($ssid) {
	$source = Get-Content "WiFi.cs" -Raw

	# Compile
	$parameters = [System.CodeDom.Compiler.CompilerParameters]::new()
	$parameters.CompilerOptions = "-unsafe"
	[void] $parameters.ReferencedAssemblies.Add("System.dll")
	Add-Type $source -CompilerParameters $parameters

	# Connect
	[WiFi]::Connect($ssid)
}

Add $settings.ssid $settings.securityType $settings.password $settings.hidden

Connect $settings.ssid
