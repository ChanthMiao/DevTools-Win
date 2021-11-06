function Set-DtwConfig {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Proxy', 'VsWhere', 'VcpkgRoot', 'Clang', 'PyRoot', 'RustMirror')]
        [string]
        $Name,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'string')]
        [ValidateNotNullOrEmpty()]
        [string]
        $StringValue
    )
    $Script:DevToolsConf[$Name] = $StringValue
}

Set-Alias -Name sdcf -Value Set-DtwConfig