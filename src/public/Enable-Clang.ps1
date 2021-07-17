function Enable-Clang {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                [System.IO.Path]::GetFileNameWithoutExtension((Get-Command $_)) -eq 'clang'
            })]
        [string]
        $ClangPath
    )
    [bool]$isVerbose = if ($VerbosePreference -eq "SilentlyContinue") { $false }else { $true }
    $_ClangPath = if ($ClangPath) {
        $ClangPath
    }
    else {
        Get-Config -Name 'Clang'
    }
    if (-not $_ClangPath) {
        Write-Error 'Clang installation not found! operation aborted.'
        return
    }
    $clangInfo = (&$_ClangPath --version)
    $clangInfo | Write-Verbose
    if (($clangInfo -match 'clang version').Count -eq 0) {
        Write-Error 'Failed to parse clang installation information.'
        return
    }
    $clangVersion = ($clangInfo -match 'clang version').Split()[-1]
    $clangInstallDir = ($clangInfo -match 'InstalledDir').Split(' ', 2)[1]
    $llvmInstallDir = [System.IO.Directory]::GetParent($clangInstallDir)
    $llvmIncludeDir = [System.IO.Path]::Combine($llvmInstallDir, "include")
    $llvmLibDir = [System.IO.Path]::Combine($llvmInstallDir, "lib")
    $clangIncludeDir = [System.IO.Path]::Combine($llvmInstallDir, "lib", "clang", $clangVersion, "include")
    $clangLibDir = [System.IO.Path]::Combine($llvmInstallDir, "lib", "clang", $clangVersion, "lib", "windows")
    # Add resources paths to environment variables.
    $llvmIncludeDir, $clangIncludeDir | Where-Object { [System.IO.Directory]::Exists($_) } | Add-Path -Target 'INCLUDE' -Verbose:$isVerbose
    $llvmLibDir, $clangLibDir | Where-Object { [System.IO.Directory]::Exists($_) } | Add-Path -Target 'LIB' -Verbose:$isVerbose
    # Make sure clang in path.
    Add-Path $clangInstallDir -Verbose:$isVerbose
}

Set-Alias -Name ecla -Value Enable-Clang