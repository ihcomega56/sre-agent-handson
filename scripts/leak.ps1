# メモリを少しずつ増やし続ける（予兆検知シナリオ用）。
# 使い方: ./scripts/leak.ps1 [-ApiUri <url>] [-StepMb 20] [-IntervalSec 60] [-Steps 25]
param(
    [string]$ApiUri = (azd env get-value API_URI),
    [int]$StepMb = 20,
    [int]$IntervalSec = 60,
    [int]$Steps = 25
)

Write-Host "Leaking ${StepMb}MB every ${IntervalSec}s, $Steps times, on $ApiUri"
for ($i = 1; $i -le $Steps; $i++) {
    $result = Invoke-RestMethod -Uri "$ApiUri/api/debug/leak?mb=$StepMb" -Method Post
    Write-Host "$(Get-Date -Format HH:mm:ss) [$i/$Steps] $($result | ConvertTo-Json -Compress)"
    if ($i -lt $Steps) { Start-Sleep -Seconds $IntervalSec }
}
