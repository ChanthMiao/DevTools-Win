function Enable-Python {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                [System.IO.Path]::GetFileNameWithoutExtension((Get-Command ([System.IO.Path]::Combine($_, "python")))) -eq 'python'
            })]
        [string]
        $PyRoot = (Get-Config -Name 'PyRoot')
    )
    end {
        [bool]$isVerbose = if ($VerbosePreference -eq "SilentlyContinue") { $false }else { $true }
        if ($Env:DTW_PY_ROOT) {
            $DTW_PyScriptDir = [System.IO.Path]::Combine($Env:DTW_PY_ROOT, 'Scripts')
            $Env:DTW_PY_ROOT, $DTW_PyScriptDir | Remove-Path -Verbose:$isVerbose -Mode 'All'
        }
        $PyScriptDir = [System.IO.Path]::Combine($PyRoot, 'Scripts')
        $PyRoot, $PyScriptDir | Add-Path -Verbose:$isVerbose
        $Env:DTW_PY_ROOT = $PyRoot
    }
}

Set-Alias -Name epy -Value Enable-Python