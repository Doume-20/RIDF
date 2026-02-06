$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\bootim.exe";
$noop = "C:\Windows\System32\rundll32.exe";

# Change bootim to noop
New-Item -Path $path;
Set-ItemProperty -Path $path -Name "Debugger" -Type "String" -Value $noop -Force;

# Change BCD
bcdedit /set "{current}" bootstatuspolicy IgnoreAllFailures;

# Remove ENT administrator role
$admins = [System.Security.Principal.SecurityIdentifier]::new([System.Security.Principal.WellKnownSidType]"BuiltinAdministratorsSid", $null);
$account = Get-LocalUser -Name ENT -ErrorAction Ignore;
if ($account -ne $null) {
    # Remove-LocalGroupMember -SID $admins -Member $account -ErrorAction Ignore;
}

# Disable administrator user
$group = Get-LocalGroup -Name "DisabledAccounts" -ErrorAction Ignore;
if ($group -eq $null) {
    $group = New-LocalGroup -Name "DisabledAccounts";
}
$domain = $group.SID.AccountDomainSid;
$admin = [System.Security.Principal.SecurityIdentifier]::new("AccountAdministratorSid", $domain);
$account = Get-LocalUser -SID $admin -ErrorAction Ignore;
if (($account -ne $null) -and ($account.Enabled)) {
    Add-LocalGroupMember -Group $group -Member $account -ErrorAction Ignore;
    Disable-LocalUser -InputObject $account;
}