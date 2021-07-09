param vmAdminUsername string
@secure()
param vmAdminPassword string
param sqlAdminUsername string
@secure()
param sqlAdminPassword string


@allowed([
  'prod'
  'test'
  'dev'
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

// Environment specific VM names
var vmOne = {
  dev: {
    name: 'vmNumberOneDev'
  }
  test: {
    name: 'vmNumberOneTest'
  }
  prod: {
    name: 'vmNumberOneProd'
  }
}
var vmTwo = {
  dev: {
    name: 'vmNumberTwoDev'
  }
  test: {
    name: 'vmNumberTwoTest'
  }
  prod: {
    name: 'vmNumberTwoProd'
  }
}
var vmThree = {
  dev: {
    name: 'vmNumberThreeDev'
  }
  test: {
    name: 'vmNumberThreeTest'
  }
  prod: {
    name: 'vmNumberThreeProd'
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
// VM and SQL Set One
// **********************************************
module vmOneResource 'appserver.bicep' = {
  name: 'vmOneResource'
  params:{
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmName: vmOne[environment].name
    vmSize: 'Standard_D4s_v3'
  }
}

module sqlSetOneDbOneResource 'sqlserver.bicep' = {
  name: 'sqlSetOneDbOneResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetOneDbNameTwo
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 12
    sqlMaxDiskSizeBytes: 3221225472000  // 3 TB
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
    sqlVcores: 4
    sqlMaxDiskSizeBytes: 1073741824000  // 1 Tb
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetOneDbOneResource
  ]
}

// **********************************************
// VM and SQL Set Two - Only for Prod
// **********************************************
module vmTwoResource 'appserver.bicep' = if (isProd) {
  name: 'vmTwoResource'
  params:{
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmName: vmTwo[environment].name
    vmSize: 'Standard_D4s_v3'
  }
}
module sqlSetTwoDbOneResource 'sqlserver.bicep' = if (isProd) {
  name: 'sqlSetTwoDbOneResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetTwoDbNameTwo
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 12
    sqlMaxDiskSizeBytes: 1073741824000  // 1 TB
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
    sqlVcores: 4
    sqlMaxDiskSizeBytes: 1073741824000  // 1 TB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetTwoDbOneResource
    sqlSetOneDbOneResource
    sqlSetOneDbTwoResource
  ]
}

// **********************************************
// VM and SQL Set Three - Only for Prod
// **********************************************
module vmThreeResource 'appserver.bicep' = if (isProd) {
  name: 'vmThreeResource'
  params:{
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmName: vmThree[environment].name
    vmSize: 'Standard_D4s_v3'
  }
}
module sqlSetThreeDbOneResource 'sqlserver.bicep' = if (isProd) {
  name: 'sqlSetThreeDbOneResource'
  params: {
    serverName: sqlSrvName
    databaseName: sqlSetThreeDbNameOne
    environment: environment
    adminPassword: sqlAdminPassword
    adminUsername: sqlAdminUsername
    sqlVcores: 2
    sqlMaxDiskSizeBytes: 1073741824000  // 1 TB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetTwoDbOneResource
    sqlSetTwoDbOneResource
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
    sqlVcores: 4 
    sqlMaxDiskSizeBytes: 1073741824000  // 1 TB
    sqlZoneRedundant: dbSkuZoneProperties[environment].zoneRedundant
  }
  dependsOn: [
    sqlSetTwoDbOneResource
    sqlSetTwoDbOneResource
    sqlSetThreeDbOneResource
  ]
}
