$color_table = @{}

foreach($line in Get-Content -Path 'vim_colors.tsv') {
    $pair = $line -split "`t"
    $color_table[$pair[0]] = $pair[1]
}

foreach($path in $args | % { Resolve-Path $_ } | ? { Test-Path $_ }) {
    $lines = foreach($line in Get-Content -Path $path) {
        if($line -match 'guifg=([a-zA-Z0-9]{3,})') {
            $name = $matches[1]

            $line = $line -replace ($name + '\b'),$color_table[$name]
        }
        if($line -match 'guibg=([a-zA-Z0-9]{3,})') {
            $name = $matches[1]

            $line = $line -replace ($name + '\b'),$color_table[$name]
        }
        if($line -match 'guisp=([a-zA-Z0-9]{3,})') {
            $name = $matches[1]

            $line = $line -replace ($name + '\b'),$color_table[$name]
        }

        $line
    }

    $lines | Out-File -Encoding utf8 -FilePath $path
}
