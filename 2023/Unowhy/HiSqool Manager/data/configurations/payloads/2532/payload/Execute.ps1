$target = "$env:ProgramFiles\Unowhy\HiSqool Manager\sqoolctl"

# Stop service
Stop-Service "Unowhy Task Scheduler" -ErrorAction Ignore

# Remove service - Remove-Service "Unowhy Task Scheduler" -ErrorAction Ignore
sc.exe delete "Unowhy Task Scheduler"

# Kill programs (sqoolsys.exe is no longer deployed)
$programs = @(Get-Item Tools\*.exe | % { $_.Name.ToLower() }) + "sqoolsys.exe"
while (Get-Process | ? { $programs.Contains("$($_.ProcessName.ToLower()).exe") } | % { $_.Kill() ; $_ })
{
	# Wait
	Start-Sleep -Seconds 1
}

# Create folder if missing
New-Item $target -ItemType Directory -Force

# Copy binaries
Copy-Item Tools\* -Destination $target -Force -Recurse

# Create service - New-Service "Unowhy Task Scheduler" "$target\sqooltsk.exe" -StartupType Automatic -DependsOn 'HiSqoolManager'
sc.exe create "Unowhy Task Scheduler" "start=" "auto" "depend=" "HiSqoolManager" "binpath=" "$target\sqooltsk.exe"

# Start service
Start-Service "Unowhy Task Scheduler"

# Initialize SSL
& "$target\sqoolctl.exe" init

# Create the registry key if it doesn't already exist
$keyPath = "HKLM:\SOFTWARE\Unowhy\HiSqoolManager\confs\sqool-net"

if (!(Get-Item -Path $keyPath -ErrorAction Ignore))
{
    New-Item -Path $keyPath -Force
}

# Save the version of all exe in the registry
foreach ($program in Get-Item Tools\*.exe)
{
	Set-ItemProperty -Path $keyPath -Name $program.Name -Value $program.VersionInfo.FileVersion
}

# Remove sqool.sys value
Remove-ItemProperty -Path $keyPath -Name "sqoolsys.exe" -ErrorAction Ignore
