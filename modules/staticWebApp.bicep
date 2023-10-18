// ------------------
// PARAMETERS
// ------------------

param paramLocation string
param paramResourceSuffix string
param paramRepositoryUrl string
param paramRepositoryToken string
param paramRepositoryBranch string = 'main'
param paramAppLocation string = '/'
param paramApiLocation string = ''
param paramAppArtifactLocation string = 'public'
param paramSku string = 'Free'
param paramSkuCode string = 'Free'

// ------------------
// VARIABLES
// ------------------

var naming = loadJsonContent('../naming.json')

// ------------------
// RESOURCES
// ------------------

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: '${naming.resourceAbbreviations.staticWebApp}-${paramResourceSuffix}'
  location: paramLocation
  tags: null
  properties: {
    repositoryUrl: paramRepositoryUrl
    branch: paramRepositoryBranch
    repositoryToken: paramRepositoryToken
    buildProperties: {
      appLocation: paramAppLocation
      apiLocation: paramApiLocation
      appArtifactLocation: paramAppArtifactLocation
    }
  }
  sku: {
    tier: paramSku
    name: paramSkuCode
  }
}

// ------------------
// OUTPUTS
// ------------------

output staticWebAppDefaultHostname string = staticWebApp.properties.defaultHostname
output staticWebAppName string = staticWebApp.name
output staticWebAppId string = staticWebApp.id
