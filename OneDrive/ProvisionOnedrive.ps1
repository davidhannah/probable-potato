# Author: David Hannah | http://dhseng.sharepoint.com
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
<#
.SYNOPSIS
Create OneDrive for business sites for all licensed users.

.DESCRIPTION
Create OneDrive for business sites for all licensed users.

Requires:
Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Install-Module -Name MSOnline
.EXAMPLE
PS C:\> .\ProvisionOnedrive.ps1 -Url https://tenant-admin.sharepoint.com

.EXAMPLE
PS C:\> $creds = Get-Credential
PS C:\> .\ProvisionOnedrive.ps1 -Url https://tenant-admin.sharepoint.com -BatchSize 20

.EXAMPLE
PS C:\> $creds = Get-Credential
PS C:\> .\ProvisionOnedrive.ps1 -Url https://tenant-admin.sharepoint.com -Credentials $creds
#>
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false, HelpMessage="Optional administration credentials")]
    [PSCredential]
    $Credentials,
    [Parameter(Mandatory = $true, HelpMessage="Required tenant admin Url")]
    [string]
    $Url,
    [Parameter(Mandatory = $false, HelpMessage="Optional batch size")]
    [string]
    $BatchSize = 50
)

if($Credentials -eq $null)
{
	$Credentials = Get-Credential -Message "Enter your O365 Admin Credentials"
}

#connect to MSOL
try{
    Connect-MsolService -Credential $Credentials
}catch{
     $errorstring = "Critical error, unable to connect to O365, check the credentials"
     ac $logfile $errorstring
     ac $logfile $error[0]
     Write-Host $errorstring
     Pause
     Exit
}

try{
    Connect-SPOService -Url $Url -Credential $Credentials
}catch{
     $errorstring = "Critical error, unable to connect to O365, check the credentials"
     ac $logfile $errorstring
     ac $logfile $error[0]
     Write-Host $errorstring
     Pause
     Exit
}

#fetch all UPN's
#$users = Get-MsolUser -All | Select-Object UserPrincipalName
#Fetch only licensed users, but this can be changes as per your need. Like based on certain department...
$users = Get-MSOLUser -All | select userprincipalname,islicensed | where {$_.islicensed -eq "True"}
$noUsers = $users.Count

$noBatches = [math]::ceiling( $noUsers / $BatchSize )
$counter = [pscustomobject] @{ Value = 0 }
$batches = $users | Group-Object -Property { [math]::Floor($counter.Value++ / $BatchSize) }
foreach($batch in $batches)
{
    ##write-host $batch
    #write-host $batch.Group
    $emailAddresses = @()
    foreach($user in $batch.Group){
        $emailAddresses += $user.UserPrincipalName
        #write-host -ForegroundColor Cyan $user.UserPrincipalName
    }
    Request-SPOPersonalSite -UserEmails $emailAddresses
}
Disconnect-SPOService
