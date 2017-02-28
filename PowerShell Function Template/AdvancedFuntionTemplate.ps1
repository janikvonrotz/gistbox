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

function Test-AdvancedFunction{

<#
.SYNOPSIS
    A brief description of the function.

.DESCRIPTION
	A detailed description of the function.

.PARAMETER ParameterA
	The description of the ParameterA parameter.

.PARAMETER ParameterB
	The description of the ParameterB parameter.

.EXAMPLE
	PS C:\> Get-Something -ParameterA 'One value' -ParameterB 32

.EXAMPLE
	PS C:\> Get-Something 'One value' 32

.INPUTS
	System.String,System.Int32

.OUTPUTS
	System.String

.NOTES
	Additional information about the function go here.

.LINK
	about_functions_advanced

.LINK
	about_comment_based_help

#>

    [CmdletBinding()]
    param(

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
	
    # This block is used to provide optional one-time pre-processing for the function.
    begin{ 
        
        Do-Something
    }

    # This block is used to provide record-by-record processing for the function.
    process{

    	try{
        
    		
    	}catch{
        
  		  throw
  		  
		  }finally{
        
      }
    }
    
    # This block is used to provide optional one-time post-processing for the function.
    end{
    
        
    }
}