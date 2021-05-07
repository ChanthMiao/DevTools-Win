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
        $PassThru
    )

    begin {
        $_paths = New-Object 'System.Collections.Generic.List[string]'
        if (Test-Path "Env:\$Target") {
            (Get-Item "Env:\$Target" | Select-Object -ExpandProperty 'Value').Split(';') | ForEach-Object {
                $_paths.Add($_)
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
            if (-not (Test-Path -Path $pa -PathType Container)) {
                Write-Warning "Directory $pa does not exist, skiped!"
                Continue
            }
            if ($_paths.Contains($pa)) {
                Write-Verbose "Directory $pa is already in Env:\$Target, skiped!"
                Continue
            }
            if ($pa -match '.*?(?<!:)\\$') {
                $pa = $pa.TrimEnd('\')
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
        Set-Item -Path "Env:\$Target" -Value ($_paths -join ';')
        if ($PassThru) {
            $_paths | Write-Output
        }
    }
}

Set-Alias -Name apa -Value Add-Path