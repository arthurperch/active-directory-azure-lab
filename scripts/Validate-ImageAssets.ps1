<#
.SYNOPSIS
    Validates that required image assets exist with the expected file names.
.DESCRIPTION
    Checks each screenshot path used in the README and reports whether the file
    is present. Provides recommended dimensions to help with replacement.
.NOTES
    Author: Oleg Perchatkin
    Version: 1.0
.EXAMPLE
    .\Validate-ImageAssets.ps1
#>

[CmdletBinding()]
param ()

$expectedImages = @(
    @{ Path = "..\images\hero\lab-hero.png"; Description = "Hero banner"; Size = "1920×1080" },
    @{ Path = "..\images\steps\architecture-topology.png"; Description = "Architecture diagram"; Size = "1600×900" },
    @{ Path = "..\images\steps\azure-portal-resource-group.png"; Description = "Azure Portal resource group"; Size = "1600×900" },
    @{ Path = "..\images\steps\domain-controller-dashboard.png"; Description = "Domain controller dashboard"; Size = "1600×900" },
    @{ Path = "..\images\steps\ad-users-and-computers.png"; Description = "ADUC users list"; Size = "1600×900" },
    @{ Path = "..\images\steps\gpo-account-lockout.png"; Description = "Account lockout GPO"; Size = "1600×900" }
)

$results = foreach ($image in $expectedImages) {
    $fullPath = Join-Path -Path $PSScriptRoot -ChildPath $image.Path
    [pscustomobject]@{
        File        = $image.Path
        Description = $image.Description
        ExpectedSize= $image.Size
        Exists      = Test-Path -LiteralPath $fullPath
    }
}

$results | Format-Table -AutoSize

if ($results.Exists -contains $false) {
    Write-Warning "One or more images are missing. Add the files listed above before pushing to GitHub."
} else {
    Write-Host "All image assets are present." -ForegroundColor Green
}
