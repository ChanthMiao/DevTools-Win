function Get-DefaultConfig {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name
    )
    switch ($Name) {
        'Proxy' {
            $null
        }
        'VsWhere' {
            "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        }
        'VcpkgRoot' {
            $null
        }
        'Clang' {
            $null
        }
        'PyRoot' {
            # Auto detect installed python.
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
        Default { $null }
    }
}