<#
.SYNOPSIS
    Validation script for the Active Directory Azure Lab.
.DESCRIPTION
    Runs a series of tests to confirm DNS, Active Directory, and Group Policy configuration.
.NOTES
    Author: Oleg Perchatkin
    Version: 1.0
    Requires: Active Directory PowerShell Module, RSAT tools
.EXAMPLE
    .\Test-ADConfiguration.ps1
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$DomainControllerName = "dc01",

    [Parameter(Mandatory = $false)]
    [string]$TestUserOu = "OU=_EMPLOYEES,DC=mydomain,DC=com",

    [Parameter(Mandatory = $false)]
    [string]$RequiredGpoName = "Account Lockout Policy"
)

$results = @()

function Add-TestResult {
    param (
        [string]$Name,
        [bool]$Passed,
        [string]$Details
    )

    $results += [pscustomobject]@{
        Test    = $Name
        Passed  = $Passed
        Details = $Details
    }
}

try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Add-TestResult -Name "ActiveDirectory module" -Passed $false -Details "Module not available: $_"
    $results | Format-Table
    return
}

$domain = Get-ADDomain -ErrorAction Stop
Add-TestResult -Name "Domain discovery" -Passed $true -Details "Found domain $($domain.DNSRoot)"

# Test 1: DNS service running on domain controller
try {
    $dnsService = Get-Service -Name DNS -ComputerName $DomainControllerName -ErrorAction Stop
    $passed = $dnsService.Status -eq 'Running'
    Add-TestResult -Name "DNS service status" -Passed $passed -Details "Status: $($dnsService.Status)"
}
catch {
    Add-TestResult -Name "DNS service status" -Passed $false -Details $_.Exception.Message
}

# Test 2: LDAP SRV record
try {
    $srvRecord = Resolve-DnsName -Name "_ldap._tcp.dc._msdcs.$($domain.DNSRoot)" -Type SRV -ErrorAction Stop
    $target = ($srvRecord | Select-Object -First 1).NameTarget
    Add-TestResult -Name "LDAP SRV record" -Passed $true -Details "Resolved target: $target"
}
catch {
    Add-TestResult -Name "LDAP SRV record" -Passed $false -Details $_.Exception.Message
}

# Test 3: Sample user existence in target OU
try {
    $userCount = (Get-ADUser -Filter * -SearchBase $TestUserOu).Count
    $passed = $userCount -gt 0
    Add-TestResult -Name "Lab user objects" -Passed $passed -Details "Users found: $userCount"
}
catch {
    Add-TestResult -Name "Lab user objects" -Passed $false -Details $_.Exception.Message
}

# Test 4: GPO existence
try {
    Import-Module GroupPolicy -ErrorAction Stop
    $gpo = Get-GPO -Name $RequiredGpoName -ErrorAction Stop
    Add-TestResult -Name "Required GPO" -Passed $true -Details "Found GPO with ID $($gpo.Id)"
}
catch {
    Add-TestResult -Name "Required GPO" -Passed $false -Details $_.Exception.Message
}

# Test 5: Account lockout threshold
try {
    $policy = Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop
    $threshold = $policy.LockoutThreshold
    $passed = $threshold -gt 0
    Add-TestResult -Name "Account lockout threshold" -Passed $passed -Details "Threshold: $threshold"
}
catch {
    Add-TestResult -Name "Account lockout threshold" -Passed $false -Details $_.Exception.Message
}

# Test 6: Basic replication health (single DC should still pass)
try {
    $dcDiag = & dcdiag /test:Services 2>$null
    $passed = $LASTEXITCODE -eq 0
    Add-TestResult -Name "dcdiag services test" -Passed $passed -Details ($dcDiag -join ' ')
}
catch {
    Add-TestResult -Name "dcdiag services test" -Passed $false -Details $_.Exception.Message
}

# Output summary table
$results | Format-Table -AutoSize

# Provide a simple pass/fail summary
if ($results.Where({ -not $_.Passed }).Count -eq 0) {
    Write-Host "All validation checks passed." -ForegroundColor Green
}
else {
    Write-Warning "One or more validation checks failed. Review the details above." 
}
