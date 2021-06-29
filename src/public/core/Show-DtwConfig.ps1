function Show-DtwConfig {
    param (
        [Parameter()]
        [switch]
        $ExpandDefault
    )
    $outdict = [ordered]@{}
    $dopts = $Script:DevToolsConf.Keys
    foreach ($key in $dopts) {
        if ($ExpandDefault) {
            $outdict.Add($key, (Get-Config $key))
        }
        else {
            $outdict.Add($key, (Get-Config $key -NoDefault))
        }
    }
    $outdict | Write-Output
}

Set-Alias -Name shdcf -Value Show-DtwConfig