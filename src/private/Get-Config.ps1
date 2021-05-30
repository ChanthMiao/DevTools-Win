function Get-Config {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Proxy', 'VsWhere', 'VcpkgRoot', 'Clang')]
        [string]
        $Name
    )
    switch ($Name) {
        'Proxy' {
            if ($Env:HTTP_PROXY -and ($Env:HTTP_PROXY -eq $Env:HTTPS_PROXY)) {
                $Env:HTTP_PROXY
            }
            else {
                $Script:DevToolsConf.Proxy
            }
        }
        'VsWhere' {
            if ($Env:VSWHERE_PATH) {
                $Env:VSWHERE_PATH
            }
            else {
                $Script:DevToolsConf.VsWhere
            }
        }
        'VcpkgRoot' {
            if ($Env:VCPKG_ROOT) {
                $Env:VCPKG_ROOT
            }
            else {
                $Script:DevToolsConf.VcpkgRoot
            }
        }
        'Clang' {
            if ($Env:CLANG_PATH) {
                $Env:CLANG_PATH
            }
            else {
                $Script:DevToolsConf.Clang
            }
        }
        Default { $null }
    }
}