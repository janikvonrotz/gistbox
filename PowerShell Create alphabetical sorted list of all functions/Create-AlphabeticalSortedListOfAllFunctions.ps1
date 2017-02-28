cls

$B = "https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/"
$A = "H:/SkyDrive/Shared/Projects/GitHub/Powershell-PowerUp/functions/"

$Terms = Get-ChildItem $PSfunctions.Path -Recurse -Filter *.ps1 | 
select Name, BaseName, @{L="Verb";E={$_.Name.Split("-")[0]}},@{L="Noun";E={$_.BaseName.Split("-")[1]}}, FullName, @{L="Url";E={$_.FullName -replace "\\","/" -replace $A,$B}} | 
Sort-Object Noun, Verb


$OutPut = @()
$HeadingWraper = "<h1 id=`"%`"><a href=`"#index`">%</a></h1>"

$OutPut += "<h1 id=`"index`">Index</h1>"

$OutPut += (

    [char[]]([int][char]'A'..[int][char]'Z') | ForEach-Object{
    
        if($_ -ne  'Z'){
            "<a href=`"#$("$_".tolower())`"> $_ </a>|"
        }else{
            "<a href=`"#$("$_".tolower())`"> $_ </a>"
        }    
    }

) 

$OutPut += "</p>"

[char[]]([int][char]'A'..[int][char]'Z')| ForEach-Object{
    
    $OutPut += $HeadingWraper -replace "%", $_
    
    $Char = $_
    
    $TermsOutput = $Terms | Where-Object{$_.Noun.Startswith($Char)}
    
    if(-not $TermsOutput){

        $OutPut += "<p>-</p>"
        
    }else{

        $OutPut += "<p>" + ($TermsOutput | ForEach-Object{
            
            if(-not ($_ -eq $TermsOutput[0])){      
            
                 "<br/>`n<a href='$($_.Url)'>$($_.BaseName)</a>"
            
            }else{
            
                "`n<a href='$($_.Url)'>$($_.BaseName)</a>"
            
            }
        }) + "</p>"
    }
}

$OutPut