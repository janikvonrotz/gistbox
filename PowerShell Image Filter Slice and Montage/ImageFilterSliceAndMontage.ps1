
# tmpdir=tmp
$TempFolder = "Slices"
$Output = "out.png"
$Filter = "*.png"

# if [ -d "$tmpdir" ]; then
  # rm -rf $tmpdir
# fi
# mkdir $tmpdir
If(-not (Test-Path $TempFolder)){New-Item -Path $TempFolder -ItemType Directory}

# height=1080
$Height = 1080

# width=96
$Width = 96

# n=0
$N = 0

# for f in *.jpg
# do
$Files = "H:\Documents","H:\SkyDrive" | %{Get-ChildItem -Path $_ -Recurse -Filter $Filter}

$DayStart = Get-Date 01.01.2013
$DayFinish = Get-Date 31.12.2013

$TimeStart = Get-date 18:20:00
$TimeFinish = Get-Date 20:20:00

0..$(New-TimeSpan $Start $Finish).Days | %{
    
    $From = ($DayStart).AddDays($_).AddHours($TimeStart.Hour).AddMinutes($TimeStart.Minute)
    $To = ($DayStart).AddDays($_).AddHours($TimeFinish.Hour).AddMinutes($TimeFinish.Minute)  
       
    $Files | where{$_.LastWriteTime -gt $From -and $_.LastWriteTime -lt $To} | select -First 1
} | %{

  # offset=$(($n*$width))
  $Offset = ($N * $Width)
  
  # c="$(printf "%05d" $n)"  
  # echo "Creating slice $tmpdir/$c.png"
  Write-Host "Creating slice $(Join-Path $TempFolder $_.Name))"
  
  # "/cygdrive/c/Programme/ImageMagick-6.8.6-Q16/convert.exe" -crop ${width}x${height}+${offset}+0 $f $tmpdir/$c.png
  iex "Convert -crop $Width x $($Height + $Offset) $(Join-Path $TempFolder $_.Name)"
  
  # n=$(($n+1))
  $N += 1
  
# done
}

# count="$(ls -1 $tmpdir | wc -l)"
$Count = (get-childitem $TempFolder).count

# echo "Joining $count slices into out.png"
Write-Host "Joining $Count pictures into $Output"

# "/cygdrive/c/Programme/ImageMagick-6.8.6-Q16/montage.exe" $tmpdir/*.png -mode concatenate -tile ${count}x out.png
iex "montage $($Slices)/*.png -mode concatenate -tile $($Count)x $Output"

    