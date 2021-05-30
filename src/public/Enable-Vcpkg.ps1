function Enable-Vcpkg {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                [System.IO.Path]::GetFileNameWithoutExtension((Get-Command ([System.IO.Path]::Combine($_, "vcpkg")))) -eq 'vcpkg'
            })]
        [string]
        $VcpkgRoot = (Get-Config -Name 'VcpkgRoot')
    )

    begin {
        [bool]$isVerbose = if ($VerbosePreference -eq "SilentlyContinue") { $false }else { $true }
    }

    end {
        Add-Path $VcpkgRoot -Verbose:$isVerbose
        if (Get-Module -Name posh-vcpkg -ErrorAction SilentlyContinue) {
            Write-Verbose "PSModule 'posh-vcpkg' already imported."
        }
        else {
            [System.IO.Path]::Combine($VcpkgRoot, 'scripts\posh-vcpkg') | Import-Module -Global
        }
    }
}

Set-Alias -Name evpg -Value Enable-Vcpkg