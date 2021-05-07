$LevelTable = @{
    'Error'   = 0;
    'Warning' = 1;
    'Info'    = 2;
    'Debug'   = 3
}
$LogColor = @{
    'Error'   = 'Red';
    'Warning' = 'Yellow';
    'Info'    = 'Green';
    'Debug'   = 'Blue'
}

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]
        $Message,
        [Parameter()]
        [ValidateSet('Error', 'Warning', 'Info', 'Debug')]
        [string]
        $Level = 'Info'
    )
    
    begin {
        # See detail in https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.1#parent-and-child-scopes
        # Functions from a module do not run in a child scope of the calling scope.
        # Modules have their own session state that is linked to the global scope. 
        # All module code runs in a module-specific hierarchy of scopes that has its own root scope.
        # 
        # That means, to change $SysLevel, make sure change Variable:\LogLevel in global scope!
        $SysLevel = if ((Test-Path Variable:\LogLevel) -and $LevelTable.ContainsKey($LogLevel)) {
            $LevelTable[$LogLevel]
        }
        else {
            2
        }
        $localLevel = $LevelTable[$Level]
        $caller = if ($MyInvocation.PSCommandPath) {
            $MyInvocation.PSCommandPath | Split-Path -Leaf
        }
        else {
            'Interactive'
        }
        Write-Debug "sys: $SysLevel, localLevel: $localLevel"
    }

    process {
        foreach ($msg in $Message) {
            if ($localLevel -le $SysLevel) {
                if ($LogColor[$Level] -ne 'Default') {
                    Write-Host "$(Get-Date) $caller [$Level]: $msg" -ForegroundColor $LogColor[$Level]
                }
                else {
                    Write-Host "$(Get-Date) $caller [$Level]: $msg"
                }
            }
        }
    }
}

Set-Alias -Name wrlg -Value Write-Log