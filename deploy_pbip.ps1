# Parameters
$workspaceId = $env:WORKSPACE_ID
$filePath = $env:FILE_PATH

# Remove AzureRM modules if present
$azureRMModules = Get-Module -ListAvailable -Name AzureRM*
foreach ($module in $azureRMModules) {
    Uninstall-Module -Name $module.Name -AllVersions -Force
}

# Ensure that AzureRM is not loaded in the current session
Get-Module -Name AzureRM 

# Install Az module
Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber

# Set up module directory
New-Item -ItemType Directory -Path ".\modules" -ErrorAction SilentlyContinue | Out-Null

# Download and import FabricPS-PBIP module
@("https://raw.githubusercontent.com/microsoft/Analysis-Services/master/pbidevmode/fabricps-pbip/FabricPS-PBIP.psm1"
, "https://raw.githubusercontent.com/microsoft/Analysis-Services/master/pbidevmode/fabricps-pbip/FabricPS-PBIP.psd1") | ForEach-Object {
    Invoke-WebRequest -Uri $_ -OutFile ".\modules\$(Split-Path $_ -Leaf)"
}

Import-Module ".\modules\FabricPS-PBIP.psm1" -Force

# Authenticate to Power BI
Set-FabricAuthToken -reset

# Import the Power BI file
Import-PowerBIFile -WorkspaceId $workspaceId -FilePath $filePath
