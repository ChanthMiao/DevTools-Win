function Get-Config {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Proxy', 'VsWhere', 'VcpkgRoot', 'Clang', 'PyRoot')]
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
        'PyRoot' {
            if ($Env:PY_ROOT) {
                $Env:PY_ROOT
            }
            elseif ($Script:DevToolsConf.PyRoot) {
                $Script:DevToolsConf.PyRoot
            }
            else {
                # Fallback: auto detect installed python.
                if (Test-Path "HKCU:\Software\Python\PythonCore\*\InstallPath") {
                    Get-ItemPropertyValue -Path "HKCU:\Software\Python\PythonCore\*\InstallPath" -Name '(default)' | Select-Object -First 1
                }
                elseif (Test-Path "HKLM:\Software\Python\PythonCore\*\InstallPath") {
                    Get-ItemPropertyValue -Path "HKLM:\Software\Python\PythonCore\*\InstallPath" -Name '(default)' | Select-Object -First 1
                }
                else {
                    $null
                }
            }
        }
        Default { $null }
    }
}