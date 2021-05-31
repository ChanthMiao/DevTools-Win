function Get-ItemSize {
    [CmdletBinding()]
    [OutputType([System.Int64], [string])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( { foreach ($Pa in $_) { Test-Path -Path $Pa } })]
        [Alias("FullName")]
        [string[]]
        $Path = $PWD,
        [Parameter()]
        [switch]
        $LiteralValue,
        [Parameter()]
        [switch]
        $Sum
    )

    begin {
        [System.Int64]$_Sum = 0
    }

    process {
        foreach ($p in $Path) {
            $meta = Get-Item $p
            # check path type
            $s = if ($meta.Attributes -eq 'Directory') {
                # Recurse search for files in directory. This would blocked when applied for a file.
                (Get-ChildItem -Path $p -Recurse -File | Measure-Object -Property Length -Sum).Sum
            }
            else {
                $meta.Length
            }
            if (-not $s) {
                # $s May be $null, if target path is an empty directory.
                $s = 0
            }
            if ($Sum) {
                $_Sum += $s
            }
            else {
                if ($LiteralValue) {
                    Write-Output $s
                }
                else {
                    Write-Output (Format-ItemSize $s)
                }
            }
        }
    }

    end {
        if ($Sum) {
            if ($LiteralValue) {
                Write-Output $_Sum
            }
            else {
                Write-Output (Format-ItemSize $_Sum)
            }
        }
    }
}

Set-Alias -Name gis -Value Get-ItemSize