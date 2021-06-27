function Remove-Path {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'Value',
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateScript( { foreach ($Pa in $_) { Test-Path -Path $Pa -IsValid } })]
        [Alias('FullName')]
        [string[]]
        $Path,
        [Parameter(ParameterSetName = 'Script', Position = 0, Mandatory = $true)]
        [scriptblock]
        $Match,
        [Parameter(ParameterSetName = 'Value' , Position = 1)]
        [Parameter(ParameterSetName = 'Script' , Position = 1)]
        [string]
        $Target = 'Path',
        [Parameter(ParameterSetName = 'Value')]
        [ValidateSet('Default', 'First', 'Last', 'All')]
        [string]
        $Mode,
        [Parameter(ParameterSetName = 'Value')]
        [switch]
        $LiteralPath,
        [Parameter(ParameterSetName = 'Value')]
        [Parameter(ParameterSetName = 'Script')]
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
            $pa = $pa.Trim()
            [string]$formatted_path = [System.IO.Path]::GetFullPath("$pa\", $PSCmdlet.CurrentProviderLocation("FileSystem").ProviderPath)
            if (-not $_paths.Contains($formatted_path)) {
                if ([System.IO.Path]::GetPathRoot($formatted_path) -ne $formatted_path) {
                    $formatted_path = $formatted_path.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
                    if (-not $_paths.Contains($formatted_path)) {
                        Write-Verbose "Directory $formatted_path is not in Env:\$Target, skiped!"
                        Continue
                    }
                }
            }
            if (-not $LiteralPath) {
                $pa = $formatted_path
            }
            switch ($Mode) {
                'All' { $_paths.RemoveAll( { param($_p) $_p -eq $pa }) | Out-Null; break }
                'Last' { $_paths.RemoveAt($_paths.LastIndexOf($pa)); break }
                'First' { $_paths.Remove($pa) | Out-Null; break }
                Default { $_paths.Remove($pa) | Out-Null }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq 'Script') {
            $_paths = $_paths.Where( { !$Match.Invoke($_) })
        }
        [System.Environment]::SetEnvironmentVariable($Target, [string]::Join([System.IO.Path]::PathSeparator, $_paths))
        if ($PassThru) {
            $_paths | Write-Output
        }
    }
}

Set-Alias -Name rpa -Value Remove-Path