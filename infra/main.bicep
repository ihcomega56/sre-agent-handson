targetScope = 'subscription'

@minLength(1)
@maxLength(40)
@description('azd 環境名。リソース名の一部に使われます。')
param environmentName string

@minLength(1)
@description('アプリ一式をデプロイするリージョン')
param location string

@description('アラート通知先のメールアドレス（任意）。空ならメール通知なし。')
param alertEmail string = ''

@description('App Service プランの SKU。B1 のクォータがないサブスクリプションでは P0v3 などに変更します。')
param appServicePlanSku string = 'B1'

@description('App Service だけを別リージョンに置く場合に指定します（App Service のクォータがないリージョン向け）。空なら location と同じ。')
param appServiceLocation string = ''

@secure()
@description('PostgreSQL 管理者パスワード。未指定ならデプロイごとに自動生成されます。')
param postgresAdminPassword string = newGuid()

var tags = { 'azd-env-name': environmentName }
var token = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module monitoring 'modules/monitoring.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: 'log-${token}'
    appInsightsName: 'appi-${token}'
  }
}

module database 'modules/database.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    serverName: 'psql-${token}'
    adminPassword: 'Pg!${postgresAdminPassword}'
  }
}

module app 'modules/app.bicep' = {
  scope: rg
  params: {
    location: empty(appServiceLocation) ? location : appServiceLocation
    tags: tags
    planName: 'asp-${token}'
    planSku: appServicePlanSku
    appName: 'app-order-api-${token}'
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    jdbcUrl: database.outputs.jdbcUrl
    dbUser: database.outputs.adminUser
    dbPassword: 'Pg!${postgresAdminPassword}'
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}

module alerts 'modules/alerts.bicep' = {
  scope: rg
  params: {
    tags: tags
    appId: app.outputs.appId
    appInsightsId: monitoring.outputs.appInsightsId
    alertEmail: alertEmail
    actionGroupName: 'ag-${token}'
  }
}

output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output API_URI string = app.outputs.uri
output APP_NAME string = app.outputs.name
output POSTGRES_SERVER_NAME string = database.outputs.serverName
output APPLICATIONINSIGHTS_NAME string = monitoring.outputs.appInsightsName
