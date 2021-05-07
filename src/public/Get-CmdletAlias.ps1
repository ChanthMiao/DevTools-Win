function Get-CmdletAlias ($cmdletname) {
    Get-Alias |
    Where-Object -FilterScript { $_.Definition -like "$cmdletname" } |
    Format-Table -Property Definition, Name -AutoSize
}

Set-Alias -Name gcas -Value Get-CmdletAlias
