function Format-ItemSize {
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Length")]
        [System.Int64[]]$Bytes
    )
    process {
        foreach ($b in $Bytes) {
            if ($b -lt 1KB) {
                Write-Output "$b B"
            }
            elseif ($b -lt 1MB) {
                Write-Output "$([Math]::Round($b / 1KB, 2)) KB"
            }
            elseif ($b -lt 1GB) {
                Write-Output "$([Math]::Round($b / 1MB, 2)) MB"
            }
            elseif ($b -lt 1TB) {
                Write-Output "$([Math]::Round($b / 1GB, 2)) GB"
            }
            elseif ($b -lt 1PB) {
                Write-Output "$([Math]::Round($b / 1TB, 2)) TB"
            }
            else {
                Write-Output "$([Math]::Round($b / 1PB, 2)) PB"
            }
        }
    }
}

Set-Alias -Name fis -Value Format-ItemSize