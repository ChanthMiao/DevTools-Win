function Get-DtwConfig {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Proxy', 'VsWhere', 'VcpkgRoot', 'Clang', 'PyRoot')]
        [string]
        $Name,
        [Parameter()]
        [switch]
        $ExpandDefault
    )
    if ($ExpandDefault) {
        return Get-Config $Name
    }
    else {
        return Get-Config $Name -NoDefault
    }
}

Set-Alias -Name gdcf -Value Get-DtwConfig