function New-RandString {
    param (
        [Parameter()]
        [Int32]
        $Length
    )
    end {
        if (-not $Length) {
            $Length = 8
        }
        [string]::Join($null, ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $Length).forEach( { [char]$_ }))
    }
}