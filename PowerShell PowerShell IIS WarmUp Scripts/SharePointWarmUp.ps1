function get-webpage([string]$url,[System.Net.NetworkCredential]$cred=$null)
{
$wc = new-object net.webclient
if($cred -eq $null)
{
$cred = [System.Net.CredentialCache]::DefaultCredentials;
}
$wc.credentials = $cred;
return $wc.DownloadString($url);
}
 
#This passes in the default credentials needed. If you need specific stuff you can use something else to
#elevate basically the permissions. Or run this task as a user that has a Policy above all the Web Applications
#with the correct permissions
$cred = [System.Net.CredentialCache]::DefaultCredentials;
#$cred = new-object System.Net.NetworkCredential("username","password","machinename")
 
[xml]$x=stsadm -o enumzoneurls
foreach ($zone in $x.ZoneUrls.Collection) {
    [xml]$sites=stsadm -o enumsites -url $zone.Default;
    foreach ($site in $sites.Sites.Site) {
        write-host $site.Url;
        $html=get-webpage -url $site.Url -cred $cred;
    }
}