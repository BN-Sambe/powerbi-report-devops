# Parameters 
$workspaceName = $env:WORKSPACE_NAME
$pbipSemanticModelPath = $env:PBIP_SEMANTIC_MODEL_PATH
$pbipReportPath = $env:PBIP_REPORT_PATH
$currentPath = (Split-Path $MyInvocation.MyCommand.Definition -Parent)
Set-Location $currentPath

# Download modules and install
New-Item -ItemType Directory -Path ".\modules" -ErrorAction SilentlyContinue | Out-Null
@("https://raw.githubusercontent.com/microsoft/Analysis-Services/master/pbidevmode/fabricps-pbip/FabricPS-PBIP.psm1"
, "https://raw.githubusercontent.com/microsoft/Analysis-Services/master/pbidevmode/fabricps-pbip/FabricPS-PBIP.psd1") | ForEach-Object {
    Invoke-WebRequest -Uri $_ -OutFile ".\modules\$(Split-Path $_ -Leaf)"
}
if(-not (Get-Module Az.Accounts -ListAvailable)) { 
    Install-Module Az.Accounts -Scope CurrentUser -Force
}
Import-Module ".\modules\FabricPS-PBIP.psm1" -Force

# Authenticate
Set-FabricAuthToken -reset

# Ensure workspace exists
$workspaceId = New-FabricWorkspace -Name $workspaceName -SkipErrorIfExists

# Import the semantic model and save the item id
$semanticModelImport = Import-FabricItem -WorkspaceId $workspaceId -Path $pbipSemanticModelPath

# Import the report and ensure it's bound to the previous imported semantic model
$reportImport = Import-FabricItem -WorkspaceId $workspaceId -Path $pbipReportPath -ItemProperties @{"SemanticModelId" = $semanticModelImport.Id}
