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
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                [System.Uri]$_checked_uri = $null
                if (-not [System.Uri]::TryCreate($_, [System.UriKind]::Absolute, [ref]$_checked_uri)) {
                    $false
                }
                elseif ($_checked_uri.Scheme -notin @('http', 'https', 'file')) {
                    $false
                }
                elseif ($_checked_uri.IsFile -and !(Test-Path $_checked_uri.AbsolutePath -PathType Leaf)) {
                    $false
                }
                else {
                    $true
                }
            })]
        [string]
        $Icon = "$PSScriptRoot\..\..\assets\icon_64px.png",
        [Parameter()]
        [switch]
        $Silent,
        [Parameter()]
        [switch]
        $NoWait
    )

    begin {
        if ($Silent) {
            $SoundElement = '<audio silent="true" />'
        }
        else {
            $SoundElement = '<audio src="ms-winsoundevent:Notification.Default" />'
        }
        $AppId = Get-WindowsAppId
        $Icon = [System.Uri]::new($Icon, [System.UriKind]::Absolute).AbsoluteUri
    }

    process {
        foreach ($msg in $ToastContent) {
            $XmlString = @"
            <toast>
            <visual>
                <binding template="ToastGeneric">
                <image src="$Icon" placement="appLogoOverride" hint-crop="circle" />
                <text>$ToastTitle</text>
                <text>$msg</text>
                </binding>
            </visual>
            $SoundElement
            </toast>
"@
            $jprefix = "psnotification-$(New-RandString)"
            # Start-Job make it possible to unload Assemblies of WinRT interop.
            $job = Start-Job -ScriptBlock {
                if ([System.Environment]::Version -lt [System.Version]"5.0.0") {
                    # In this case, use builtin WinRT Interop system.
                    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null
                    [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
                    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
                }
                else {
                    # Load WinRT assembly file.
                    Add-Type -Path $args
                }
                $ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
                $ToastXml.LoadXml($Using:XmlString)
                $Toast = [Windows.UI.Notifications.ToastNotification]::new($ToastXml)
                [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($Using:AppId).Show($Toast)
                if ($PSEdition -eq "Desktop") {
                    Write-Output "This just fix bug in Windows Powershell 5" | Out-Null
                }
            } -ArgumentList "$(Resolve-Path "$PSScriptRoot\..\..\lib\Microsoft.Windows.SDK.NET.dll")"
            Register-ObjectEvent -InputObject $job -EventName StateChanged -SourceIdentifier "$jprefix-$(New-RandString)" -Action {
                if ($EventSubscriber.SourceObject.State -eq 'Completed') {
                    Unregister-Event -SourceIdentifier $EventSubscriber.SourceIdentifier
                    Remove-Event -SourceIdentifier $EventSubscriber.SourceIdentifier
                    Remove-Job -Name $EventSubscriber.SourceIdentifier
                    Remove-Job -Id $EventSubscriber.SourceObject.Id | Out-Null
                }
            } | Out-Null
        }
    }

    end {
        # When this command is invoked in interactive terminal, recommend to use '-NoWait'.
        if (-not $NoWait) {
            Get-Job -Name "$jpreifx*" | Wait-Job -Timeout 3 | Out-Null
        }
    }
}

Set-Alias -Name sdnf -Value Send-Notification