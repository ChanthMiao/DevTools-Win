function Set-DtwConfig {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Proxy', 'VsWhere', 'VcpkgRoot', 'Clang', 'PyRoot')]
        [string]
        $Name,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'string')]
        [ValidateNotNullOrEmpty()]
        [string]
        $StringValue
    )
    switch ($Name) {
        'Proxy' {
            $Script:DevToolsConf.Proxy = $StringValue
        }
        'VsWhere' {
            $Script:DevToolsConf.VsWhere = $StringValue
        }
        'VcpkgRoot' {
            $Script:DevToolsConf.VcpkgRoot = $StringValue
        }
        'Clang' {
            $Script:DevToolsConf.Clang = $StringValue
        }
        'PyRoot' {
            $Script:DevToolsConf.PyRoot = $StringValue
        }
        Default {}
    }
}

Set-Alias -Name sdcf -Value Set-DtwConfig