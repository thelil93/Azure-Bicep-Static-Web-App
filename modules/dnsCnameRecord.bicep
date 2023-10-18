// ------------------
// PARAMETERS
// ------------------

param paramCustomDomain string
param paramSubDomain string
param paramStaticWebAppDefaultHostname string

// ------------------
// RESOURCES
// ------------------

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${paramCustomDomain}/${paramSubDomain}'
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: paramStaticWebAppDefaultHostname
    }
  }
}


