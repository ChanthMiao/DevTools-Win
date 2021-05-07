function Get-WindowsAppId {
    if (Test-Path Variable:\AppId) {
        Get-Variable Appid -ValueOnly
    }
    elseif ($PSEdition -eq 'Desktop') {
        # May be ISE
        $app = (Get-Process -Pid $PID | Select-Object -ExpandProperty Description)
        $appid = (Get-StartApps -Name $app | Select-Object -ExpandProperty 'AppId' -First 1)
        Set-Variable -Name 'AppId' -Value $appid -Scope Global -Option ReadOnly
        return $appid
    }
    elseif ($PSVersionTable.PSVersion -ge [System.Management.Automation.SemanticVersion]'6.0') {
        Import-Module StartLayout -SkipEditionCheck
        $appid = (Get-StartApps -Name 'PowerShell' | Where-Object { $_.Name -match "^PowerShell $($PSVersionTable.PSVersion.Major)" } | Select-Object -ExpandProperty 'AppId' -First 1)
        Set-Variable -Name 'AppId' -Value $appid -Scope Global -Option ReadOnly
        return $appid
    }
    else {
        # Fallback
        '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    }
}