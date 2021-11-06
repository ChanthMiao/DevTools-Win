function Get-Config {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [Parameter()]
        [switch]
        $NoDefault
    )
    switch ($Name) {
        'Proxy' {
            if ($Env:HTTP_PROXY -and ($Env:HTTP_PROXY -eq $Env:HTTPS_PROXY)) {
                $Env:HTTP_PROXY
            }
            elseif ($Script:DevToolsConf.Proxy) {
                $Script:DevToolsConf.Proxy
            }
            elseif (-not $NoDefault) {
                Get-DefaultConfig $Name
            }
            else {
                $null
            }
        }
        'VsWhere' {
            if ($Env:VSWHERE_PATH) {
                $Env:VSWHERE_PATH
            }
            elseif ($Script:DevToolsConf.VsWhere) {
                $Script:DevToolsConf.VsWhere
            }
            elseif (-not $NoDefault) {
                Get-DefaultConfig $Name
            }
            else {
                $null
            }
        }
        'VcpkgRoot' {
            if ($Env:VCPKG_ROOT) {
                $Env:VCPKG_ROOT
            }
            elseif ($Script:DevToolsConf.VcpkgRoot) {
                $Script:DevToolsConf.VcpkgRoot
            }
            elseif (-not $NoDefault) {
                Get-DefaultConfig $Name
            }
            else {
                $null
            }
        }
        'Clang' {
            if ($Env:CLANG_PATH) {
                $Env:CLANG_PATH
            }
            elseif ($Script:DevToolsConf.Clang) {
                $Script:DevToolsConf.Clang
            }
            elseif (-not $NoDefault) {
                Get-DefaultConfig $Name
            }
            else {
                $null
            }
        }
        'PyRoot' {
            if ($Env:PY_ROOT) {
                $Env:PY_ROOT
            }
            elseif ($Script:DevToolsConf.PyRoot) {
                $Script:DevToolsConf.PyRoot
            }
            elseif (-not $NoDefault) {
                Get-DefaultConfig $Name
            }
            else {
                $null
            }
        }
        'RustMirror' {
            if ($Env:Rust_Mirror) {
                $Env:Rust_Mirror
            }
            elseif ($Script:DevToolsConf.Rust_Mirror) {
                $Script:DevToolsConf.Rust_Mirror
            }
            elseif (-not $NoDefault) {
                Get-DefaultConfig $Name
            }
            else {
                $null
            }
        }
        Default { $null }
    }
}