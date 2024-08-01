# Parameters
$workspaceId = $env:WORKSPACE_ID
$filePath = $env:FILE_PATH

# Function to remove AzureRM modules if they exist
function Remove-AzureRMModules {
    $azureRMModules = Get-Module -ListAvailable -Name AzureRM*
    if ($azureRMModules) {
        foreach ($module in $azureRMModules) {
            try {
                Write-Output "Uninstalling module: $($module.Name)"
                Uninstall-Module -Name $module.Name -AllVersions -Force -ErrorAction Stop
            } catch {
                Write-Output "Error uninstalling module: $($module.Name). $_"
            }
        }
        # Ensure that AzureRM is not loaded
        Get-Module -Name AzureRM | Remove-Module -Force -ErrorAction SilentlyContinue
    } else {
        Write-Output "No AzureRM modules found."
    }
}

# Remove AzureRM modules
Remove-AzureRMModules

# Install Az module
try {
    Write-Output "Installing Az module..."
    Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
} catch {
    Write-Output "Error installing Az module. $_"
}

# Set up module directory
New-Item -ItemType Directory -Path ".\modules" -ErrorAction SilentlyContinue | Out-Null

# Download and import FabricPS-PBIP module
try {
    Write-Output "Downloading FabricPS-PBIP module..."
    @("https://raw.githubusercontent.com/microsoft/Analysis-Services/master/pbidevmode/fabricps-pbip/FabricPS-PBIP.psm1"
    , "https://raw.githubusercontent.com/microsoft/Analysis-Services/master/pbidevmode/fabricps-pbip/FabricPS-PBIP.psd1") | ForEach-Object {
        Invoke-WebRequest -Uri $_ -OutFile ".\modules\$(Split-Path $_ -Leaf)" -ErrorAction Stop
    }
    Import-Module ".\modules\FabricPS-PBIP.psm1" -Force
} catch {
    Write-Output "Error downloading or importing FabricPS-PBIP module. $_"
}

# Authenticate to Power BI
try {
    Write-Output "Authenticating to Power BI..."
    Set-FabricAuthToken -reset
} catch {
    Write-Output "Error during Power BI authentication. $_"
}

# Import the Power BI file
try {
    Write-Output "Importing Power BI file..."
    Import-PowerBIFile -WorkspaceId $workspaceId -FilePath $filePath
} catch {
    Write-Output "Error importing Power BI file. $_"
}
