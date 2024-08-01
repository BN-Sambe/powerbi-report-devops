# Authenticate to Power BI service
$tenantId = $env:TENANT_ID
$clientId = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET
$workspaceId = $env:WORKSPACE_ID
$filePath = $env:FILE_PATH

$secureClientSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $secureClientSecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId

# Import the .pbip file to the specified workspace
Import-PowerBIFile -WorkspaceId $workspaceId -FilePath $filePath

# Disconnect from Power BI service
Disconnect-AzAccount
