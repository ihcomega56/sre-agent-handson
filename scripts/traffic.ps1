# 注文 API に通常トラフィックを流し続ける。
# 使い方: ./scripts/traffic.ps1 [-ApiUri <url>] [-DurationSec 1800]
param(
    [string]$ApiUri = (azd env get-value API_URI),
    [int]$DurationSec = 1800
)

function Get-StatusCode([scriptblock]$Request) {
    try { return (& $Request).StatusCode } catch { return [int]$_.Exception.Response.StatusCode }
}

$coupons = @('WELCOME10', 'VIP20', 'welcome10')
Write-Host "Sending traffic to $ApiUri for ${DurationSec}s (Ctrl+C to stop)"
$end = (Get-Date).AddSeconds($DurationSec)
while ((Get-Date) -lt $end) {
    $products = Get-StatusCode { Invoke-WebRequest -Uri "$ApiUri/api/products" -UseBasicParsing }
    $order = @{ productId = Get-Random -Minimum 1 -Maximum 5; quantity = Get-Random -Minimum 1 -Maximum 4 }
    if ((Get-Random -Maximum 10) -lt 3) { $order.couponCode = $coupons | Get-Random }
    $body = $order | ConvertTo-Json -Compress
    $status = Get-StatusCode { Invoke-WebRequest -Uri "$ApiUri/api/orders" -Method Post -ContentType 'application/json' -Body $body -UseBasicParsing }
    Write-Host "$(Get-Date -Format HH:mm:ss) GET /api/products=$products POST /api/orders=$status $body"
    Start-Sleep -Seconds 1
}
