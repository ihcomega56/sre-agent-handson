# 01. アプリのデプロイ

`azd up` 1 回で、次のリソースを作成してアプリをデプロイします。

| リソース | 用途 |
| --- | --- |
| リソース グループ `rg-<環境名>` | アプリ一式 |
| App Service プラン (Linux, 既定 B1) + Web App (Java 21) | 注文 API `order-api` |
| Azure Database for PostgreSQL Flexible Server (B1ms) | 商品・注文データ |
| Log Analytics ワークスペース + Application Insights | ログ・メトリクス・例外・依存関係のテレメトリ |
| メトリック アラート 3 件 | `order-api-http-5xx` / `order-api-exceptions` / `order-api-memory-high` |
| （任意）アクション グループ | アラートをメールで受け取る場合のみ |

## 1. サインイン

```bash
az login
azd auth login
```

> [!TIP]
> テナントが複数ある場合は `az login --tenant <tenant-id>`、`azd auth login --tenant-id <tenant-id>` のようにテナントを指定してください。

## 2. azd の設定

このアプリは Gradle でビルドします。azd 標準の Java サポートは Maven 専用のため、ビルドした jar を「custom 言語」として配置しています。custom 言語はアルファ機能なので、有効にしておきます。

```bash
azd config set alpha.language.custom on
```

## 3. 環境を作成してデプロイ

```bash
azd env new sre-handson          # 環境名は任意（リソース グループ名に使われます）
azd env set ALERT_EMAIL you@example.com   # 任意: アラートをメールで受け取る場合
azd up
```

- サブスクリプションとリージョンを聞かれたら、自分のサブスクリプションと近いリージョン（例: `japaneast`）を選びます。
- 完了まで 10〜15 分ほどかかります（PostgreSQL の作成に時間がかかります）。
- `azd up` の中で `./gradlew bootJar` が実行され、`app/build/azd/app.jar` が App Service にデプロイされます。

> [!NOTE]
> `InternalSubscriptionIsOverQuotaForSku`（`Current Limit (B1 VMs): 0` など）は、**そのリージョンの App Service のクォータ不足**によるエラーです。App Service のクォータはリージョンごとに異なるため、まず別のリージョンで試してください。リソース グループのリージョンは変えられないので、一度削除してから作り直します。
>
> ```bash
> azd down --purge --force
> azd env set AZURE_LOCATION swedencentral   # 例: swedencentral / westus3 / japanwest など
> azd up
> ```
>
> PostgreSQL で `SkuNotAvailable` になった場合（サブスクリプションによっては、そのリージョンで B1ms が制限されています）も、同じ手順でリージョンを変えてください。
>
> PostgreSQL と App Service が同じリージョンでそろわない場合は、次の設定で対応できます。
>
> | 環境変数 | 意味 | 例 |
> | --- | --- | --- |
> | `APP_SERVICE_LOCATION` | App Service だけを別のリージョンに置く（空ならリソース グループと同じ） | `azd env set APP_SERVICE_LOCATION japanwest` |
> | `APP_SERVICE_PLAN_SKU` | App Service プランの SKU（既定 `B1`） | `azd env set APP_SERVICE_PLAN_SKU P0v3` |

## 4. 動作確認

```bash
API_URI=$(azd env get-value API_URI)
curl $API_URI/actuator/health
curl $API_URI/api/products
curl -X POST -H 'Content-Type: application/json' \
  -d '{"productId":1,"quantity":2,"couponCode":"WELCOME10"}' \
  $API_URI/api/orders
```

PowerShell の場合:

```powershell
$ApiUri = azd env get-value API_URI
Invoke-RestMethod "$ApiUri/actuator/health"
Invoke-RestMethod "$ApiUri/api/products"
Invoke-RestMethod "$ApiUri/api/orders" -Method Post -ContentType 'application/json' `
  -Body '{"productId":1,"quantity":2,"couponCode":"WELCOME10"}'
```

`{"status":"UP"}`、商品一覧、注文結果（`totalPrice` が 10% 引き）が返れば成功です。

> [!NOTE]
> デプロイ直後は JVM の起動を待つため、最初のリクエストに数十秒かかることがあります。

## 5. 通常トラフィックを流す

インシデントの「前後」を Agent に比較させるため、ハンズオン中は通常のトラフィックを流し続けておくのがおすすめです。**別のターミナル**で次を実行します（既定で 30 分間、約 1 秒ごとに商品一覧と注文の API を呼びます）。

```bash
./scripts/traffic.sh            # 継続時間を変える場合: ./scripts/traffic.sh "$API_URI" 3600
```

```powershell
./scripts/traffic.ps1           # 例: ./scripts/traffic.ps1 -DurationSec 3600
```

すべて `200` / `201` が返ることを確認します。

## 6. Azure ポータルで確認

[Azure ポータル](https://portal.azure.com) でリソース グループ `rg-<環境名>` を開き、次を確認します。

- **Application Insights** → **アプリケーション マップ**: `order-api` から PostgreSQL への依存関係が表示されること（数分かかります）
- **監視** → **アラート** → **アラート ルール**: `order-api-` で始まるルールが 3 件あること

| アラート ルール | 条件 | 重大度 | 使うシナリオ |
| --- | --- | --- | --- |
| `order-api-http-5xx` | App Service の HTTP 5xx が 5 分間で 10 件超 | Sev2 | シナリオ 1, 2 |
| `order-api-exceptions` | App Insights のサーバー例外が 5 分間で 10 件超 | Sev2 | シナリオ 2 |
| `order-api-memory-high` | App Service のメモリ ワーキング セット平均が 700 MB 超 | Sev3 | シナリオ 3 |

---

次へ: [02. SRE Agent の作成と接続](02-create-sre-agent.md)
