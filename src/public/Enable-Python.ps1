function Enable-Python {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                [System.IO.Path]::GetFileNameWithoutExtension((Get-Command ([System.IO.Path]::Combine($_, "python")))) -eq 'python'
            })]
        [string]
        $PyRoot
    )
    end {
        [bool]$isVerbose = if ($VerbosePreference -eq "SilentlyContinue") { $false }else { $true }
        if (-not $PyRoot) {
            $PyRoot = Get-Config -Name 'PyRoot'
        }
        if (-not $PyRoot) {
            Write-Error 'Python installation not found! operation aborted.'
            return
        }

        if ($Env:DTW_PY_ROOT) {
            $DTW_PyScriptDir = [System.IO.Path]::Combine($Env:DTW_PY_ROOT, 'Scripts')
            $Env:DTW_PY_ROOT, $DTW_PyScriptDir | Remove-Path -Verbose:$isVerbose -Mode 'All'
        }
        $PyScriptDir = [System.IO.Path]::Combine($PyRoot, 'Scripts')
        $PyScriptDir, $PyRoot | Add-Path -Verbose:$isVerbose
        $Env:DTW_PY_ROOT = $PyRoot
    }
}

Set-Alias -Name epy -Value Enable-Python