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
    $sshAdminKey,

    [Parameter(Mandatory=$True)]
    [String]
    $SqlAdminUsername,

    [Parameter(Mandatory=$True)]
    [String]
    $SqlAdminPassword

)
$tomorrow=((Get-Date).AddDays(1)).ToString('yyyy-MM-dd')
az group create --location $Location --name $ResourceGroupName --tags expiresOn=$tomorrow
az deployment group create --resource-group $ResourceGroupName  --name 'GlavBicepDemoDeployment' --template-file './main.bicep' --parameters `
    environment="$Environment" `
    vmAdminUsername="$VMAdminUsername" `
    adminPublicKey="$sshAdminKey" `
    sqlAdminUsername="$SqlAdminUsername" `
    sqlAdminPassword="$SqlAdminPassword"

