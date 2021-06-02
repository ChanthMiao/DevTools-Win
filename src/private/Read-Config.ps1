function Read-Config {
    $DevToolsConf = [ordered]@{
        Proxy     = $null;
        VsWhere   = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe";
        VcpkgRoot = $null;
        Clang     = $null
    }
    $config_path = [System.IO.Path]::Combine($Env:LOCALAPPDATA, "DevTools-Win", "config.json")
    if ([System.IO.File]::Exists($config_path)) {
        $json = (Get-Content -Path $config_path -Raw -Encoding utf8 | ConvertFrom-Json)
        if ($json.Proxy) {
            $DevToolsConf.Proxy = $json.Proxy
        }
        if ($json.VsWhere) {
            $DevToolsConf.VsWhere = $json.VsWhere
        }
        if ($json.VcpkgRoot) {
            $DevToolsConf.VcpkgRoot = $json.VcpkgRoot
        }
        if ($json.Clang) {
            $DevToolsConf.Clang = $json.Clang
        }
    }
    Set-Variable -Name DevToolsConf -Value $DevToolsConf -Scope Script -Force
}

