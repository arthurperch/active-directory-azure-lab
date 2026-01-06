<#
.SYNOPSIS
    Bulk Active Directory User Creation Script
.DESCRIPTION
    Creates multiple test user accounts in Active Directory with random names.
    Useful for lab environments and testing Group Policy, permissions, or logon behavior.
.NOTES
    Author: Oleg Perchatkin
    Version: 1.0
    Requires: Active Directory PowerShell Module
.EXAMPLE
    .\Create-BulkUsers.ps1
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateRange(1,1000)]
    [int]$NumberOfAccountsToCreate = 25,

    [Parameter(Mandatory = $false)]
    [string]$PasswordForUsers = "P@ssw0rd123!",

    [Parameter(Mandatory = $false)]
    [string]$TargetOu = "OU=_EMPLOYEES,DC=mydomain,DC=com"
)

# region Validate environment
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Error "Active Directory module not available. Install RSAT: Active Directory Domain Services Tools before running this script.";
    return
}

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$TargetOu'" -ErrorAction SilentlyContinue)) {
    Write-Error "Target OU '$TargetOu' not found. Create it before running the script.";
    return
}
# endregion

# Convert the plain text password to a secure string for New-ADUser.
$securePassword = ConvertTo-SecureString -String $PasswordForUsers -AsPlainText -Force

# Helper function creates names that look realistic enough for lab demos.
function New-RandomName {
    [OutputType([pscustomobject])]
    param ()

    $consonants = "bcdfghjklmnpqrstvwxyz".ToCharArray()
    $vowels = "aeiou".ToCharArray()

    function Get-Syllable([int]$length) {
        $name = ""
        for ($i = 0; $i -lt $length; $i++) {
            $name += $consonants[(Get-Random -Minimum 0 -Maximum $consonants.Length)]
            $name += $vowels[(Get-Random -Minimum 0 -Maximum $vowels.Length)]
        }
        return ($name.Substring(0,1).ToUpper() + $name.Substring(1))
    }

    $first = Get-Syllable -length (Get-Random -Minimum 2 -Maximum 3)
    $last = Get-Syllable -length (Get-Random -Minimum 2 -Maximum 3)

    return [pscustomobject]@{
        GivenName = $first
        Surname   = $last
    }
}

# Track successes for a concise summary.
$createdUsers = @()

for ($i = 1; $i -le $NumberOfAccountsToCreate; $i++) {
    $name = New-RandomName
    $givenName = $name.GivenName
    $surname = $name.Surname

    $samAccountName = ("{0}.{1}" -f $givenName, $surname).ToLower()
    $userPrincipalName = "{0}@{1}" -f $samAccountName, ((Get-ADDomain).DNSRoot)

    # Ensure username uniqueness by appending a counter if necessary.
    $samCandidate = $samAccountName
    $counter = 1
    while (Get-ADUser -Filter "SamAccountName -eq '$samCandidate'" -ErrorAction SilentlyContinue) {
        $samCandidate = "{0}{1}" -f $samAccountName, $counter
        $userPrincipalName = "{0}@{1}" -f $samCandidate, ((Get-ADDomain).DNSRoot)
        $counter++
    }

    $parameters = @{
        Name                  = ("{0} {1}" -f $givenName, $surname)
        GivenName             = $givenName
        Surname               = $surname
        SamAccountName        = $samCandidate
        UserPrincipalName     = $userPrincipalName
        DisplayName           = ("{0} {1}" -f $givenName, $surname)
        EmployeeID            = (Get-Random -Minimum 100000 -Maximum 999999).ToString()
        AccountPassword       = $securePassword
        Enabled               = $true
        PasswordNeverExpires  = $true
        Path                  = $TargetOu
        ChangePasswordAtLogon = $false
    }

    try {
        New-ADUser @parameters
        Write-Host "Created user: $($parameters.SamAccountName)" -ForegroundColor Green
        $createdUsers += $parameters.SamAccountName
    }
    catch {
        Write-Warning "Failed to create user '$($parameters.SamAccountName)': $_"
    }
}

Write-Host "Completed. Created $($createdUsers.Count) of $NumberOfAccountsToCreate requested accounts." -ForegroundColor Cyan

# Optional: list the first few accounts created for quick review.
$createdUsers | Select-Object -First 5 | ForEach-Object { Write-Host "Sample account: $_" -ForegroundColor Yellow }
