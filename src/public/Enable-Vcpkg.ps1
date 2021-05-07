function Enable-Vcpkg {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { (Get-Command  "$_\vcpkg" | Split-Path -LeafBase) -eq "vcpkg" })]
        [string]
        $VcpkgPath = $Script:DevToolsConf.Vcpkg
    )

    begin {
        [bool]$isVerbose = if ($VerbosePreference -eq "SilentlyContinue") { $false }else { $true }
    }

    end {
        Add-Path $VcpkgPath -Verbose:$isVerbose
        if (Get-Module -Name posh-vcpkg -ErrorAction SilentlyContinue) {
            Write-Verbose "PSModule 'posh-vcpkg' already imported."
        }
        else {
            Join-Path $VcpkgPath 'scripts\posh-vcpkg' | Import-Module -Global
        }
    }
}

Set-Alias -Name evpg -Value Enable-Vcpkg