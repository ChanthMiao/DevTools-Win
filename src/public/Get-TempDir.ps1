function Get-TempDir {
    [OutputType([System.IO.DirectoryInfo])]
    param (
        [Parameter()]
        [switch]
        $System
    )
    if ($System) {
        if ($t = [System.Environment]::GetEnvironmentVariable('TMP')) {
            return (Get-Item $t)
        }
        elseif ($t = [System.Environment]::GetEnvironmentVariable('TEMP')) {
            return (Get-Item $t)
        }
        elseif ($t = [System.Environment]::GetEnvironmentVariable('USERPROFILE')) {
            return (Get-Item $t)
        }
        else {
            return (Get-Item [System.Environment]::GetEnvironmentVariable('windir'))
        }
        
    }
    else {
        if ($Env:TMP) {
            return (Get-Item $Env:TMP)
        }
        elseif ($Env:TEMP) {
            return (Get-Item $Env:TEMP)
        }
        elseif ($Env:USERPROFILE) {
            return (Get-Item $Env:USERPROFILE)
        }
        else {
            return (Get-Item $Env:windir)
        }
    }
}

Set-Alias -Name gtd -Value Get-TempDir