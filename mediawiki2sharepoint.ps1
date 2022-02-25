#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Get Credentials to connect
<#
.SYNOPSIS
    Runs a media wiki convertion script
.DESCRIPTION
    Default params assumes mediawiki.xml will output sharepoint.txt
.EXAMPLE
    PS C:\> Get-MediawikiExport
    Run the script via powershell using the default params
.INPUTS
    ScriptName=name_of_custom_php_script.php
    MediaWikiXMLFileName=name_of_mediawiki_xml_file.xml
    MediaWikiXMLExportFileName=name_of_exported_txt_file.txt
.OUTPUTS
    A text file of converted mediawiki xml to sharepoint parsable text
.NOTES
    Will require php install and added to default path.
#>
function Invoke-MediawikiExport {
    [CmdletBinding()]
    param (
        # Name of the convert PHP script.
        [Parameter(Position = 0, Mandatory = $false)]
        [string]
        $ScriptName = "mediawiki_to_sharepoint_convert.php",
        # Name of mediawiki XML output
        [Parameter(Position = 1, Mandatory = $false)]
        [string]
        $MediaWikiXMLFileName = "mediawiki.xml",
        # Parameter help description
        [Parameter(Position = 3, Mandatory = $false)]
        [string]
        $MediaWikiXMLExportFileName = "sharepoint.txt"
    )
    
    begin {
        Write-Verbose "Converting mediawiki.xml to sharepoint.txt..."
    }
    
    process {
        php .\$ScriptName $MediaWikiXMLFileName > $MediaWikiXMLExportFileName
    }
    
    end {
        Write-Verbose "mediawiki.xml conversion complete!"
        Invoke-Export
    }
}

<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

function Invoke-Export {
    [CmdletBinding()]
    param (
        # Sharepoint text file name
        [Parameter(Position = 0, Mandatory = $false)]
        [string]
        $SharepointTextFileName = "sharepoint.txt"
    )
    
    begin {     
    }
    
    process {
        $SiteURL = "https://kober.sharepoint.com/sites/NetflashInternetSolutions"
        $Cred = Get-Credential
        $Path = '.\' + $SharepointTextFileName
        $SharepointTxt = Get-Content -Path $Path -Raw
        $zero, $SharepointPageArray = $SharepointTxt.Split("ж")
        foreach ($Page in $SharepointPageArray) {
            $TitleArray = $Page.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)
            $Title = $TitleArray[0]
            $PageRelativeURL = "/sites/NetflashInternetSolutions/SitePages/$Title.aspx"
            $PageContent = $Page
            #Setup the context
            $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
            $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
            # #Create a Wiki page
            $WikiPageInfo = New-Object Microsoft.SharePoint.Client.Utilities.WikiPageCreationInformation
            $WikiPageInfo.WikiHtmlContent = $PageContent
            $WikiPageInfo.ServerRelativeUrl = $PageRelativeURL
            $WikiFile = [Microsoft.SharePoint.Client.Utilities.Utility]::CreateWikiPageInContextWeb($Ctx, $WikiPageInfo)
            $Ctx.ExecuteQuery()
            write-host  $PageRelativeURL
        }
    }
    
    end {
        
    }
}