$target = "$env:ProgramFiles\Unowhy\HiSqool Manager\sqoolctl"

# Kill programs
$programs = @(Get-Item Tools\*.exe | % { $_.Name.ToLower() })
while (Get-Process | ? { $programs.Contains("$($_.ProcessName.ToLower()).exe") } | % { $_.Kill() ; $_ })
{
	# Wait
	Start-Sleep -Seconds 1
}

# Create folder if missing
New-Item $target -ItemType Directory -Force

# Copy binaries
Copy-Item Tools\* -Destination $target -Force -Recurse

# Create the registry key if it doesn't already exist
$keyPath = "HKLM:\SOFTWARE\Unowhy\HiSqoolManager\confs\sqool-rs"

if (!(Get-Item -Path $keyPath -ErrorAction Ignore))
{
    New-Item -Path $keyPath -Force
}

# Save the version of all exe in the registry
foreach ($program in Get-Item Tools\*.exe)
{
	Set-ItemProperty -Path $keyPath -Name $program.Name -Value $program.VersionInfo.FileVersion
}
