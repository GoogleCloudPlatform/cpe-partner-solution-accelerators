# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$ErrorActionPreference = "Stop"

#
# Only run the script if the VM is not a domain controller already.
#
if ((Get-CimInstance -ClassName Win32_OperatingSystem).ProductType -eq 2) {
    exit
}

#
# Read configuration from metadata.
#
Import-Module "${Env:ProgramFiles}\Google\Compute Engine\sysprep\gce_base.psm1"

$ActiveDirectoryDnsDomain     = Get-MetaData -Property "attributes/ActiveDirectoryDnsDomain" -instance_only
$ActiveDirectoryNetbiosDomain = Get-MetaData -Property "attributes/ActiveDirectoryNetbiosDomain" -instance_only
$ActiveDirectoryFirstDc       = Get-MetaData -Property "attributes/ActiveDirectoryFirstDc" -instance_only
$ActiveDirectoryPwSecret      = Get-MetaData -Property "attributes/ActiveDirectoryPwSecret" -instance_only
$ProjectId                    = Get-MetaData -Property "project-id" -project_only
$Hostname                     = Get-MetaData -Property "hostname" -instance_only
$AccessToken                  = (Get-MetaData -Property "service-accounts/default/token" | ConvertFrom-Json).access_token

#
# Read the DSRM password from secret manager.
#
$Secret = (Invoke-RestMethod `
    -Headers @{
        "Metadata-Flavor" = "Google";
        "x-goog-user-project" = $ProjectId;
        "Authorization" = "Bearer $AccessToken"} `
    -Uri "https://secretmanager.googleapis.com/v1/projects/$ProjectId/secrets/$ActiveDirectoryPwSecret/versions/latest:access")
$DsrmPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Secret.payload.data))
$DsrmPassword = ConvertTo-SecureString -AsPlainText $DsrmPassword -force

#
# Promote.
#
Write-Host "Setting administrator password..."
Set-LocalUser -Name Administrator -Password $DsrmPassword

if ($ActiveDirectoryFirstDc -eq $env:COMPUTERNAME) {
    Write-Host "Creating a new forest $ActiveDirectoryDnsDomain ($ActiveDirectoryNetbiosDomain)..."
    Install-ADDSForest `
        -DomainName $ActiveDirectoryDnsDomain `
        -DomainNetbiosName $ActiveDirectoryNetbiosDomain `
        -SafeModeAdministratorPassword $DsrmPassword `
        -DomainMode Win2008R2 `
        -ForestMode Win2008R2 `
        -InstallDns `
        -CreateDnsDelegation:$False `
        -NoRebootOnCompletion:$True `
        -Confirm:$false
}
else {
    do {
        Write-Host "Waiting for domain to become available..."
        Start-Sleep -s 60
        & ipconfig /flushdns | Out-Null
        & nltest /dsgetdc:$ActiveDirectoryDnsDomain | Out-Null
    } while ($LASTEXITCODE -ne 0)

    Write-Host "Adding DC to $ActiveDirectoryDnsDomain ($ActiveDirectoryNetbiosDomain)..."
    Install-ADDSDomainController `
        -DomainName $ActiveDirectoryDnsDomain `
        -SafeModeAdministratorPassword $DsrmPassword `
        -InstallDns `
        -Credential (New-Object System.Management.Automation.PSCredential ("Administrator@$ActiveDirectoryDnsDomain", $DsrmPassword)) `
        -NoRebootOnCompletion:$true  `
        -Confirm:$false
}

#
# Configure DNS.
#
Write-Host "Configuring DNS settings..."
Get-Netadapter| Disable-NetAdapterBinding -ComponentID ms_tcpip6
Set-DnsClientServerAddress  `
    -InterfaceIndex (Get-NetAdapter -Name Ethernet).InterfaceIndex `
    -ServerAddresses 127.0.0.1

#
# Enable LSA protection.
#
New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "RunAsPPL" `
    -Value 1 `
    -PropertyType DWord

#
# Enable management tools
#
dism /online /enable-feature /featurename:RSAT-AD-Tools-Feature
dism /online /enable-feature /featurename:RSAT-ADDS-Tools-Feature
dism /online /enable-feature /featurename:DirectoryServices-DomainController-Tools
dism /online /enable-feature /featurename:DNS-Server-Tools


Write-Host "Restarting to apply all settings..."
Restart-Computer

