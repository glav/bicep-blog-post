param(
    [Parameter(Mandatory=$True)]
    [String]
    $Location,

    [Parameter(Mandatory=$True)]
    [String]
    $Environment,

    [Parameter(Mandatory=$True)]
    [String]
    $ResourceGroupName,

    [Parameter(Mandatory=$True)]
    [String]
    $VMAdminUsername,

    [Parameter(Mandatory=$True)]
    [String]
    $VMAdminPassword,

    [Parameter(Mandatory=$True)]
    [String]
    $SqlAdminUsername,

    [Parameter(Mandatory=$True)]
    [String]
    $SqlAdminPassword

)

az group create --location $Location --name $ResourceGroupName
az deployment group create --resource-group $ResourceGroupName  --name 'GlavBicepDemoDeployment' --template-file './main.bicep' --parameters `
    environment="$Environment" `
    vmAdminUsername="$VMAdminUsername" `
    vmAdminPassword="$VMAdminPassword" `
    sqlAdminUsername="$SqlAdminUsername" `
    sqlAdminPassword="$SqlAdminPassword"

