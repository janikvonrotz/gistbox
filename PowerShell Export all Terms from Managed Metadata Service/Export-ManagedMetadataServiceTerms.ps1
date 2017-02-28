<#
$Metadata = @{
	Title = "Export all Terms from Managed Metadata Service"
	Filename = "Export-ManagedMetadataServiceTerms.ps1"
	Description = ""
	Tags = "powershell, script, sharepoint, managed, metadata, terms, export"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-14"
	LastEditDate = "2014-01-14"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

if((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin 'Microsoft.SharePoint.PowerShell'}

function loop{

    param(
    
        $Object,        
        $AttributeName,        
        $Level = 0
    )
    
    # check the child attribute containing the same type of objects
    $Objects = iex "`$Object.$AttributeName"
    
    # output this item
    $Object | select @{L="Object";E={$_}}, @{L="Level";E={$Level}}
    
    # output the child items of this object
    if($Objects){
    
        # add level
        $Level ++
        
        # loop trough the same function
        $Objects | %{loop -Object $_ -AttributeName $AttributeName -Level $Level}
    }
}

# reset vars
$SPTaxonomies = @()

# get all taxonomy objects
$SPTaxonomies = Get-SPTaxonomySession -Site "http://itwiki.vbl.ch" | %{

    $_.TermStores | %{
    
        $TermStore = New-Object -TypeName Psobject -Property @{
        
            TermStore = $_.Name
            Group = ""
            TermSet = ""
            Terms = ""      
        }        
        
        
        $_.Groups | %{
            
            $Group = $TermStore.PSObject.Copy()
            $Group.Group = $_.Name
        
            $_.TermSets | %{
            
                $TermSet = $Group.PSObject.Copy()
                $TermSet.TermSet = $_.Name
                $TermSet.Terms = ($_.Terms | %{loop -Object $_ -AttributeName "Terms" -Level 1})
            
                $TermSet                  
            }        
        }        
    }
}

# get maximum of levels a term has
$Levels = ($SPTaxonomies | %{$_.Terms | %{$_.Level}} | measure -Maximum).Maximum + 1
         
# loop throught term stores       
$SPTaxonomies | %{

    $SPTaxonomy = $_
    
    # loop throught terms
    $_.Terms | %{
    
        # create a term export object
        $Item = $SPTaxonomy.PSObject.Copy()    
        $Index = 1;while($Index -ne $Levels){
            $Item | Add-Member –MemberType NoteProperty –Name "Term Level $Index" –Value $(if($_.Level -eq $Index){$_.Object.Name}else{""})            
            $Index += 1
        }     
        
        # output this object
        $Item |  Select-Object * -exclude Terms
    }                
} | Out-GridView