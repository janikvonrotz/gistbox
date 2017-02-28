cls

$Terms = @"
Administration
Accounting
Business Plan
Certification
Communication
Technical Terms
Contracts
Licensing
Managment

Projects
Reporting
Roles
Verantwortlicher ActiveDirectory
Verantwortlicher Exchange
Verantwortlicher SharePoint
Verantwortlicher Zabbix
User Administration
Workflows
Applications
Adobe
Acrobat
Dreamweaver
Flashplayer
Illustrator
Photoshop
Reader
"@

$OutPut = @()
$TermsOutput = @()
$Terms = $Terms.split("`n") | where{$_ -ne "`r"} | sort
$HeadingWraper = "<h1 id=`"%`"><a href=`"#index`">%</a></h1>"


$OutPut += "<p id=`"index`"><a href=`"#1`"> # </a>|"

$OutPut += (

    [char[]]([int][char]'A'..[int][char]'Z') | ForEach-Object{
    
        if($_ -ne  'Z'){
            "<a href=`"#$_`"> $_ </a>|"
        }else{
            "<a href=`"#$_`"> $_ </a>"
        }    
    }

) 

$OutPut += "</p>"

$OutPut += "<h1 id=`"1`"><a href=`"#index`">#</a></h1>"

$TermsOutput += (1..9) | ForEach-Object{
    
    $Char = $_  
    $Terms | Where-Object{$_.Startswith($Char) -and $_ -ne $null}
}

if(-not $TermsOutput){

    $OutPut += "<p>-</p>"
    
}else{

    $OutPut += "<p>" + ($TermsOutput | ForEach-Object{
        
        if(-not ($_ -eq $TermsOutput[0])){      
        
             "<br/>`n[[$_]]"
        
        }else{
        
            "`n[[$_]]"
        
        }
    }) + "</p>"
}


[char[]]([int][char]'A'..[int][char]'Z')| ForEach-Object{
    
    $OutPut += $HeadingWraper -replace "%", $_
    
    $Char = $_  
    
    $TermsOutput = $Terms | Where-Object{$_.Startswith($Char)}
    
    if(-not $TermsOutput){

        $OutPut += "<p>-</p>"
        
    }else{

        $OutPut += "<p>" + ($TermsOutput | ForEach-Object{
            
            if(-not ($_ -eq $TermsOutput[0])){      
            
                 "<br/>`n[[$_]]"
            
            }else{
            
                "`n[[$_]]"
            
            }
        }) + "</p>"
    }
}
$OutPut