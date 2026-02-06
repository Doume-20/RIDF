<#
.SYNOPSIS
    Installs a browser extensions on Chrome, Mozilla, Edge using ExtensionSettings policy

.DESCRIPTION
    This script installs extensions for Chrome, Firefox, and Edge.
    Arguments are provided in the form of `-arg install_uninstall plugins  fake_enroll_machine`.

.PARAMETER install_uninstall
    String : "install" or "uninstall"

.PARAMETER plugins
    String : Plugin names comma separated. Example: "pix_companion". Checkout "*_extensionsettings_by_plugin" variables to see available plugins.
    This comma separated list will replace the ones already defined in the Policies.

.PARAMETER fake_enroll_machine
    Boolean : Fake enroll the machine so pollicy applies to Edge. Not necessary if device already in domain, AAD etc.

.EXAMPLE
    .\install-extension.ps1 install pix_companion true
    Installs the Pix Companion extension for Chrome, Mozilla, Edge. 

.NOTES
    Author: Stéphane Boucaud
#>

$install_uninstall = $args[0] # install string value for installing and uninstall value for uninstalling policies
$plugins = $args[1]; # plugins names, comma separated as a string
$fake_enroll_machine = $args[2]; # boolean => true : fake enrolment to force policy on edge (not needed if device in AAD / AD etc)

### PARSING INPUT TO SCRIPT

try {
    # Try to split the string into an array
    $plugins = $plugins -split ','
}
catch {
    $plugins = @()
}

try {
    $fake_enroll_machine = [System.Convert]::ToBoolean($fake_enroll_machine) 
} catch [FormatException] {
    $fake_enroll_machine = $False
}

$install = $False
$uninstall = $False
try {
    $install = $install_uninstall.Trim().ToLower() -eq "install"
    $uninstall = $install_uninstall.Trim().ToLower() -eq "uninstall"
}
catch {
    $install = $False
    $uninstall = $False
}

write-host "Plugins wanted : $($plugins)"
write-host "Fake Pc enroll enabled : $($fake_enroll_machine)"
write-host "Action performed:   install: $($install) ; uninstall : $($uninstall)"

### EXTENSIONSETTINGS POLICIES DEFINITIONS per plugin name (plugin names passed in input of script)

if ($install){

    # Chrome extension settings
    $chrome_extensionsettings_by_plugin = @{
        "pix_companion" = @{
            "pgpjajcmfbfdmcgjlbiengidaknopaok" = @{
                "installation_mode" = "force_installed"
                "update_url"        = "https://clients2.google.com/service/update2/crx"
            }
        }
    }

    # Mozilla (Firefox) extension settings
    $mozilla_extensionsettings_by_plugin = @{
        "pix_companion" = @{
            "companion@pix.fr" = @{
                "installation_mode" = "force_installed"
                "install_url"       = "https://addons.mozilla.org/firefox/downloads/latest/pix-companion/latest.xpi"
                "private_browsing"  = $true
            }
        }
    }

    # Edge extension settings
    $edge_extensionsettings_by_plugin = @{
        "pix_companion" = @{
            "pgpjajcmfbfdmcgjlbiengidaknopaok" = @{
                "installation_mode"   = "force_installed"
                "override_update_url" = $true
                "update_url"          = "https://clients2.google.com/service/update2/crx"
            }
        }
    }

    ### RETRIEVING EXTENSIONS SETTINGS FOR PLUGIN NAMES PASSED IN INPUT

    foreach ($plugin in $plugins) {
        $chrome_extensionsettings = @{}
        $mozilla_extensionsettings = @{}
        $edge_extensionsettings = @{}
        try {
            $plugin_extensionsettings = $chrome_extensionsettings_by_plugin[$plugin]
            foreach ($kvp in $plugin_extensionsettings.GetEnumerator()) {
                $chrome_extensionsettings[$kvp.Key] = $kvp.Value
            }
        } catch [Exception] {
            write-host "Problem retrieving chrome extensionsettings"
        }
        try {
            $plugin_extensionsettings = $mozilla_extensionsettings_by_plugin[$plugin]
            foreach ($kvp in $plugin_extensionsettings.GetEnumerator()) {
                $mozilla_extensionsettings[$kvp.Key] = $kvp.Value
            }
        } catch [Exception] {
            write-host "Problem retrieving mozilla extensionsettings"
        }
        try {
            $plugin_extensionsettings = $edge_extensionsettings_by_plugin[$plugin]
            foreach ($kvp in $plugin_extensionsettings.GetEnumerator()) {
                $edge_extensionsettings[$kvp.Key] = $kvp.Value
            }
        } catch [Exception] {
            write-host "Problem retrieving edge extensionsettings"
        }
    }

    ### CHECKING IF EXTENSIONSETTINGS IN JSON FORMAT, AND APPLYING  

    try {
        $chrome_extensionsettings = $chrome_extensionsettings | ConvertTo-Json -Depth 5
        write-host "Retrieved Chrome ExtensionSettings : $($chrome_extensionsettings)"
    } catch [Exception] {
        throw "Chrome ExtensionSettings not in right format : $chrome_extensionsettings"
    }
    If (-NOT (Test-Path 'HKLM:\SOFTWARE\Policies\Google\Chrome')) {
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Force | Out-Null
    };
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ExtensionSettings' -Value $chrome_extensionsettings -PropertyType String -Force;


    try {
        $mozilla_extensionsettings = $mozilla_extensionsettings | ConvertTo-Json -Depth 5
        write-host "Retrieved Mozilla ExtensionSettings : $($mozilla_extensionsettings)"
    } catch [Exception] {
        throw "Mozilla ExtensionSettings not in right format : $mozilla_extensionsettings"
    }
    If (-NOT (Test-Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox')) {
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' -Force | Out-Null
    };
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' -Name 'ExtensionSettings' -Value $mozilla_extensionsettings -PropertyType MultiString -Force;


    try {
        $edge_extensionsettings = $edge_extensionsettings | ConvertTo-Json -Depth 5
        write-host "Retrieved Edge ExtensionSettings : $($edge_extensionsettings)"
    } catch [Exception] {
        throw "Edge ExtensionSettings not in right format : $edge_extensionsettings"
    }
    If (-NOT (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge')) {
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Force | Out-Null
    };
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'ExtensionSettings' -Value $edge_extensionsettings -PropertyType String -Force;

    ### MANAGING FAKE ENROLLMENT TO FORCE POLICY FOR EDGE (Not necessary if device in Domain / AAD etc)

    if ($fake_enroll_machine){ # Needed to force Edge to apply the policies, by fake enrolling PC (needs to be enrolled PC)
        $fake_enroll_path1 = 'HKLM:\SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
        If (-NOT (Test-Path $fake_enroll_path1)) {
            New-Item -Path $fake_enroll_path1 -Force | Out-Null
        };
        New-ItemProperty -Path $fake_enroll_path1 -Name 'EnrollmentState' -Value 1 -PropertyType DWord -Force;
        New-ItemProperty -Path $fake_enroll_path1 -Name 'EnrollmentType' -Value 0 -PropertyType DWord -Force;
        New-ItemProperty -Path $fake_enroll_path1 -Name 'IsFederated' -Value 0 -PropertyType DWord -Force;
        $fake_enroll_path2 = 'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
        If (-NOT (Test-Path $fake_enroll_path2)) {
            New-Item -Path $fake_enroll_path2 -Force | Out-Null
        };
        New-ItemProperty -Path $fake_enroll_path2 -Name 'Flags' -Value 0x00d6fb7f -PropertyType DWord -Force;
        New-ItemProperty -Path $fake_enroll_path2 -Name 'AcctUId' -Value '0x000000000000000000000000000000000000000000000000000000000000000000000000' -PropertyType String -Force;
        New-ItemProperty -Path $fake_enroll_path2 -Name 'RoamingCount' -Value 0x00000000 -PropertyType DWord -Force;
        New-ItemProperty -Path $fake_enroll_path2 -Name 'SslClientCertReference' -Value 'MY;User;0000000000000000000000000000000000000000' -PropertyType String -Force;
        New-ItemProperty -Path $fake_enroll_path2 -Name 'ProtoVer' -Value '1.2' -PropertyType String -Force;
        write-host "Fake enrolement created under $($fake_enroll_path1) and $($fake_enroll_path2) to force Edge Policy"
    }
    else {
        ### Removing fake enroll
        $fake_enroll_path1 = 'HKLM:\SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
        if (Test-Path $fake_enroll_path1){Remove-Item -Path $fake_enroll_path1 -Recurse}
        $fake_enroll_path2 = 'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
        if (Test-Path $fake_enroll_path2){Remove-Item -Path $fake_enroll_path2 -Recurse}
        write-host "Removed fake enrollement created under $($fake_enroll_path1) and $($fake_enroll_path2) (Policies on Edge might not work anymore if device not in a domain)"
    }

}


### UNINSTALLING

elseif($uninstall){
    
    ### Removing Extension Settings
    $ChromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
    $MozillaPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"
    $EdgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

    try {
        Remove-ItemProperty -Path $ChromePath -Name "ExtensionSettings" -ErrorAction SilentlyContinue
    }
    catch [Exception] {
        Write-Host "Item property already deleted"
    }

    try {
        Remove-ItemProperty -Path $MozillaPath -Name "ExtensionSettings" -ErrorAction SilentlyContinue
    }
    catch [Exception] {
        Write-Host "Item property already deleted"
    }

    try {
        Remove-ItemProperty -Path $EdgePath -Name "ExtensionSettings" -ErrorAction SilentlyContinue
    }
    catch [Exception] {
        Write-Host "Item property already deleted"
    }
    
    ### Removing fake enroll
    $fake_enroll_path1 = 'HKLM:\SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
    if (Test-Path $fake_enroll_path1){Remove-Item -Path $fake_enroll_path1 -Recurse}
    $fake_enroll_path2 = 'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
    if (Test-Path $fake_enroll_path2){Remove-Item -Path $fake_enroll_path2 -Recurse}
    write-host "Removed fake enrollement created under $($fake_enroll_path1) and $($fake_enroll_path2) (Policies on Edge might not work anymore if device not in a domain)"
    
}

# if ($install -or $uninstall){
    # gpupdate /force # Time consuming
# }

exit(0)