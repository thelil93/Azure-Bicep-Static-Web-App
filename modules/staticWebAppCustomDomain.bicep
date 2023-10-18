// ------------------
// PARAMETERS
// ------------------

param paramParentApp string
param paramCustomDomain string

// ------------------
// RESOURCES
// ------------------

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' existing = {
  name: paramParentApp
}

resource staticWebAppCustomDomain 'Microsoft.Web/staticSites/customDomains@2022-09-01' = {
  name: paramCustomDomain
  parent: staticWebApp
  properties: {
    validationMethod: 'cname-delegation'
  }
}
