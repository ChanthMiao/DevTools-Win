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
        if (-not (Get-Command 'rq' -ErrorAction SilentlyContinue)) {
            Write-Warning "'rq' not found. Please go https://github.com/dflemstr/rq/releases/latest to download and install it."
            return
        }
        if (Test-Path "$Env:USERPROFILE/.cargo/config.toml") {
            # If both files exist, Cargo will use the file without the extension.
            New-Item -Path "$Env:USERPROFILE/.cargo/config" -ItemType SymbolicLink -Target "$Env:USERPROFILE/.cargo/config.toml"
        }
        if (-not (Test-Path "$Env:USERPROFILE/.cargo/config")) {
            New-Item -Path "$Env:USERPROFILE/.cargo/config" -ItemType File
        }
        $cargo_config = (Get-Content "$Env:USERPROFILE/.cargo/config" | rq --input-toml --output-json | ConvertFrom-Json)
        $rust_mirrors = (Get-Content "$PSScriptRoot\..\..\assets\rust_mirror.toml" | rq --input-toml --output-json | ConvertFrom-Json)
        [System.Environment]::SetEnvironmentVariable('RUSTUP_DIST_SERVER', $rust_mirrors.rustup.$Name.'dist-server')
        [System.Environment]::SetEnvironmentVariable('RUSTUP_UPDATE_ROOT', $rust_mirrors.rustup.$Name.'update-root')
        if ($Persistent) {
            [System.Environment]::SetEnvironmentVariable('RUSTUP_DIST_SERVER', $rust_mirrors.rustup.$Name.'dist-server', 'User')
            [System.Environment]::SetEnvironmentVariable('RUSTUP_UPDATE_ROOT', $rust_mirrors.rustup.$Name.'update-root', 'User')
        }
        $rust_mirrors.source."crates-io"."replace-with" = $Name
        $cargo_config.source."crates-io" = $rust_mirrors.source."crates-io"
        $cargo_config.source.$Name = $rust_mirrors.source.$Name
        $cargo_config | ConvertTo-Json | rq --input-json --output-toml | Out-File "$Env:USERPROFILE/.cargo/config" -Encoding utf8 -Force
    }
}

Set-Alias -Name srsm -Value Set-RustMirror