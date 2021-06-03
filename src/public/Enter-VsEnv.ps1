function Enter-VsEnv {
    [CmdletBinding(DefaultParameterSetName = 'Select')]
    param (
        [Parameter(ParameterSetName = "Select", Position = 0)]
        [ValidateSet('2017', '2019')]
        [string]
        $Version,
        [Parameter(ParameterSetName = "Select")]
        [ValidateSet('Community', 'Professional', 'Enterprise', 'BuildTools')]
        [string]
        $Product,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "List")]
        [switch]
        $AllowPrerelease,
        [Parameter(ParameterSetName = "InstanceId", Position = 0, Mandatory = $true)]
        [ValidatePattern('^[0-9a-z]{8}$')]
        [Alias('id')]
        [string]
        $InstanceId,
        [Parameter(ParameterSetName = "InstallPath", Position = 0, Mandatory = $true)]
        [ValidateScript( { [System.IO.Directory]::Exists($_) })]
        [Alias('p', 'Path')]
        [string]
        $InstallPath,
        [Parameter(ParameterSetName = "List", Position = 0)]
        [Alias('l')]
        [switch]
        $List,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [switch]
        $NoSubShell,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [ValidateSet('x86', 'amd64', 'arm', 'arm64')]
        [string]
        $Arch,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [ValidateSet('x86', 'amd64')]
        [string]
        $HostArch,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [ValidatePattern('^(10\.0|8\.1)(\.\d+){1,3}|none$')]
        [string]
        $WinSDK,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [ValidateSet('Desktop', 'UWP')]
        [string]
        $AppType,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [ValidatePattern('^14(\.\d+){1,3}$')]
        [string]
        $VC,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [switch]
        $UseSpectreLibs,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [switch]
        $Silent,
        [Parameter(ParameterSetName = "Select")]
        [Parameter(ParameterSetName = "InstanceId")]
        [Parameter(ParameterSetName = "InstallPath")]
        [Parameter(ParameterSetName = "List")]
        [ValidateScript( {
                [System.IO.Path]::GetFileNameWithoutExtension((Get-Command $_)) -eq 'vswhere'
            })]
        [string]
        $VsWherePath = (Get-Config -Name 'VsWhere')
    )

    end {
        if (!$NoSubShell -and !$Env:DTW_VS_INSUBSHELL -and !$List) {
            $SelfInvokeCmdBuilder = [System.Collections.Generic.List[string]]@($PSCmdlet.MyInvocation.InvocationName)
            foreach ($k in $PSBoundParameters.Keys) {
                $v = $PSBoundParameters.Item($k)
                if (($v.GetType() -eq [switch]) -and $v) {
                    $SelfInvokeCmdBuilder.Add("-$k")
                }
                else {
                    $SelfInvokeCmdBuilder.Add("-$k $v")
                }
            }
            $SelfInvokeCmdBuilder.Add('-NoSubShell')
            $SelfInvokeCmd = [string]::Join(' ', $SelfInvokeCmdBuilder)
            $SelfModulePath = $PSCmdlet.MyInvocation.MyCommand.Module.Path
            Write-Host 'Launching subshell in virtual environment...' -ForegroundColor Green
            if ($PSEdition -eq 'Core') {
                pwsh -NoExit -NoLogo -Command "& { Import-Module $SelfModulePath; `$Env:DTW_VS_INSUBSHELL = 1; $SelfInvokeCmd }"
            }
            else {
                powershell -NoExit -NoLogo -Command "& { Import-Module $SelfModulePath; `$Env:DTW_VS_INSUBSHELL = 1; $SelfInvokeCmd }"
            }
            return
        }
        $QueryBuilder = [System.Collections.Generic.List[string]]@()
        $QueryBuilder.Add("& `"$VsWherePath`"")
        if ($InstallPath) {
            $InstallPath = [System.IO.Path]::GetFullPath($InstallPath)
            $QueryBuilder.Add("-path `"$InstallPath`"")
        }
        else {
            if ($AllowPrerelease) {
                $QueryBuilder.Add('-prerelease')
            }
            if ($Product) {
                $QueryBuilder.Add("-products Microsoft.VisualStudio.Product.$Product")
            }
            else {
                $QueryBuilder.Add('-products *')
            }
            if ($Version) {
                switch ($Version) {
                    '2019' { $QueryBuilder.Add('-version "[16.0,17.0)"') ; break }
                    '2017' { $QueryBuilder.Add('-version "[15.0,16.0)"') ; break }
                    Default {}
                }
            }
            if ($InstanceId -or $List) {
                $QueryBuilder.Add('-all -sort')
            }
            else {
                $QueryBuilder.Add('-latest')
            }
        }
        $QueryBuilder.Add('-format json -nologo -utf8')
        $Query = [string]::Join(' ', $QueryBuilder)
        Write-Debug $Query
        $Results = (Invoke-Expression $Query | ConvertFrom-Json)
        if ($List) {
            $Results | Select-Object instanceId, displayName, installationName, installationPath | Format-List
            return
        }
        if (-not $Results) {
            Write-Error "Failed to find required visualstudio instance."
            return
        }
        if ($InstanceId) {
            $Results = ($Results | Where-Object instanceId -EQ $InstanceId)
            if (-not $Results) {
                Write-Error "Failed to find required visualstudio instance."
                return
            }
        }
        $InstallPath = $Results.installationPath
        $VsDevCmdFile = [System.IO.Path]::Combine($InstallPath, "Common7", "Tools", "VsDevCmd.bat")
        if (-not ([System.IO.Path]::GetFileNameWithoutExtension((Get-Command $VsDevCmdFile)) -eq 'VsDevCmd')) {
            Write-Error 'Failed to find VsDevCmd.bat.'
            return
        }
        $VsDevCmdBuilder = [System.Collections.Generic.List[string]]@()
        $VsDevCmdBuilder.Add("& `"$VsDevCmdFile`" -startdir=none")
        if (-not $Arch) {
            $Arch = switch ($Env:PROCESSOR_ARCHITECTURE) {
                'AMD64' { 'amd64' }
                'X86' { 'x86' }
                Default { '' }
            }
        }
        if ($Arch) {
            $VsDevCmdBuilder.Add("-arch=$Arch")
        }
        if (-not $HostArch) {
            $HostArch = switch ($Env:PROCESSOR_ARCHITECTURE) {
                'AMD64' { 'amd64' }
                'X86' { 'x86' }
                Default { '' }
            }
        }
        if ($HostArch) {
            $VsDevCmdBuilder.Add("-host_arch=$HostArch")
        }
        if ($WinSDK) {
            $VsDevCmdBuilder.Add("-winsdk=$WinSDK")
        }
        if ($AppType) {
            $VsDevCmdBuilder.Add("-app_platform=$AppType")
        }
        if ($VC) {
            $VsDevCmdBuilder.Add("-vcvars_ver=$VC")
        }
        if ($UseSpectreLibs) {
            $VsDevCmdBuilder.Add('-vcvars_spectre_libs=spectre')
        }
        if ($Silent) {
            $VsDevCmdBuilder.Add('-no_logo')
        }
        else {
            $logoText = [System.Collections.Generic.List[string]]@()
        }
        $VsDevCmd = [string]::Join(' ', $VsDevCmdBuilder)
        Write-Debug $VsDevCmd
        $Env:VSCMD_SKIP_SENDTELEMETRY = "1"
        $Env:VSCMD_BANNER_SHELL_NAME_ALT = "Developer PowerShell"
        $Env:VSCMD_DEBUG = "2"
        Invoke-Expression $VsDevCmd | ForEach-Object -Process {
            $line = $_
            switch -Regex ($line) {
                "^\[DEBUG:(?'key'.*?)\] (?'value'.*?)$" { Write-Debug "[$($Matches.key)] $($Matches.value)" ; break }
                "^\[ERROR:(?'key'.*?)\] (?'value'.*?)$" { Write-Error "[$($Matches.key)] $($Matches.value)" ; break }
                "(?'key'[^=].*?)=(?'value'.*)$" {
                    if ($Matches.key -in @('Path', 'INCLUDE', 'LIB', 'LIBPATH')) {
                        $_VS_ADDED = [System.Environment]::GetEnvironmentVariable("_DTW_VS_$($Matches.key)_ADDED")
                        if ($_VS_ADDED) {
                            $_VS_ADDED.Split([System.IO.Path]::PathSeparator) | Remove-Path -Target $Matches.key -Mode 'All'
                        }
                        else {
                            $Original_Path = [System.Environment]::GetEnvironmentVariable($Matches.Key)
                            if ($Original_Path) {
                                $_new_path_set = [System.Collections.Generic.HashSet[string]]($Matches.value.Split([System.IO.Path]::PathSeparator))
                                $_new_path_set.ExceptWith($Original_Path.Split([System.IO.Path]::PathSeparator))
                                $_VS_ADDED = [string]::Join([System.IO.Path]::PathSeparator, $_new_path_set)
                                [System.Environment]::SetEnvironmentVariable("_DTW_VS_$($Matches.key)_ADDED", $_VS_ADDED)
                            }                            
                        }
                    }
                    [System.Environment]::SetEnvironmentVariable($Matches.key, $Matches.value)
                    break 
                }
                "^\*\*.*$" {
                    if (-not $Silent) {
                        $logoText.Add($line)
                        break 
                    }
                }
                Default { Write-Verbose $line }
            }
        }
        [System.Environment]::SetEnvironmentVariable('VSCMD_SKIP_SENDTELEMETRY', $null)
        [System.Environment]::SetEnvironmentVariable('VSCMD_BANNER_SHELL_NAME_ALT', $null)
        [System.Environment]::SetEnvironmentVariable('VSCMD_DEBUG', $null)
        if (-not $Silent) {
            $logoText | Write-Host
        }
    }
}

Set-Alias -Name etvs -Value Enter-VsEnv