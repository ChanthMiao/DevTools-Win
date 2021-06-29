function Clear-WebProxy {
    [CmdletBinding()]
    param ()
    if (Test-Path Env:\HTTP_PROXY) {
        Remove-Item Env:\HTTP_PROXY
    }
    if (Test-Path Env:\HTTPS_PROXY) {
        Remove-Item Env:\HTTPS_PROXY
    }
    if (Test-Path Env:\NO_PROXY) {
        Remove-Item Env:\NO_PROXY
    }
    [System.Net.WebRequest]::DefaultWebProxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
    if ([System.Environment]::Version -ge [System.Version]"5.0.0") {
        [System.Net.Http.HttpClient]::DefaultProxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
    }
}

Set-Alias -Name clwp -Value Clear-WebProxy