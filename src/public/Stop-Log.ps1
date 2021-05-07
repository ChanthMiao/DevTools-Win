function Stop-Log {
    [CmdletBinding()]
    param ()
    Stop-Transcript
}

Set-Alias -Name splg -Value Stop-Log