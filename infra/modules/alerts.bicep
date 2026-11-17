param tags object
param appId string
param appInsightsId string
param alertEmail string
param actionGroupName string

@description('予兆検知シナリオで使うメモリ閾値（MB）')
param memoryThresholdMb int = 700

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = if (!empty(alertEmail)) {
  name: actionGroupName
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'sreHandson'
    enabled: true
    emailReceivers: [
      { name: 'handson-owner', emailAddress: alertEmail, useCommonAlertSchema: true }
    ]
  }
}

var actions = empty(alertEmail) ? [] : [ { actionGroupId: actionGroup.id } ]

// シナリオ 1（インフラ障害）で発火することを想定
resource http5xx 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'order-api-http-5xx'
  location: 'global'
  tags: tags
  properties: {
    description: 'order-api returns HTTP 5xx errors (more than 10 in 5 minutes).'
    severity: 2
    enabled: true
    scopes: [ appId ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'Http5xx'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Total'
        }
      ]
    }
    actions: actions
  }
}

// シナリオ 2（アプリ不具合）で発火することを想定
resource exceptions 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'order-api-exceptions'
  location: 'global'
  tags: tags
  properties: {
    description: 'order-api throws server exceptions (more than 10 in 5 minutes).'
    severity: 2
    enabled: true
    scopes: [ appInsightsId ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'ServerExceptions'
          metricNamespace: 'microsoft.insights/components'
          metricName: 'exceptions/server'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Count'
        }
      ]
    }
    actions: actions
  }
}

// シナリオ 3（予兆検知）で「発火する前に」Agent が気付けるかを確認する対象
resource memory 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'order-api-memory-high'
  location: 'global'
  tags: tags
  properties: {
    description: 'order-api memory working set exceeds ${memoryThresholdMb} MB.'
    severity: 3
    enabled: true
    scopes: [ appId ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'MemoryWorkingSet'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'MemoryWorkingSet'
          operator: 'GreaterThan'
          threshold: memoryThresholdMb * 1024 * 1024
          timeAggregation: 'Average'
        }
      ]
    }
    actions: actions
  }
}
