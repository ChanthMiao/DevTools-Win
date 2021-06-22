function Start-Log {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript( { 
                [System.String]::IsNullOrWhiteSpace($_) -or (Test-Path -Path $_ -IsValid)
            })]
        [string]
        $LogFile
    )

    end {
        if ([System.String]::IsNullOrWhiteSpace($LogFile)) {
            if (-not $MyInvocation.PSCommandPath) {
                Start-Transcript -OutputDirectory $Env:TEMP -Append -IncludeInvocationHeader -UseMinimalHeader
                return
            }
            $LogFile = [System.IO.Path]::Combine($MyInvocation.PSScriptRoot, "logs", "$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PSCommandPath)).log")
        }
        if (-not [System.IO.File]::Exists($LogFile)) {
            New-Item -Path $LogFile -ItemType File -Force
        }
        Start-Transcript -Path $LogFile -Append -IncludeInvocationHeader -UseMinimalHeader
    }
}

Set-Alias -Name salg -Value Start-Log