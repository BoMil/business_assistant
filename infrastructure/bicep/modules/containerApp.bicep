// Reusable Container App — used once each for Identity, Business and Gateway from main.bicep.
// The caller decides ingress (internal/external), image, env vars and which Key Vault secrets
// this app needs; this module just wires those into a Microsoft.App/containerApps resource
// using the shared user-assigned identity for both ACR pull and Key Vault secret access.

param name string
param location string
param containerAppsEnvironmentId string
param userAssignedIdentityId string
param acrLoginServer string
param image string
param targetPort int
param external bool

@description('Key Vault-backed secrets, e.g. [{ name: \'jwt-secret\', keyVaultUrl: \'https://.../secrets/jwt-secret\' }]')
param secrets array = []

@description('Container env vars, e.g. [{ name: \'Jwt__Secret\', secretRef: \'jwt-secret\' }, { name: \'Jwt__Issuer\', value: \'identity-api\' }]')
param env array = []

param minReplicas int
param maxReplicas int = 3
param cpu string = '0.25'
param memory string = '0.5Gi'

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: external
        targetPort: targetPort
        transport: 'auto'
      }
      registries: [
        {
          server: acrLoginServer
          identity: userAssignedIdentityId
        }
      ]
      secrets: [for s in secrets: {
        name: s.name
        keyVaultUrl: s.keyVaultUrl
        identity: userAssignedIdentityId
      }]
    }
    template: {
      containers: [
        {
          name: name
          image: image
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          env: env
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
