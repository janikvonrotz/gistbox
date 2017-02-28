[CmdletBinding()]param(

    # parameter options
    # validation
    # cast
    # name and default value

    [Parameter(Position=0, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $Name,

    [Parameter(Position=1)]
    [ValidateNotNull()]
    [System.Int32]
    $Index

)
    
<#
$Metadata = @{
	Title = ""
	Filename = ""
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "yyyyy-mm-dd hh:mm"
	LastEditDate = "yyyyy-mm-dd hh:mm"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

try{
  
    <#
    #--------------------------------------------------#
	  # about
	  #--------------------------------------------------#
    
    The restore and backup process is described here: http://technet.microsoft.com/en-us/library/dd581644(WS.10).aspx
    
    #>
    
    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#

    #--------------------------------------------------#
    # functions
    #--------------------------------------------------#

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    Do-Something

}catch{

    throw "Something"

}
