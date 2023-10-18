targetScope='subscription'

// ------------------
// PARAMETERS
// ------------------

@description('The name of static web app resource. Up to 15 characters long.')
@maxLength(15)
param paramSiteName string

@description('The name of the environment. (e.g. "dev", "test", "prod", "uat", "dr", "qa") Up to 4 characters long.')
@maxLength(4)
param paramEnvironment string

@description('The name of the Azure region that the resources are to be deployed in. (defined in naming.json)')
@allowed([
  'westeurope'
  'northeurope'
  'australiacentral'
  'australiacentral2'
  'australiaeast'
  'australiasoutheast'
  'brazilsouth'
  'brazilsoutheast'
  'canadacentral'
  'canadaeast'
  'centralindia'
  'centralus'
  'centraluseuap'
  'eastasia'
  'eastus'
  'eastus2'
  'eastus2euap'
  'francecentral'
  'francesouth'
  'germanynorth'
  'germanywestcentral'
  'japaneast'
  'japanwest'
  'jioindiacentral'
  'jioindiawest'
  'koreacentral'
  'koreasouth'
  'northcentralus'
  'northeurope'
  'norwayeast'
  'norwaywest'
  'southafricanorth'
  'southafricawest'
  'southcentralus'
  'southeastasia'
  'southindia'
  'swedencentral'
  'switzerlandnorth'
  'switzerlandwest'
  'uaecentral'
  'uaenorth'
  'uksouth'
  'ukwest'
  'westcentralus'
  'westeurope'
  'westindia'
  'westus'
  'westus2'
  'westus3'
])
param paramLocation string

@description('The domain name for the deployed (public) application. (available domains defined in existingResources.json)')
param paramCustomDomain string

@description('The subdomain that the deployed application will be accessed by. (e.g "paramSubDomain.paramCustomDomain")')
param paramSubDomain string

@description('The URL to your application repository. (e.g "https://github.com/<YOUR-GITHUB-USERNAME>/<YOUR-REPOSITORY-NAME>.git")')
param paramRepositoryUrl string

@description('Your GitHub personal access token.')
param paramRepositoryToken string

// -------------------
// OPTIONAL PARAMETERS
// -------------------

@description('The branch of your repository you want to deploy. Defaults to "main" in "modules/staticWebApp.bicep"')
param paramRepositoryBranch string?

@description('Your app source code path. Defaults to "/" in "modules/staticWebApp.bicep"')
param paramAppLocation string?

@description('Your optional API source code path. Defaults to " " in "modules/staticWebApp.bicep"')
param paramApiLocation string?

@description('Your optional built app content directory. Defaults to "public" in "modules/staticWebApp.bicep"')
param paramAppArtifactLocation string?

@description('Choice of hosting plan tier for the static web app. Defaults to "Free" in "modules/staticWebApp.bicep"')
param paramSku string?

@description('Name of hosting plan tier for the static web app. Defaults to "Free" in "modules/staticWebApp.bicep"')
param paramSkuCode string?

// ------------------
// VARIABLES
// ------------------

var naming = loadJsonContent('./naming.json')
var existingResources = loadJsonContent('./existingResources.json')
var resourceSuffix = '${paramEnvironment}-${paramSiteName}-${naming.regionAbbreviations[paramLocation]}'

// ------------------
// RESOURCES
// ------------------

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: '${naming.resourceAbbreviations.resourceGroup}-${resourceSuffix}'
  location: paramLocation
}

module staticWebApp 'modules/staticWebApp.bicep' = {
  name: take('staticWebApp-${deployment().name}-deployment', 64)
  scope: resourceGroup
  params: {
    paramLocation: resourceGroup.location 
    paramResourceSuffix: resourceSuffix
    paramRepositoryUrl: paramRepositoryUrl
    paramRepositoryToken: paramRepositoryToken
    paramRepositoryBranch: paramRepositoryBranch
    paramAppLocation: paramAppLocation
    paramApiLocation: paramApiLocation
    paramAppArtifactLocation: paramAppArtifactLocation
    paramSku: paramSku
    paramSkuCode: paramSkuCode
  }
}

module dnsCnameRecord 'modules/dnsCnameRecord.bicep' = if (paramCustomDomain != 'example.com') {
  dependsOn: [staticWebApp]
  name: take('dnsCnameRecord-${deployment().name}-deployment', 64)
  scope: az.resourceGroup(existingResources.domains[paramCustomDomain].subscription, existingResources.domains[paramCustomDomain].resourceGroup)
  params: {
    paramCustomDomain: paramCustomDomain
    paramSubDomain: paramSubDomain
    paramStaticWebAppDefaultHostname: staticWebApp.outputs.staticWebAppDefaultHostname
  }
}

module staticWebAppCustomDomain 'modules/staticWebAppCustomDomain.bicep' = if (paramCustomDomain != 'example.com') {
  dependsOn: [dnsCnameRecord]
  name: take('staticWebAppCustomDomain-${deployment().name}-deployment', 64)
  scope: resourceGroup
  params: {
    paramParentApp: staticWebApp.outputs.staticWebAppName
    paramCustomDomain: '${paramSubDomain}.${paramCustomDomain}'
  }
}
