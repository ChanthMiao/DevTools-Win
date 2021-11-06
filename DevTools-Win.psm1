# Currently, this module is windows only.
if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) {
    # Clear the variable which mounted privoius importing.
    if (Test-Path Variable:\AppId) {
        Remove-Variable -Name AppId -Scope Global -Force
    }
    # Private functions.
    . $PSScriptRoot\src\private\Get-WindowsAppId.ps1
    . $PSScriptRoot\src\private\Read-Config.ps1
    . $PSScriptRoot\src\private\Get-DefaultConfig.ps1
    . $PSScriptRoot\src\private\Get-Config.ps1
    # Public core functions.
    . $PSScriptRoot\src\public\core\Add-Path.ps1
    . $PSScriptRoot\src\public\core\Remove-Path.ps1
    . $PSScriptRoot\src\public\core\New-RandString.ps1
    . $PSScriptRoot\src\public\core\Get-DtwConfig.ps1
    . $PSScriptRoot\src\public\core\Set-DtwConfig.ps1
    . $PSScriptRoot\src\public\core\Show-DtwConfig.ps1
    # Public functions.
    . $PSScriptRoot\src\public\Format-ItemSize.ps1
    . $PSScriptRoot\src\public\Get-TempDir.ps1
    . $PSScriptRoot\src\public\Get-CmdletAlias.ps1
    . $PSScriptRoot\src\public\Start-Log.ps1
    . $PSScriptRoot\src\public\Stop-Log.ps1
    . $PSScriptRoot\src\public\Write-Log.ps1
    . $PSScriptRoot\src\public\Enable-Clang.ps1
    . $PSScriptRoot\src\public\Enable-Vcpkg.ps1
    . $PSScriptRoot\src\public\Enter-VsEnv.ps1
    . $PSScriptRoot\src\public\Send-Notification.ps1
    . $PSScriptRoot\src\public\Set-WebProxy.ps1
    . $PSScriptRoot\src\public\Clear-WebProxy.ps1
    . $PSScriptRoot\src\public\Get-ItemSize.ps1
    . $PSScriptRoot\src\public\Enable-Python.ps1
    . $PSScriptRoot\src\public\Set-RustMirror.ps1
    if ($Env:DevTools_UnSupported_Functions) {
        # Override some functions to hide them.
        $ufns = $Env:DevTools_UnSupported_Functions -split ';'
        foreach ($fn in $ufns) {
            Invoke-Expression "function $fn {Write-Error `"This function is not supported, because of the runtime limit.`"}"
        }
    }
    # Read Config from json file.
    Read-Config
}
else {
    throw (New-Object System.Management.Automation.RuntimeException "This Module is Windows only.")
}
# Cleanup
if (Get-Module "DevTools-Check" -ErrorAction SilentlyContinue) {
    Remove-Module "DevTools-Check"
}