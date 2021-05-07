function Enter-VsEnv {
    [CmdletBinding(DefaultParameterSetName = "Latest")]
    param (
        [Parameter(ParameterSetName = "InstanceId", Position = 0)]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [Alias('i', 'Id')]
        [string]
        $InstanceId,
        [Parameter(ParameterSetName = "InstallPath", Position = 0)]
        [Alias('p', 'Path')]
        [string]
        $InstallPath,
        [Parameter(ParameterSetName = "List", Position = 0)]
        [Alias('l')]
        [switch]
        $List,
        [Parameter(ParameterSetName = "Latest", Position = 0)]
        [Parameter(ParameterSetName = "InstanceId", Position = 1)]
        [Parameter(ParameterSetName = "InstallPath", Position = 1)]
        [Parameter(ParameterSetName = "Advanced", Position = 0)]
        [ValidateSet("amd64", "x86")]
        [Alias('a')]
        [string]
        $Arch,
        [Parameter(ParameterSetName = "Advanced", Position = 1)]
        [ValidateSet("2017", "2019")]
        [Alias('v')]
        [string]
        $Version,
        [Parameter(ParameterSetName = "Advanced", Position = 2)]
        [ValidateSet("Community", "Professional", "Enterprise")]
        [Alias('e')]
        [string]
        $Edition,
        [Parameter(ParameterSetName = "Latest")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [Parameter(ParameterSetName = "Advanced")]
        [string]
        $CmdArgs,
        [Parameter(ParameterSetName = "Latest")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [Parameter(ParameterSetName = "List")]
        [Parameter(ParameterSetName = "Advanced")]
        [switch]
        $ExcludePrerelease,
        [Parameter(ParameterSetName = "Latest")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [Parameter(ParameterSetName = "Advanced")]
        [Alias('s')]
        [switch]
        $NoLogo,
        [Parameter(ParameterSetName = "Latest")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [Parameter(ParameterSetName = "List")]
        [Parameter(ParameterSetName = "Advanced")]
        [ValidateScript( { (Get-Command $_ | Split-Path -LeafBase) -eq 'vswhere' })]
        [string]
        $VsWherePath = $Script:DevToolsConf.Vswhere
    )
    
    begin {
        $vswhereCmd = "& `"$VsWherePath`"  -format json"
        switch ($PSCmdlet.ParameterSetName) {
            "Latest" { $vswhereCmd += " -latest" ; break }
            "InstanceId" { $vswhereCmd += " -all" ; break }
            "InstallPath" { $vswhereCmd += " -path $InstallPath" ; break }
            Default { $vswhereCmd += " -all -sort" }
        }
        if (-not $ExcludePrerelease -and ($PSCmdlet.ParameterSetName -ne "InstallPath")) {
            $vswhereCmd += " -prerelease"
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "List") {
            (Invoke-Expression $vswhereCmd | ConvertFrom-Json) | Select-Object instanceId, displayName, installationName, installationPath | Format-List
            return
        }
        $basePath = switch ($PSCmdlet.ParameterSetName) {
            "InsctanceId" { (Invoke-Expression $vswhereCmd | ConvertFrom-Json) | Where-Object { $_.instanceId -eq $InstanceId } | Select-Object -ExpandProperty installationPath ; break }
            "Advanced" {
                $_sets = Invoke-Expression $vswhereCmd
                if ($Version) {
                    $_sets = Where-Object { $_.catalog_productLineVersion -eq $Version } -InputObject $_sets
                }
                if ($Edition) {
                    $_sets = Where-Object { $_.productId -eq ("Microsoft.VisualStudio.Product." + $Edition) } -InputObject $_sets
                }
                $_sets | Select-Object -ExpandProperty installationPath -First
                break
            }
            Default { (Invoke-Expression $vswhereCmd | ConvertFrom-Json) | Select-Object  -ExpandProperty installationPath }
        }
        if (-not $basePath) {
            Write-Error "Could not find an installation of Visual Studio with given arguments!" -Category ObjectNotFound
            return
        }
        $cmdbat = Join-Path $basePath "Common7\Tools\VsDevCmd.bat"
        if (-not (Get-Command $cmdbat | Split-Path -Leaf) -eq 'VsDevCmd.bat' ) {
            Write-Error "Could not find VsDevCmd.bat!" -Category ObjectNotFound
            return
        }
        $cmdbatCall = "&`"$cmdbat`" -startdir=none"
        if ($Arch) {
            $cmdbatCall += " -arch=$Arch"
        }
        if ($NoLogo) {
            $cmdbatCall += " -no_logo"
        }
        if ($CmdArgs) {
            $cmdbatCall += " $CmdArgs"
        }
        if (-not $NoLogo -and $cmdbatCall.Contains("-no_logo")) {
            $cmdbatCall = $cmdbatCall -replace "-no_logo", ""
        }
        if ($cmdbatCall.Contains("-help")) {
            Invoke-Expression $cmdbatCall | Write-Host
            return
        }
        if ($cmdbatCall.Contains("-test")) {
            $cmdbatCall = $cmdbatCall -replace "-test", ""
            Write-Warning "Parameter '-test' not supported currently. Drop it."
        }
        $logoText = @()
        Invoke-Expression $cmdbatCall | ForEach-Object -Begin { 
            $Env:VSCMD_SKIP_SENDTELEMETRY = "1"
            $Env:VSCMD_BANNER_SHELL_NAME_ALT = "Developer PowerShell"
            $Env:VSCMD_DEBUG = "2" 
        } -Process {
            $line = $_
            switch -Regex ($line) {
                "^\[DEBUG:(?'key'.*?)\] (?'value'.*?)$" { Write-Debug "[$($Matches.key)] $($Matches.value)" ; break }
                "^\[ERROR:(?'key'.*?)\] (?'value'.*?)$" { Write-Error "[$($Matches.key)] $($Matches.value)" ; break }
                "(?'key'[^=].*?)=(?'value'.*)$" { Set-Item -Path "Env:\$($Matches.key)" -Value $Matches.value ; break }
                "^\*\*.*$" { $logoText += $line ; break }
                Default { Write-Verbose $line }
            }
        } -End {
            if (Test-Path Env:\VSCMD_SKIP_SENDTELEMETRY) {
                Remove-Item Env:VSCMD_SKIP_SENDTELEMETRY
            }
            if (Test-Path Env:\VSCMD_BANNER_SHELL_NAME_ALT) {
                Remove-Item Env:VSCMD_BANNER_SHELL_NAME_ALT
            }
            if (Test-Path Env:\VSCMD_DEBUG) {
                Remove-Item Env:\VSCMD_DEBUG
            }
            if (-not $NoLogo) {
                $logoText | Write-Host
            }
        }
    }
}

Set-Alias -Name etvs -Value Enter-VsEnv