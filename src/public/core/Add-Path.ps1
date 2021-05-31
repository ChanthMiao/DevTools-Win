function Add-Path {
    [CmdletBinding(DefaultParameterSetName = "Basic")]
    param (
        [Parameter(
            ParameterSetName = "Basic",
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Parameter(
            ParameterSetName = "Advanced",
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateScript( { foreach ($Pa in $_) { Test-Path -Path $Pa -IsValid } })]
        [Alias('FullName')]
        [string[]]
        $Path,
        [Parameter(ParameterSetName = "Basic", Position = 1)]
        [Parameter(ParameterSetName = "Advanced", Position = 1)]
        [string]
        $Target = 'Path',
        [Parameter(ParameterSetName = "Basic")]
        [switch]
        $Reverse,
        [Parameter(ParameterSetName = "Advanced")]
        [int]
        $Index = 0,
        [Parameter(ParameterSetName = "Basic")]
        [Parameter(ParameterSetName = "Advanced")]
        [switch]
        $Force,
        [Parameter(ParameterSetName = "Basic")]
        [Parameter(ParameterSetName = "Advanced")]
        [switch]
        $LiteralPath,
        [Parameter(ParameterSetName = "Basic")]
        [Parameter(ParameterSetName = "Advanced")]
        [switch]
        $PassThru
    )

    begin {
        $_paths = [System.Collections.Generic.List[string]]@()
        $TargetValue = [System.Environment]::GetEnvironmentVariable($Target)
        if ($TargetValue) {
            $pcs = $TargetValue.Split([System.IO.Path]::PathSeparator)
            foreach ($p in $pcs) {
                if ($_paths.Contains($p)) {
                    Continue
                }
                if (-not [System.IO.Path]::IsPathRooted($p)) {
                    $p = $p.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
                    $p = $p.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)
                    if ($_paths.Contains($p)) {
                        Continue
                    }
                }
                $_paths.Add($p)
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Advanced') {
            $sub = if ($Index -lt 0) {
                ($Index + $_paths.Count) % $_paths.Count
            }
            else {
                $Index
            }
            if (($sub -lt 0) -or ($sub -gt $_paths.Count)) {
                Write-Error "Index $Index is out of range!" -Category InvalidArgument
                return
            }
        }
    }

    process {
        foreach ($pa in $Path) {
            if (-not $LiteralPath) {
                # Get absolute path.
                $pa = [System.IO.Path]::GetFullPath($pa.Trim())
            }
            if (!$Force -and ![System.IO.Directory]::Exists($pa)) {
                Write-Warning "Directory $pa does not exist, skiped!"
                Continue
            }
            if ($_paths.Contains($pa)) {
                Write-Verbose "Directory $pa is already in Env:\$Target, skiped!"
                Continue
            }
            if (-not [System.IO.Path]::IsPathRooted($pa)) {
                $pa = $pa.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
                $pa = $pa.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)
                if ($_paths.Contains($pa)) {
                    Write-Verbose "Directory $pa is already in Env:\$Target, skiped!"
                    Continue
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Basic') {
                if ($Reverse) {
                    $_paths.Add($pa)
                }
                else {
                    $_paths.Insert(0, $pa)
                }
            }
            else {
                $_paths.Insert($sub, $pa)
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

Set-Alias -Name apa -Value Add-Path