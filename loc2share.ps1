#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Config Variable
$SiteURL = "https://kober.sharepoint.com/sites/NetflashInternetSolutions"
$PageRelativeURL="/sites/NetflashInternetSolutions/SitePages/Knowledgebase.aspx"
$PageContent="This has been edited!<br/>[[Home]]<hr/><br/><h1>Test</h1>"
 
#Get Credentials to connect
$Cred= Get-Credential
  
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
 
#Create a Wiki page
$WikiPageInfo = New-Object Microsoft.SharePoint.Client.Utilities.WikiPageCreationInformation
$WikiPageInfo.WikiHtmlContent = $PageContent
$WikiPageInfo.ServerRelativeUrl = $PageRelativeURL
$WikiFile = [Microsoft.SharePoint.Client.Utilities.Utility]::CreateWikiPageInContextWeb($Ctx, $WikiPageInfo)
$Ctx.ExecuteQuery()