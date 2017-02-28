
$import = ""
$export = @()

Get-ChildItem | Where-Object{!@("store", "index").contains($_.BaseName)} | ForEach-Object{
    $import += "import $($_.baseName) from '$($_.baseName)';`n"
    $export += $_.BaseName
}

@"
$($import)

export { $($export -join(', ')) }
"@ | Out-File -Encoding utf8 'index.js'