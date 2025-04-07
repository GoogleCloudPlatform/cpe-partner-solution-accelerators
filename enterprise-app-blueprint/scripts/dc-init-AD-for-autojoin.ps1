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

Import-Module "${Env:ProgramFiles}\Google\Compute Engine\sysprep\gce_base.psm1"

$AccessToken                  = (Get-MetaData -Property "service-accounts/default/token" | ConvertFrom-Json).access_token
$RegisterComputerPwSecret     = Get-MetaData -Property "attributes/RegisterComputerPwSecret" -instance_only
$ProjectId                    = Get-MetaData -Property "project-id" -project_only

$ParentOrgUnitPath = (Get-ADDomain).DistinguishedName
$ProjectsOrgUnitPath = "OU=Projects,$ParentOrgUnitPath"
$ProjectsOrgUnit = Get-ADOrganizationalUnit -Identity $ProjectsOrgUnitPath
$ProjectOrgUnitPath = "OU=$ProjectId,OU=Projects,$ParentOrgUnitPath"
$ProjectOrgUnit = Get-ADOrganizationalUnit -Identity $ProjectOrgUnitPath

if ($ProjectsOrgUnit) {
    Write-Host "'Projects' org unit exists: " + $ProjectsOrgUnit.DistinguishedName
} else {
    Write-Host "Creating 'Projects' org unit: $ProjectsOrgUnitPath"
    $ProjectsOrgUnitPath = New-ADOrganizationalUnit `
        -Name 'Projects' `
        -Path $ParentOrgUnitPath `
        -PassThru
}

if ($ProjectOrgUnit) {
    Write-Host "'$ProjectId,Projects' org unit exists: " + $ProjectOrgUnit.DistinguishedName
} else {
    Write-Host "Creating '$ProjectId,Projects' org unit: $ProjectOrgUnitPath"
    $ProjectsOrgUnitPath = New-ADOrganizationalUnit `
        -Name $ProjectId `
        -Path $ProjectsOrgUnitPath `
        -PassThru
}

$RegisterComputerUser = Get-ADUser -Identity register-computer
if ($RegisterComputerUser) {
    Write-Host "register-computer user exists: " $RegisterComputerUser.DistinguishedName " (" $RegisterComputerUser.ObjectGUID ")"
} else {
    $Secret = (Invoke-RestMethod `
        -Headers @{
    "Metadata-Flavor" = "Google";
    "x-goog-user-project" = $ProjectId;
    "Authorization" = "Bearer $AccessToken"} `
        -Uri "https://secretmanager.googleapis.com/v1/projects/$ProjectId/secrets/$RegisterComputerPwSecret/versions/latest:access")
    $Password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Secret.payload.data))

    # Create user
    $UpnSuffix = (Get-ADDomain).DNSRoot
    $RegisterComputerUser = New-ADUser `
        -Name "register-computer Cloud Run app" `
        -GivenName "Register" `
        -Surname "Computer" `
        -Path $ProjectsOrgUnitPath `
        -SamAccountName "register-computer" `
        -UserPrincipalName "register-computer@$UpnSuffix" `
        -AccountPassword (ConvertTo-SecureString "$Password" -AsPlainText -Force) `
        -PasswordNeverExpires $True `
        -Enabled $True `
        -PassThru

    $AcesForContainerAndDescendents = @(
        "CCDC;Computer",               # Create/delete computers
        "CCDC;Group"                   # Create/delete users
    )

    $AcesForDescendents = @(
        "LC;;Computer" ,               # List child objects
        "RC;;Computer" ,               # Read security information
        "WD;;Computer" ,               # Change security information
        "WP;;Computer" ,               # Write properties
        "RP;;Computer" ,               # Read properties
        "CA;Reset Password;Computer",  # ...
        "CA;Change Password;Computer", # ...
        "WS;Validated write to service principal name;Computer",
        "WS;Validated write to DNS host name;Computer",

        "LC;;Group",                   # List child objects
        "RC;;Group",                   # Read security information
        "WD;;Group",                   # Change security information
        "WP;;Group",                   # Write properties
        "RP;;Group"                    # Read properties
    )

    $AcesForContainerAndDescendents | % { dsacls.exe $ProjectsOrgUnitPath /G "${RegisterComputerUser}:${_}" /I:T | Out-Null }
    $AcesForDescendents | % { dsacls.exe $ProjectsOrgUnitPath /G "${RegisterComputerUser}:${_}" /I:S | Out-Null }

    $DnsPartition=(Get-ADDomain).SubordinateReferences | Where-Object {$_.StartsWith('DC=DomainDnsZones')}
    $DnsContainer="DC=$((Get-ADDomain).DNSRoot),CN=MicrosoftDNS,$DnsPartition"

    dsacls $DnsContainer /G "${RegisterComputerUser}:SD" /I:S
}

Write-Host "register-computer password: $Password"
Write-Host "Projects OU: $ProjectsOrgUnitPath"
Write-Host "Project OU:  $ProjectOrgUnitPath"
