Get-SPSite | Get-SPWeb -Limit All | %{

    $SPWeb = $_
    [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($_) | %{
        
        $SPPublishingWeb = $_
        $SPWeb.GetLimitedWebPartManager("$($_.Uri)$($_.DefaultPage)", [System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared) | %{
        
            $SPWebPartManager = $_
            
            $_.WebParts | %{
            
                # do something
                
                $SPWebPartManager.SaveChanges($_)
            
            }                   
        }
    }
}