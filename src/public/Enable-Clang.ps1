function Enable-Clang {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { 
                (Get-Command $_ | Split-Path -LeafBase) -eq 'clang' 
            })]
        [string]
        $ClangPath = $Script:DevToolsConf.Clang
    )
    [bool]$isVerbose = if ($VerbosePreference -eq "SilentlyContinue") { $false }else { $true }
    $clangInfo = (&$ClangPath --version)
    $clangInfo | Write-Verbose
    if (($clangInfo -match 'clang version').Count -eq 0) {
        Write-Error 'Failed to parse clang installation information.'
        return
    }
    $clangVersion = ($clangInfo -match 'clang version').Split()[-1]
    $clangInstallDir = ($clangInfo -match 'InstalledDir').Split(' ', 2)[1]
    $llvmInstallDir = Split-Path $clangInstallDir
    $llvmIncludeDir = Join-Path $llvmInstallDir "include"
    $llvmLibDir = Join-Path $llvmInstallDir "lib"
    $clangIncludeDir = Join-Path $llvmInstallDir "lib\clang" $clangVersion "include"
    $clangLibDir = Join-Path $llvmInstallDir "lib\clang" $clangVersion "lib\windows"
    # Add resources paths to environment variables.
    $llvmIncludeDir, $clangIncludeDir | Add-Path -Target 'INCLUDE'
    $llvmLibDir, $clangLibDir | Add-Path -Target 'LIB'
    # Make sure clang in path.
    Add-Path $clangInstallDir -Verbose:$isVerbose
}

Set-Alias -Name ecla -Value Enable-Clang