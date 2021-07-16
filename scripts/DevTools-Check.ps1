# This script should only be invoked by 'MyTools.psd1', which does some checks first.
#
# Only check for Windows.
if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) {
    $UnSupported_Functions = "Send-Notification"

    if (Test-Path Env:\DevTools_UnSupported_Functions) {
        Remove-Item Env:\DevTools_UnSupported_Functions
    }

    $ModuleRoot = [System.IO.Path]::GetFullPath("$PSScriptRoot\..")
    $PlaceHolder = [System.IO.Path]::Combine($Env:LOCALAPPDATA, 'DevTools-Win', 'disable-cswinrt')
    $disable_cswinrt = if ([System.IO.File]::Exists($PlaceHolder)) {
        $true
    }
    else {
        $false
    }

    if ([System.Environment]::Version -ge [System.Version]"5.0.0") {
        if (([System.Environment]::OSVersion.Version -lt [System.Version]"10.0.17763.0") -or $disable_cswinrt) {
            $Env:DevTools_UnSupported_Functions = $UnSupported_Functions
        }
        else {
            # dot source 'Install-Dll.ps1'.
            . "${PSScriptRoot}\Install-Dlls.ps1"
            # The existing WinRT interop system has been removed from the .NET runtime as part of .NET 5.0.
            # Load Microsoft.Windows.SDK.NET.dll and WinRT.Runtime.dll.
            $LocalCswinrtVersion = Get-LocalDllVersion -DllPath "$ModuleRoot\lib\WinRT.Runtime.dll"
            $LocalWdkVersion = Get-LocalDllVersion -DllPath "$ModuleRoot\lib\Microsoft.Windows.SDK.NET.dll"
            $WdkPattern = if ([System.Environment]::OSVersion.Version -ge [System.Version]"10.0.20348.0") {
                "10.0.20348."
            }
            elseif ([System.Environment]::OSVersion.Version -ge [System.Version]"10.0.19041.0") {
                "10.0.19041."
            }
            elseif ([System.Environment]::OSVersion.Version -ge [System.Version]"10.0.18362.0") {
                "10.0.18362."
            }
            else {
                "10.0.17763."
            }
            # Need download deps.
            if ((-not $LocalCswinrtVersion) -or (-not $LocalWdkVersion)) {
                $BaseUri = Get-PackageBaseAddress -ErrorAction SilentlyContinue
                if (-not $BaseUri) {
                    $BaseUri = "https://api.nuget.org/v3-flatcontainer/"
                    Write-Warning "Fallback to hard coded resource api: $BaseUri."
                }
                try {
                    # For load speed, not invoke update here.
                    if (-not $LocalWdkVersion) {
                        $WdkVersion = (Get-PackageVersions -LowID "microsoft.windows.sdk.net.ref" -PackageBaseAddress $BaseUri | Select-String -Pattern $WdkPattern)[-1]
                        $Wdk = Invoke-NupkgDownload -LowID "microsoft.windows.sdk.net.ref" -LowVersion $WdkVersion -PackageBaseAddress $BaseUri
                        "lib\WinRT.Runtime.dll", "lib\Microsoft.Windows.SDK.NET.dll" | Invoke-NupkgExtract -NupkgPath $Wdk -DestDir "$ModuleRoot\lib"
                    }
                }
                catch {
                    $Env:DevTools_UnSupported_Functions = $UnSupported_Functions
                }
                finally {
                    Remove-Item "$PSScriptRoot/*.nupkg" -Force
                }
            }
        }
    }
}