function Get-PackageBaseAddress {
    [CmdletBinding()]
    param()

    $nuget_api_v3 = Invoke-WebRequest -Uri "https://api.nuget.org/v3/index.json" -TimeoutSec 30

    if ($nuget_api_v3.StatusCode -ne 200) {
        Write-Error "Something is wrong with nuget api v3."
        return
    }

    $nuget_api_index_json = $nuget_api_v3.Content | ConvertFrom-Json | Select-Object -ExpandProperty "resources"
    return ($nuget_api_index_json | Where-Object { $_."@type" -eq 'PackageBaseAddress/3.0.0' } | Select-Object -ExpandProperty "@id" -First 1)
}

function Get-PackageVersions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LowID,
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if (New-Object System.Uri $_) {
                    $true
                }
                else {
                    $false
                }
            })]
        [string]
        $PackageBaseAddress
    )
    $rsp = Invoke-WebRequest -Uri "${PackageBaseAddress}${LowID}/index.json"

    if ($rsp.StatusCode -ne 200) {
        Write-Error "No versions available for $LowID."
        return
    }

    return ($rsp.Content | ConvertFrom-Json | Select-Object -ExpandProperty "versions" | Select-String -Pattern "prerelease", "preview" -NotMatch)
}

function Invoke-NupkgDownload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LowID,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LowVersion,
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if (New-Object System.Uri $_) {
                    $true
                }
                else {
                    $false
                }
            })]
        [string]
        $PackageBaseAddress
    )
    $rsp = Invoke-WebRequest -Uri "${PackageBaseAddress}${LowID}/${LowVersion}/${LowID}.${LowVersion}.nupkg" -TimeoutSec 30  -OutFile "${PSScriptRoot}/${LowID}.${LowVersion}.nupkg" -PassThru
    if ($rsp.StatusCode -ne 200) {
        Remove-Variable -Name "rsp"
        return
    }
    Remove-Variable -Name "rsp"
    return "${PSScriptRoot}/${LowID}.${LowVersion}.nupkg"
}

function Invoke-NupkgExtract {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [string]
        $NupkgPath,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FullName,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-Path -Path $_ -IsValid })]
        [string]
        $DestDir
    )

    begin {
        if (-not (Test-Path -Path $DestDir -PathType Container)) {
            New-Item -Path $DestDir -ItemType Directory -Force | Out-Null
        }

        $TmpExtractDir = "${PSScriptRoot}\$(Split-Path -Path $NupkgPath -LeafBase)"

        if (-not (Test-Path -Path $TmpExtractDir -PathType Container)) {
            New-Item -Path $TmpExtractDir -ItemType Directory -Force | Out-Null
        }
        Expand-Archive -Path $NupkgPath -DestinationPath $TmpExtractDir -Force
    }

    process {
        foreach ($fname in $FullName) {
            Move-Item "${TmpExtractDir}\${FullName}" $DestDir -Force
        }
    }

    end {
        Remove-Item -Path $TmpExtractDir -Recurse -Force
    }
}

function Get-LocalDllVersion {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DllPath
    )
    if (-not (Test-Path -Path $DllPath -PathType Leaf)) {
        return
    }
    return (Get-Item -Path $DllPath).VersionInfo.FileVersion
}