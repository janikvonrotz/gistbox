$SPUrl = (Get-SPUrl $Identity).Url

$SPWeb = Get-SPWeb $SPUrl

if($IncludeChildItems -and -not $Recursive){

    $SPWebs += $SPWeb
    $SPWebs += $SPWeb.webs            

}elseif($Recursive -and -not $IncludeChildItems){

    $SPWebs = $SPWeb.Site.AllWebs | where{$_.Url.Startswith($SPWeb.Url)}
    
}else{

    $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString
    $SPWebs += $SPWeb
} 