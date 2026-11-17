param location string
param tags object
param planName string
param planSku string
param appName string
param appInsightsConnectionString string
param jdbcUrl string
param dbUser string
@secure()
param dbPassword string
param logAnalyticsWorkspaceId string

resource plan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: planName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: planSku
  }
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2024-04-01' = {
  name: appName
  location: location
  tags: union(tags, { 'azd-service-name': 'api' })
  kind: 'app,linux'
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'JAVA|21-java21'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsightsConnectionString }
        { name: 'APPLICATIONINSIGHTS_ROLE_NAME', value: 'order-api' }
        { name: 'SPRING_DATASOURCE_URL', value: jdbcUrl }
        { name: 'SPRING_DATASOURCE_USERNAME', value: dbUser }
        // ハンズオンを簡単にするため App Settings に直接設定（本番では Key Vault 参照 / Entra 認証を推奨）
        { name: 'SPRING_DATASOURCE_PASSWORD', value: dbPassword }
        { name: 'APP_LEAK_ENABLED', value: 'true' }
        { name: 'JAVA_OPTS', value: '-Xmx768m' }
        { name: 'SCM_DO_BUILD_DURING_DEPLOYMENT', value: 'false' }
      ]
    }
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-log-analytics'
  scope: app
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      { category: 'AppServiceHTTPLogs', enabled: true }
      { category: 'AppServiceConsoleLogs', enabled: true }
      { category: 'AppServiceAppLogs', enabled: true }
      { category: 'AppServicePlatformLogs', enabled: true }
    ]
    metrics: [
      { category: 'AllMetrics', enabled: true }
    ]
  }
}

output appId string = app.id
output name string = app.name
output uri string = 'https://${app.properties.defaultHostName}'
