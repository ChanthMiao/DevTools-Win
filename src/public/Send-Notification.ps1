function Send-Notification {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Title")]
        [string]
        $ToastTitle,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Value", "Content", "Message", "Body")]
        [string[]]
        $ToastContent,
        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { 
                try {
                    if ((New-Object System.Uri $_).Scheme -in @('http', 'https', 'file')) {
                        return $true
                    }
                    else {
                        return $false
                    }
                }
                catch {
                    return $false
                }
            })]
        [string]
        $Icon = "$PSScriptRoot\..\..\assets\icon_64px.png",
        [Parameter(Position = 3)]
        [switch]
        $Silent
    )

    begin {
        if ($Silent) {
            $SoundElement = '<audio silent="true" />'
        }
        else {
            $SoundElement = '<audio src="ms-winsoundevent:Notification.Default" />'
        }
        $AppId = Get-WindowsAppId        
    }

    process {
        foreach ($msg in $ToastContent) {
            $XmlString = @"
            <toast>
            <visual>
                <binding template="ToastGeneric">
                <text>$ToastTitle</text>
                <text>$msg</text>
                <image src="$((Resolve-Path -Path $Icon).Path)" placement="appLogoOverride" hint-crop="circle" />
                </binding>
            </visual>
            $SoundElement
            </toast>
"@
            # Start-Job make it possible to unload Assemblies of WinRT interop.
            Start-Job -ScriptBlock {
                if ([System.Environment]::Version -lt [System.Version]"5.0.0") {
                    # In this case, use builtin WinRT Interop system.
                    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null
                    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
                }
                else {
                    Add-Type -Path $args
                }
                $ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
                $ToastXml.LoadXml($Using:XmlString)
                $Toast = [Windows.UI.Notifications.ToastNotification]::new($ToastXml)
                [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($Using:AppId).Show($Toast)
                if ($PSEdition -eq "Desktop") {
                    Write-Output "This just fix bug in Windows Powershell 5" | Out-Null
                }
            } -Name "$ToastTitle-$(New-Guid)" -ArgumentList "$(Resolve-Path "$PSScriptRoot\..\..\lib\Microsoft.Windows.SDK.NET.dll")" | Out-Null

        }
    }

    end {
        Get-Job -Name "$ToastTitle*" | Wait-Job -Timeout 3 | Remove-Job
    }
}

Set-Alias -Name sdnf -Value Send-Notification