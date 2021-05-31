function Remove-Path {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateScript( { foreach ($Pa in $_) { Test-Path -Path $Pa -IsValid } })]
        [Alias('FullName')]
        [string[]]
        $Path,
        [Parameter(, Position = 1)]
        [string]
        $Target = 'Path',
        [Parameter()]
        [ValidateSet('Default', 'First', 'Last', 'All')]
        [string]
        $Mode,
        [Parameter()]
        [switch]
        $LiteralPath,
        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        $_paths = [System.Collections.Generic.List[string]]@()
        $TargetValue = [System.Environment]::GetEnvironmentVariable($Target)
        if ($TargetValue) {
            $TargetValue.Split([System.IO.Path]::PathSeparator).ForEach( { $_paths.Add($_) })
        }
    }

    process {
        foreach ($pa in $Path) {
            if (-not $LiteralPath) {
                # Get absolute path.
                $pa = [System.IO.Path]::GetFullPath($pa.Trim())
            }
            if (-not $_paths.Contains($pa)) {
                if (-not [System.IO.Path]::IsPathRooted($pa)) {
                    $pa = $pa.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
                    $pa = $pa.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)
                    if (-not $_paths.Contains($pa)) {
                        Write-Verbose "Directory $pa is not in Env:\$Target, skiped!"
                        Continue
                    }
                }
            }
            switch ($Mode) {
                'All' { $_paths.RemoveAll($pa) | Out-Null; break }
                'Last' { $_paths.RemoveAt($_paths.LastIndexOf($pa)); break }
                'First' { $_paths.Remove($pa) | Out-Null; break }
                Default { $_paths.Remove($pa) | Out-Null }
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