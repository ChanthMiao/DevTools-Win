function Remove-Path {
    [CmdletBinding(DefaultParameterSetName = "ByIndex")]
    param (
        [Parameter(
            ParameterSetName = "ByValue",
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateScript( { foreach ($Pa in $_) { Test-Path -Path $Pa -IsValid } })]
        [Alias('FullName')]
        [string[]]
        $Path,
        [Parameter(
            ParameterSetName = "ByIndex",
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [int[]]
        $Index = 0,
        [Parameter(ParameterSetName = "ByValue", Position = 1)]
        [Parameter(ParameterSetName = "ByIndex", Position = 1)]
        [string]
        $Target = 'Path',
        [Parameter(ParameterSetName = "ByValue")]
        [switch]
        $Reverse,
        [Parameter(ParameterSetName = "ByValue")]
        [switch]
        $All,
        [Parameter(ParameterSetName = "ByValue")]
        [Parameter(ParameterSetName = "ByIndex")]
        [switch]
        $PassThru
    )

    begin {
        $_paths = New-Object 'System.Collections.Generic.List[string]'
        $TargetValue = [System.Environment]::GetEnvironmentVariable($Target)
        if ($TargetValue) {
            $TargetValue.Split(';').ForEach( { $_paths.Add($_) })
        }
        if ($PSCmdlet.ParameterSetName -eq 'Advanced') {
            if ($Index -gt $_paths.Count) {
                Write-Error "Index is out of range!" -Category InvalidArgument
                return
            }
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "ByValue") {
            foreach ($pa in $Path) {
                if (-not $_paths.Contains($pa)) {
                    if ($pa.EndsWith([System.IO.Path]::DirectorySeparatorChar) -and ![System.IO.Path]::IsPathRooted($pa)) {
                        $pa = $pa.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
                        if (-not $_paths.Contains($pa)) {
                            Write-Verbose "Directory $pa is not in Env:\$Target, skiped!"
                            Continue
                        }
                    }
                    else {
                        Write-Verbose "Directory $pa is not in Env:\$Target, skiped!"
                        Continue
                    }
                }
                if ($All) {
                    $_paths.RemoveAll($pa) | Out-Null
                }
                elseif ($Reverse) {
                    $_paths.RemoveAt($_paths.LastIndexOf($pa))
                }
                else {
                    $_paths.Remove($pa) | Out-Null
                }
            }
        }
        else {
            foreach ($i in $Index) {
                $sub = if ($i -lt 0) {
                    ($i + $_paths.Count) % $_paths.Count
                }
                else {
                    $i
                }
                if (($sub -lt 0) -or ($sub -ge $_paths.Count)) {
                    Write-Error "Index $i is out of range! Skiped." -Category InvalidArgument
                    Continue
                }
                $_paths.RemoveAt($sub)
            }
        }
    }

    end {
        [System.Environment]::SetEnvironmentVariable($Target, [string]::Join([System.IO.Path]::PathSeparator, $_paths))
        if ($PassThru) {
            $_paths | Write-Output
        }
    }
}

Set-Alias -Name rpa -Value Remove-Path