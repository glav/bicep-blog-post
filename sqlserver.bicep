
@allowed([
  'prod'
  'test'
  'dev'
])
param environment string
param serverName string
param databaseName string
param adminUsername string
@secure()
param adminPassword string

@allowed([
  2
  4
  6
  8
  10
  12
  14
  16
  18
  20
  24
  32
  40
  80
])
param sqlVcores int
param sqlMaxDiskSizeBytes int
param sqlZoneRedundant bool

var isProd = environment == 'prd' ? true : false
var environmentKey = isProd ? 'prod' : 'nonprod'
var backupPolicies = {
  nonprod: {
    monthlyRetention: 'P4M'
  }
  prod: {
    weeklyRetention: 'P6W'
    monthlyRetention: 'P6M'
    yearlyRetention: 'P6Y'
    weekOfYear: 26
  }
}

var storageAcctName = 'sa${environment}blogpostsqlaudit'
var saAcctType = isProd ? 'Standard_GRS' : 'Standard_LRS'

resource storageAcct 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAcctName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: saAcctType
  }
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: serverName
  location: resourceGroup().location
  properties: {
    minimalTlsVersion: '1.2'
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
}

resource sqlBackupsShortTerm 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-02-01-preview' = {
  parent: sqlDatabase
  name: 'Default'
  properties: {
    retentionDays: 30
  }
}

resource sqlBackupsLongTerm 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-02-01-preview' = {
  parent: sqlDatabase
  name: 'Default'
  properties: backupPolicies[environmentKey]
}


resource sqlAudit 'Microsoft.Sql/servers/auditingSettings@2017-03-01-preview' = {
  name: '${sqlServer.name}/Default'
  properties: {
    storageEndpoint: storageAcct.properties.primaryEndpoints.blob
    storageAccountSubscriptionId: subscription().subscriptionId
    storageAccountAccessKey: listKeys(storageAcct.id, storageAcct.apiVersion).keys[0].value
    state: 'Enabled'
    retentionDays: 90
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
  }
  dependsOn: [
    sqlServer
  ]
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: '${sqlServer.name}/${databaseName}'
  location: resourceGroup().location
  sku: {
      name: 'GP_Gen5'
      tier: 'GeneralPurpose'
      family: 'Gen5'
      capacity: sqlVcores
  }
  properties: {
    collation: 'Latin1_General_CI_AS'
    maxSizeBytes: sqlMaxDiskSizeBytes
    zoneRedundant: sqlZoneRedundant

  }
}


output sqlServerFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
