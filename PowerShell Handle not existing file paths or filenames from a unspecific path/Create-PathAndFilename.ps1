$PathAndFilename = Get-PathAndFilename $Path

if(-not $PathAndFilename.Filename){$PathAndFilename.Filename =$AlternativeFilename}
if(-not $PathAndFilename.Path){$PathAndFilename.Path = (Get-Location).Path}
if(-not (Test-Path $PathAndFilename.Path)){New-Item -Path $PathAndFilename.Path -ItemType Directory}
$Path = Join-Path $PathAndFilename.Path ($PathAndFilename.Filename)