$SPWebs = Get-SPWebs
$SPWebs | %{

    $SPWeb = $_   
    
    $SPSite = $_.site.url
        
    Get-SPLists -Url $_.Url -OnlyDocumentLibraries | %{
    
        $SPList = $_
        
        $SPListUrl = (Get-SPUrl $SPList).url
        
        Write-Progress -Activity "Crawl list on website" -status "$($SPWeb.Title): $($SPList.Title)" -percentComplete ([Int32](([Array]::IndexOf($SPWebs, $SPWeb)/($SPWebs.count))*100))
                        
        Get-SPListItems $_.ParentWeb.Url -FilterListName $_.title | %{
            
            $ItemUrl = (Get-SPUrl $_).Url
            
            # files
            New-Object PSObject -Property @{
                ParentWebsite = $SPWeb.ParentWeb.title
                ParentWebsiteUrl = $SPWeb.ParentWeb.Url
                Website = $SPWeb.title
                WebsiteUrl = $SPWeb.Url
                List = $SPList.title
                ListUrl = $SPListUrl
                FileExtension = [System.IO.Path]::GetExtension($_.Url)
                IsCheckedOut = $false
                IsASubversion = $false                
                Item = $_.Name                
                ItemUrl = $ItemUrl
                Folder = $ItemUrl -replace "[^/]+$",""      
                FileSize = $_.file.Length / 1000000    
            }
            
            $SPItem = $_
            
            # file subversions            
            $_.file.versions | %{
            
                $ItemUrl = (Get-SPUrl $SPItem).Url  
            
                New-Object PSObject -Property @{
                    ParentWebsite = $SPWeb.ParentWeb.title
                    ParentWebsiteUrl = $SPWeb.ParentWeb.Url
                    Website = $SPWeb.title
                    WebsiteUrl = $SPWeb.Url                    
                    List = $SPList.title
                    ListUrl = $SPListUrl
                    FileExtension = [System.IO.Path]::GetExtension($_.Url)
                    IsCheckedOut = $false
                    IsASubversion = $true                                 
                    Item = $SPItem.Name                    
                    ItemUrl = $ItemUrl 
                    Folder = $ItemUrl -replace "[^/]+$",""                               
                    FileSize = $_.Size / 1000000
                }
            }            
        }
        
        # checked out files
        Get-SPListItems $_.ParentWeb.Url -FilterListName $_.title -OnlyCheckedOutFiles | %{
        
            $ItemUrl = $SPSite + "/" + $_.Url 
        
            New-Object PSObject -Property @{
                ParentWebsite = $SPWeb.ParentWeb.title
                ParentWebsiteUrl = $SPWeb.ParentWeb.Url
                Website = $SPWeb.title
                WebsiteUrl = $SPWeb.Url
                List = $SPList.title
                ListUrl = $SPListUrl
                FileExtension = [System.IO.Path]::GetExtension($_.Url)
                IsCheckedOut = $true
                IsASubversion = $false                              
                Item = $_.LeafName                
                ItemUrl = $ItemUrl  
                Folder = $ItemUrl -replace "[^/]+$",""          
                FileSize = $_.Length / 1000000
            } 
        
        }   
    }
} | Export-Csv "Report SharePoint Files.csv" -Delimiter ";" -Encoding "UTF8" -NoTypeInformation