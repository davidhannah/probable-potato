
$oneDriveURL = "https://TenantID-my.sharepoint.com/personal/ONEDRIVEPATH/"
$oneDriveUserName = "USERNAME"
$oneDrivePassword  = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force

$FolderIn = "C:\BackupFiles"
$DocLibName = "Documents"

#Add references to SharePoint client assemblies and authenticate to Office 365 site – required for CSOM
# https://www.microsoft.com/en-us/download/details.aspx?id=42038
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($oneDriveURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($oneDriveUserName,$oneDrivePassword)
$Context.Credentials = $Creds

#Load web context
$web = $Context.Web
$Context.Load($web)
$Context.ExecuteQuery()

$lists = $Context.Web.Lists
$Context.Load($Context.Web.Lists)
$Context.ExecuteQuery()

$douments = $lists.GetByTitle("$DocLibName")
$Context.Load($douments)
$Context.ExecuteQuery()

$Context.Load($douments.RootFolder.Folders)
$Context.ExecuteQuery()

#Get the List Root Folder
$ParentFolder=$Context.Web.GetFolderByServerRelativeUrl("$DocLibName")
 
$RestoreFolderName = "Restore_13112018"
#Create New Folder
$newFoler = $ParentFolder.Folders.Add($RestoreFolderName)
$ParentFolder.Context.ExecuteQuery()

#Get OneDrive Document List
$oneDriveList = $web.Lists.GetByTitle($DocLibName)
$context.Load($oneDriveList.RootFolder)
$context.ExecuteQuery()

#Uploading File to oneDrive Site
Foreach ($localfile in (dir $FolderIn -File))
{
    #$localfile = Get-ChildItem $deltaFile
    $folderRelativeUrl = $oneDriveList.RootFolder.ServerRelativeUrl
    $fileURL = $folderRelativeUrl + "/$RestoreFolderName/" + $localfile.Name
    [Microsoft.SharePoint.Client.File]::SaveBinaryDirect($web.Context, $fileURL, $localfile.OpenRead(), $true)  #This is the actual upload!
}