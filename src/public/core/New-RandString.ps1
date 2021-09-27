function random_ascii_nums {
    param (
        [Parameter()]
        [Int32]
        $Times
    )

    $raws = (0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A)
    for ($i = 0; $i -lt $Times; $i++) {
        Get-Random -Count 62 -InputObject $raws | Write-Output
    }
}

function New-RandString {
    param (
        [Parameter()]
        [ValidateScript({ $_ -gt 0 })]
        [Int32]
        $Length
    )
    end {
        if (-not $Length) {
            $Length = 8
        }
        $mul = 1;
        if ($Length -gt 62) {
            $mul = [int]($Length / 62) + 1
        }
        -join (random_ascii_nums -Times $mul | Get-Random -Count $Length | ForEach-Object { [char]$_ })
    }
}

Set-Alias -Name nrs -Value New-RandString