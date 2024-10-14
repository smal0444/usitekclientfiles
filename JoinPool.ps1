#Login to Azure and Retrieve Host Pool Token
az login --identity
az account set --subscription "NTS QA environment"
$expDate = $((Get-Date).ToUniversalTime().AddHours(648).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
$registrationToken = az desktopvirtualization hostpool update --resource-group QA_Environment --name QA_Pool --registration-info "{'expirationTime':'$expDate'}" --query registrationInfo.token

cd C:\Provisioning-USitek

$RDAgentInstaller = Get-ChildItem -Path "C:\Provisioning-USitek\Microsoft.RDInfra.RDAgent.Installer-x64*.msi"
$RDAgentInstaller = $RDAgentInstaller.Name
$BootLoader = Get-ChildItem -Path "C:\Provisioning-USitek\Microsoft.RDInfra.RDAgentBootLoader.Installer-x64*.msi"
$BootLoader = $BootLoader.Name

msiexec /i $RDAgentInstaller /quiet REGISTRATIONTOKEN=$registrationToken

Start-Sleep 10

msiexec /i $BootLoader /quiet

Start-Sleep 60

#Enable FSLogix Profiles
$regPath = "HKLM:\SOFTWARE\FSLogix\profiles"

# Check if the registry key exists; if not, create it
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}

# Now set the properties (values) inside the registry key
New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value "\\ntsqausersfs.file.core.windows.net\profiles" -Force

Start-Sleep 2

#Set Provisioning Status to True
Set-Content -Path "C:\Provisioning-USitek\status.txt" -Value "true"