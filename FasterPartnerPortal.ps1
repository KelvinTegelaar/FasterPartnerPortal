#Related blog: https://www.cyberdrain.com/documenting-with-powershell-using-powershell-to-create-faster-partner-portal/
########################## Secure App Model Settings ############################
$ApplicationId = 'YourApplicationID'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YourTenantID'
$RefreshToken = 'YourRefreshToken'
$UPN = "YourUPN"
########################## Secure App Model Settings ############################
   
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID
  
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
$CustomerLinks = foreach ($customer in $customers) {
    $domains = (Get-MsolDomain -TenantId $customer.tenantid).Name -join ',' | Out-String
    [pscustomobject]@{
        'Client Name'            = $customer.Name
        'Client tenant domain'   = $customer.DefaultDomainName
        'O365 Admin Portal'      = "<a target=`"_blank`" href=`"https://portal.office.com/Partner/BeginClientSession.aspx?CTID=$($customer.TenantId)&CSDEST=o365admincenter`">O365 Portal</a>"
        'Exchange Admin Portal'  = "<a target=`"_blank`" href=`"https://outlook.office365.com/ecp/?rfr=Admin_o365&exsvurl=1&amp;delegatedOrg=$($Customer.DefaultDomainName)`">Exchange Portal</a>"
        'Azure Active Directory' = "<a target=`"_blank`" href=`"https://aad.portal.azure.com/$($Customer.DefaultDomainName)`" >AAD Portal</a>"
        'MFA Portal (Read Only)' = "<a target=`"_blank`" href=`"https://account.activedirectory.windowsazure.com/usermanagement/multifactorverification.aspx?tenantId=$($Customer.DefaultDomainName)&culture=en-us&requestInitiatedContext=users`" >MFA Portal</a>"
        'Sfb Portal'             = "<a target=`"_blank`" href=`"https://portal.office.com/Partner/BeginClientSession.aspx?CTID=$($Customer.TenantId)&CSDEST=MicrosoftCommunicationsOnline`">SfB Portal</a>"
        'Teams Portal'           = "<a target=`"_blank`" href=`"https://admin.teams.microsoft.com/?delegatedOrg=$($Customer.DefaultDomainName)`">Teams Portal</a>"
        'Azure Portal'           = "<a target=`"_blank`" href=`"https://portal.azure.com/$($customer.DefaultDomainName)`">Azure Portal</a>"
        'Intune portal'          = "<a target=`"_blank`" href=`"https://portal.azure.com/$($customer.DefaultDomainName)/#blade/Microsoft_Intune_DeviceSettings/ExtensionLandingBlade/overview`">Intune Portal</a>"
        'Domains'                = "Domains: $domains"
    }
}
  
$head = @"
<script>
function myFunction() {
    const filter = document.querySelector('#myInput').value.toUpperCase();
    const trs = document.querySelectorAll('table tr:not(.header)');
    trs.forEach(tr => tr.style.display = [...tr.children].find(td => td.innerHTML.toUpperCase().includes(filter)) ? '' : 'none');
  }</script>
<Title>LNPP - Lime Networks Partner Portal</Title>
<style>
body { background-color:#E5E4E2;
      font-family:Monospace;
      font-size:10pt; }
td, th { border:0px solid black; 
        border-collapse:collapse;
        white-space:pre; }
th { color:white;
    background-color:black; }
table, tr, td, th {
     padding: 2px; 
     margin: 0px;
     white-space:pre; }
tr:nth-child(odd) {background-color: lightgray}
table { width:95%;margin-left:5px; margin-bottom:20px; }
h2 {
font-family:Tahoma;
color:#6D7B8D;
}
.footer 
{ color:green; 
 margin-left:10px; 
 font-family:Tahoma;
 font-size:8pt;
 font-style:italic;
}
#myInput {
  background-image: url('https://www.w3schools.com/css/searchicon.png'); /* Add a search icon to input */
  background-position: 10px 12px; /* Position the search icon */
  background-repeat: no-repeat; /* Do not repeat the icon image */
  width: 50%; /* Full-width */
  font-size: 16px; /* Increase font-size */
  padding: 12px 20px 12px 40px; /* Add some padding */
  border: 1px solid #ddd; /* Add a grey border */
  margin-bottom: 12px; /* Add some space below the input */
}
</style>
"@
  
$PreContent = @"
<H1> CyberDrain.com faster partner portal</H1> <br>
  
For more information, check <a href="https://www.cyberdrain.com/documenting-with-powershell-using-powershell-to-create-faster-partner-portal/"/>CyberDrain.com</a>
<br/>
<br/>
   
<input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search...">
"@
  
  
$CustomerHTML = $CustomerLinks | ConvertTo-Html -head $head -PreContent $PreContent | Out-String
  
[System.Web.HttpUtility]::HtmlDecode($CustomerHTML) -replace "<th>Domains", "<th style=display:none;`">" -replace "<td>Domains", "<td style=display:none;`">Domains"  | out-file "C:\temp\index.html"