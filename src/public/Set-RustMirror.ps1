function Set-RustMirror {
    param (
        [Parameter()]
        [ValidateSet('rsproxy', 'sjtug', 'tuna', 'ustc')]
        [string]
        $Name,
        [Parameter()]
        [switch]
        $Persistent
    )
    end {
        if (-not $Name) {
            $Name = Get-Config -Name 'RustMirror'
        }

        if (Test-Path "$Env:USERPROFILE/.cargo/config.toml") {
            # If both files exist, Cargo will use the file without the extension.
            New-Item -Path "$Env:USERPROFILE/.cargo/config" -ItemType SymbolicLink -Target "$Env:USERPROFILE/.cargo/config.toml"
        }
        if (-not (Test-Path "$Env:USERPROFILE/.cargo/config")) {
            New-Item -Path "$Env:USERPROFILE/.cargo/config" -ItemType File
        }
        $cargo_config = Get-IniContent "$Env:USERPROFILE/.cargo/config"
        $rust_mirrors = Get-IniContent "$PSScriptRoot\..\..\assets\rust_mirror.toml"
        [System.Environment]::SetEnvironmentVariable('RUSTUP_DIST_SERVER', $rust_mirrors["rustup.$Name"]['dist-server'])
        [System.Environment]::SetEnvironmentVariable('RUSTUP_UPDATE_ROOT', $rust_mirrors["rustup.$Name"]['update-root'])
        if ($Persistent) {
            [System.Environment]::SetEnvironmentVariable('RUSTUP_DIST_SERVER', $rust_mirrors["rustup.$Name"]['dist-server'], 'User')
            [System.Environment]::SetEnvironmentVariable('RUSTUP_UPDATE_ROOT', $rust_mirrors["rustup.$Name"]['update-root'], 'User')
        }
        $rust_mirrors["source.crates-io"]["replace-with"] = $Name
        $cargo_config["source.crates-io"] = $rust_mirrors["source.crates-io"]
        $cargo_config["source.$Name"] = $rust_mirrors["source.$Name"]
        $cargo_config | Out-IniFile "$Env:USERPROFILE/.cargo/config" -Encoding UTF8 -Force -Loose -Pretty
    }
}

Set-Alias -Name srsm -Value Set-RustMirror