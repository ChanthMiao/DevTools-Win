function Set-WebProxy {
    [CmdletBinding(DefaultParameterSetName = "Basic")]
    [OutputType([System.Net.Webproxy])]
    param (
        [Parameter(ParameterSetName = "Basic", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^http://(?:[^:@]+:(?:[^@:]|\\:|\\@)+@)?([^:@]+|\[[:0-9a-fA-F]+\])(:\d+)?/?$")]
        [Alias("P")]
        [string]
        $Proxy,
        [Parameter(ParameterSetName = "Basic", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Uri", "AbsoluteUri")]
        [string[]]
        $ByPass,
        [Parameter(ParameterSetName = "Basic")]
        [switch]
        $NoDefaultCredentials,
        [Parameter(ParameterSetName = "Adavanced", Mandatory = $true, Position = 0)]
        [System.Net.Webproxy]
        $ProxyObject,
        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        $Proxy_In = if ($Proxy) {
            $Proxy
        }
        else {
            Get-Config -Name 'Proxy'
        }
        $ByPassList = New-Object 'System.Collections.Generic.List[string]'
        $_proxy = New-Object 'System.Net.Webproxy'
    }

    process {
        if ($ByPass) {
            foreach ($Uri in $ByPass) {
                $ByPassList.Add($Uri)
            }
        }   
    }

    end {
        if ($ProxyObject) {
            $_proxy = $ProxyObject
        }
        elseif ($Proxy_In) {
            $caps = [regex]::Match($Proxy, '^http://(?<credentials>(?<user>[^:@]+):(?<passwd>(?:[^@:]|\\:|\\@)+)@)?(?<address>(?:[^@:]+|\[[:0-9a-fA-F]+\])(?::\d+)?/?)$').Groups
            $address = $caps | Where-Object { $_.Name -eq "address" } | Select-Object -ExpandProperty "Value"
            $_proxy.Address = "http://$address"
            $_proxy.BypassProxyOnLocal = $true
            if ($caps | Where-Object { $_.Name -eq "credentials" } | Select-Object -ExpandProperty "Success") {
                $user = $caps | Where-Object { $_.Name -eq "user" } | Select-Object -ExpandProperty "Value"
                $passwd = ($caps | Where-Object { $_.Name -eq "passwd" } | Select-Object @{l = 'Value'; e = { $_.Value -replace '\\([@:])', '$&' } }).Value
                $_proxy.Credentials = New-Object System.Net.NetworkCredential $user, $passwd
            }
            elseif (-not $NoDefaultCredentials) {
                $_proxy.UseDefaultCredentials = $true
            }
            if ($ByPassList.Length -gt 0) {
                $_proxy.BypassList = $ByPassList
            }
        }
        else {
            # Do nothing.
            Write-Error 'Proxy not found! Operation aborted.'
            return
        }
        $Env:HTTP_PROXY = $_proxy.Address.ToString().TrimEnd('/')
        $Env:HTTPS_PROXY = $Env:HTTP_PROXY
        # Not standardized.
        #if ($_proxy.BypassList) {
        #    $Env:NO_PROXY = (($_proxy.BypassList -join ',') -replace ';', '')
        #}
        [System.Net.WebRequest]::DefaultWebProxy = $_proxy
        if ([System.Environment]::Version -ge [System.Version]"5.0.0") {
            [System.Net.Http.HttpClient]::DefaultProxy = $_proxy
        }
        Write-Verbose "Set webproxy as below."
        $_proxy | Write-Verbose
        if ($PassThru) {
            $_proxy | Write-Output
        }
    }
}

Set-Alias -Name swp -Value Set-WebProxy