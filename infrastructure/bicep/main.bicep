// Business Assistant backend — Azure Container Apps deployment.
//
// Provisions: Container Registry, Log Analytics + Container Apps Environment, Key Vault
// (secrets populated from the secure params below), Azure SQL Server + IdentityDb/BusinessDb,
// one user-assigned Managed Identity (Key Vault read + ACR pull, shared by all 3 apps), and
// the Identity/Business/Gateway Container Apps themselves.
//
// RabbitMQ (CloudAMQP), the tenant-images Blob Storage account, and the Identity
// Data-Protection-keys Blob Storage account are NOT provisioned here — all three already
// exist from earlier work (external SaaS or created ad-hoc via az cli). Their connection
// details come in as secure params and are stored in Key Vault alongside everything else.
//
// Run against an existing resource group:
//   az deployment group create -g <rg-name> -f main.bicep -p environmentName=staging \
//     sqlAdminPassword=... jwtSecret=... ciApiKey=... blobStorageConnectionString=... \
//     dataProtectionStorageConnectionString=... \
//     sentryDsn=... rabbitMqHost=... rabbitMqUsername=... rabbitMqPassword=... rabbitMqVirtualHost=...

@allowed(['staging', 'prod'])
param environmentName string

param location string = resourceGroup().location

param sqlAdminUsername string = 'baadmin'

@secure()
param sqlAdminPassword string

@secure()
param jwtSecret string

@secure()
param ciApiKey string

@secure()
param blobStorageConnectionString string

// Separate storage account from blobStorageConnectionString (tenant images) — this one holds
// only the ASP.NET Core Data Protection key ring (see FirebaseCredentialProtector.cs), kept in
// its own account so a leak of tenant-image access doesn't also expose the key ring, or vice versa.
@secure()
param dataProtectionStorageConnectionString string

@secure()
param sentryDsn string

@secure()
param rabbitMqHost string

@secure()
param rabbitMqUsername string

@secure()
param rabbitMqPassword string

@secure()
param rabbitMqVirtualHost string

var uniqueSuffix = uniqueString(resourceGroup().id)
var aspnetEnvironment = environmentName == 'prod' ? 'Production' : 'Staging'

// Bootstrap image used only for the very first deploy, before CI/CD has pushed a real image
// to ACR. Every `az containerapp update --image ...` from the pipeline replaces it.
var bootstrapImage = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

var jwtIssuer = 'identity-api'
var jwtAudience = 'business-assistant-clients'

// ── Shared identity (Key Vault read + ACR pull for all 3 apps) ────────────────────────────
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-ba-${environmentName}'
  location: location
}

// ── Container Registry ─────────────────────────────────────────────────────────────────────
resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: toLower('acrba${environmentName}${take(uniqueSuffix, 6)}')
  location: location
  sku: { name: 'Basic' }
  properties: {
    adminUserEnabled: false
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, uami.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// ── Key Vault ───────────────────────────────────────────────────────────────────────────────
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${environmentName}-${take(uniqueSuffix, 6)}'
  location: location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource kvSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, uami.id, 'KeyVaultSecretsUser')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// ── Azure SQL ───────────────────────────────────────────────────────────────────────────────
resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: 'sql-ba-${environmentName}-${take(uniqueSuffix, 6)}'
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    minimalTlsVersion: '1.2'
  }
}

// Container Apps have no static IP — this is Azure SQL's "Allow Azure services" firewall rule.
resource sqlFirewallAllowAzure 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource identityDb 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: 'IdentityDb'
  location: location
  sku: { name: 'Basic', tier: 'Basic' }
  properties: { maxSizeBytes: 2147483648 }
}

resource businessDb 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: 'BusinessDb'
  location: location
  sku: { name: 'Basic', tier: 'Basic' }
  properties: { maxSizeBytes: 2147483648 }
}

var identityDbConnectionString = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=IdentityDb;Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
var businessDbConnectionString = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=BusinessDb;Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

// ── Key Vault secrets ───────────────────────────────────────────────────────────────────────
resource secretIdentityDbConn 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'identity-db-connection-string'
  properties: { value: identityDbConnectionString }
}

resource secretBusinessDbConn 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'business-db-connection-string'
  properties: { value: businessDbConnectionString }
}

resource secretJwt 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'jwt-secret'
  properties: { value: jwtSecret }
}

resource secretCiApiKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'ci-api-key'
  properties: { value: ciApiKey }
}

resource secretBlobStorage 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'blob-storage-connection-string'
  properties: { value: blobStorageConnectionString }
}

resource secretDataProtectionStorage 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'dataprotection-storage-connection-string'
  properties: { value: dataProtectionStorageConnectionString }
}

resource secretSentryDsn 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'sentry-dsn'
  properties: { value: sentryDsn }
}

resource secretRabbitMqHost 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'rabbitmq-host'
  properties: { value: rabbitMqHost }
}

resource secretRabbitMqUsername 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'rabbitmq-username'
  properties: { value: rabbitMqUsername }
}

resource secretRabbitMqPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'rabbitmq-password'
  properties: { value: rabbitMqPassword }
}

resource secretRabbitMqVirtualHost 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'rabbitmq-virtualhost'
  properties: { value: rabbitMqVirtualHost }
}

// ── Container Apps Environment ─────────────────────────────────────────────────────────────
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-ba-${environmentName}'
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-ba-${environmentName}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// ── Container Apps ─────────────────────────────────────────────────────────────────────────
// RabbitMq:VirtualHost / RabbitMq:UseSsl are read by Identity.Infrastructure/Business.Infrastructure's
// DependencyInjection.cs — CloudAMQP requires TLS and a non-"/" virtual host, unlike local RabbitMQ.
var rabbitMqEnv = [
  { name: 'RabbitMq__Host', secretRef: 'rabbitmq-host' }
  { name: 'RabbitMq__Username', secretRef: 'rabbitmq-username' }
  { name: 'RabbitMq__Password', secretRef: 'rabbitmq-password' }
  { name: 'RabbitMq__VirtualHost', secretRef: 'rabbitmq-virtualhost' }
  { name: 'RabbitMq__UseSsl', value: 'true' }
]

var commonKvSecrets = [
  { name: 'jwt-secret', keyVaultUrl: secretJwt.properties.secretUri }
  { name: 'blob-storage-connection-string', keyVaultUrl: secretBlobStorage.properties.secretUri }
  { name: 'sentry-dsn', keyVaultUrl: secretSentryDsn.properties.secretUri }
  { name: 'rabbitmq-host', keyVaultUrl: secretRabbitMqHost.properties.secretUri }
  { name: 'rabbitmq-username', keyVaultUrl: secretRabbitMqUsername.properties.secretUri }
  { name: 'rabbitmq-password', keyVaultUrl: secretRabbitMqPassword.properties.secretUri }
  { name: 'rabbitmq-virtualhost', keyVaultUrl: secretRabbitMqVirtualHost.properties.secretUri }
]

module identityApp 'modules/containerApp.bicep' = {
  name: 'identityApp'
  params: {
    name: 'ca-identity-${environmentName}'
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.id
    userAssignedIdentityId: uami.id
    acrLoginServer: acr.properties.loginServer
    image: bootstrapImage
    targetPort: 8080
    external: false
    minReplicas: 0
    secrets: concat(commonKvSecrets, [
      { name: 'identity-db-connection-string', keyVaultUrl: secretIdentityDbConn.properties.secretUri }
      { name: 'ci-api-key', keyVaultUrl: secretCiApiKey.properties.secretUri }
      { name: 'dataprotection-storage-connection-string', keyVaultUrl: secretDataProtectionStorage.properties.secretUri }
    ])
    env: concat([
      { name: 'ASPNETCORE_ENVIRONMENT', value: aspnetEnvironment }
      { name: 'ASPNETCORE_URLS', value: 'http://+:8080' }
      { name: 'ConnectionStrings__IdentityDb', secretRef: 'identity-db-connection-string' }
      { name: 'Jwt__Secret', secretRef: 'jwt-secret' }
      { name: 'Jwt__Issuer', value: jwtIssuer }
      { name: 'Jwt__Audience', value: jwtAudience }
      { name: 'Jwt__ExpiryMinutes', value: '60' }
      { name: 'CiApiKey', secretRef: 'ci-api-key' }
      { name: 'BlobStorage__ConnectionString', secretRef: 'blob-storage-connection-string' }
      { name: 'DataProtection__StorageConnectionString', secretRef: 'dataprotection-storage-connection-string' }
      { name: 'Sentry__Dsn', secretRef: 'sentry-dsn' }
    ], rabbitMqEnv)
  }
}

module businessApp 'modules/containerApp.bicep' = {
  name: 'businessApp'
  params: {
    name: 'ca-business-${environmentName}'
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.id
    userAssignedIdentityId: uami.id
    acrLoginServer: acr.properties.loginServer
    image: bootstrapImage
    targetPort: 8080
    external: false
    minReplicas: 0
    secrets: concat(commonKvSecrets, [
      { name: 'business-db-connection-string', keyVaultUrl: secretBusinessDbConn.properties.secretUri }
    ])
    env: concat([
      { name: 'ASPNETCORE_ENVIRONMENT', value: aspnetEnvironment }
      { name: 'ASPNETCORE_URLS', value: 'http://+:8080' }
      { name: 'ConnectionStrings__BusinessDb', secretRef: 'business-db-connection-string' }
      { name: 'Jwt__Secret', secretRef: 'jwt-secret' }
      { name: 'Jwt__Issuer', value: jwtIssuer }
      { name: 'Jwt__Audience', value: jwtAudience }
      { name: 'BlobStorage__ConnectionString', secretRef: 'blob-storage-connection-string' }
      { name: 'Sentry__Dsn', secretRef: 'sentry-dsn' }
    ], rabbitMqEnv)
  }
}

module gatewayApp 'modules/containerApp.bicep' = {
  name: 'gatewayApp'
  params: {
    name: 'ca-gateway-${environmentName}'
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.id
    userAssignedIdentityId: uami.id
    acrLoginServer: acr.properties.loginServer
    image: bootstrapImage
    targetPort: 8080
    external: true
    minReplicas: 0
    env: [
      { name: 'ASPNETCORE_ENVIRONMENT', value: aspnetEnvironment }
      { name: 'ASPNETCORE_URLS', value: 'http://+:8080' }
      { name: 'ReverseProxy__Clusters__identityCluster__Destinations__destination1__Address', value: 'https://${identityApp.outputs.fqdn}' }
      { name: 'ReverseProxy__Clusters__businessCluster__Destinations__destination1__Address', value: 'https://${businessApp.outputs.fqdn}' }
    ]
  }
}

output acrLoginServer string = acr.properties.loginServer
output keyVaultName string = keyVault.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output gatewayFqdn string = gatewayApp.outputs.fqdn
output identityAppName string = 'ca-identity-${environmentName}'
output businessAppName string = 'ca-business-${environmentName}'
output gatewayAppName string = 'ca-gateway-${environmentName}'
