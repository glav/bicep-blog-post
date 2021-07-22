param sqlAdminUsername string
@secure()
param sqlAdminPassword string


@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

// Environment specific zone redundant settings
var dbSkuZoneProperties = {
  dev: {
    zoneRedundant: false
  }
  test: {
    zoneRedundant: false
  }
  prod: {
    zoneRedundant: true
  }
}

var isProd = environment == 'prod'

// Main SQL Server
var sqlSrvName = 'sql-srv-glav-demo-${environment}'

// DB's Set 1
var sqlSetOneDbNameOne = 'sql-db-glav-demo-vmone-one-${environment}'
var sqlSetOneDbNameTwo = 'sql-db-glav-demo-vmone-two-${environment}'

// DB's Set 2
var sqlSetTwoDbNameOne = 'sql-db-glav-demo-vmtwo-one-${environment}'
var sqlSetTwoDbNameTwo = 'sql-db-glav-demo-vmtwo-two-${environment}'

// DB's Set 3
var sqlSetThreeDbNameOne = 'sql-db-glav-demo-vmthree-one-${environment}'
var sqlSetThreeDbNameTwo = 'sql-db-glav-demo-vmthree-two-${environment}'


// **********************************************
// IMPORTANT NOTE: Please note the 'depends' element in all the module resource definitions below. This is required
//                 as apparently deploying more than a single Db or modification of a single Db at a time causes the following
//                 deployment errors:
//                 Code: UpsertLogicalServerRequestAlreadyInProgress
//                 Message: An ongoing logical server request is already in progress, please try your request again later.
// **********************************************


// **********************************************
// SQL Set One
// **********************************************

module sqlSetOneDbOneResource 'sqlserver.bicep' = {
  name: 'sqlSetOneDbOneResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetOneDbNameTwo
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 536870912000  // 512 GB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
}

module sqlSetOneDbTwoResource 'sqlserver.bicep' = {
  name: 'sqlSetOneDbTwoResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetOneDbNameOne
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 536870912000  // 512 GB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetOneDbOneResource
  ]
}

// **********************************************
// SQL Set Two - Only for Prod
// **********************************************
module sqlSetTwoDbOneResource 'sqlserver.bicep' = if (isProd) {
  name: 'sqlSetTwoDbOneResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetTwoDbNameTwo
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 536870912000  // 512 GB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetOneDbOneResource
    sqlSetOneDbTwoResource
  ]
}

module sqlSetTwoDbTwoResource 'sqlserver.bicep' = if (isProd) {
  name: 'sqlSetTwoDbTwoResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetTwoDbNameOne
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 536870912000  // 512 GB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetTwoDbOneResource
    sqlSetOneDbOneResource
    sqlSetOneDbTwoResource
  ]
}

// **********************************************
// SQL Set Three - Only for Prod
// **********************************************
module sqlSetThreeDbOneResource 'sqlserver.bicep' = if (isProd) {
  name: 'sqlSetThreeDbOneResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetThreeDbNameOne
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 536870912000  // 512 GB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetTwoDbOneResource
    sqlSetTwoDbTwoResource
  ]
}

module sqlSetThreeDbTwoResource 'sqlserver.bicep' = if (isProd) {
  name: 'sqlSetThreeDbTwoResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetThreeDbNameTwo
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 536870912000  // 512 GB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetTwoDbOneResource
    sqlSetTwoDbTwoResource
    sqlSetThreeDbOneResource
  ]
}
