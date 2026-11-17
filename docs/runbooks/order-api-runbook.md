# order-api Runbook

SRE Agent やオンコール担当者が、order-api のインシデント対応で最初に読むドキュメントです。

## システム構成

| コンポーネント | Azure リソース | 備考 |
| --- | --- | --- |
| 注文 API | App Service (Linux, Java 21)。アプリ設定 `APPLICATIONINSIGHTS_ROLE_NAME=order-api` | Spring Boot。ソースは `app/` |
| データベース | Azure Database for PostgreSQL Flexible Server、DB 名 `orders` | 接続は JDBC。HikariCP の接続タイムアウトは 5 秒 |
| 監視 | Application Insights / Log Analytics | 例外・依存関係・リクエストを収集 |

主な API:

- `GET /api/products`
- `POST /api/orders`（`couponCode` は**任意**）
- `GET /api/orders/{id}`

## アラートと一次対応

### order-api-http-5xx / order-api-exceptions

1. App Insights の `exceptions` と `requests` で、失敗しているエンドポイントと例外の型を確認する。
2. **DB 接続エラー**（`CannotCreateTransactionException`、`java.net.SocketTimeoutException: Connect timed out`、`org.postgresql.util.PSQLException`）の場合:
   - PostgreSQL Flexible Server の状態（`state`）を確認する。
   - Activity Log で直近のサーバー停止（Stops an existing server）などの操作と、その実行者を確認する。
   - 停止している場合は起動する（`az postgres flexible-server start`）。**本番データベースへの操作なので必ず承認を得ること。**
3. **アプリの例外**（`NullPointerException` など）の場合:
   - App Service の直近のデプロイ時刻と、例外が出始めた時刻を比較する。
   - スタックトレースのクラスと行から、GitHub リポジトリの該当コードと直近のコミットを確認する。
   - 原因のコードと修正案を GitHub Issue にまとめる。
   - 暫定対応として、**直前の正常版（`main` ブランチ）を再デプロイ**するよう提案する。

### order-api-memory-high

1. App Service の `MemoryWorkingSet` の推移を確認する（JVM の最大ヒープは `-Xmx768m`）。
2. 増加が続いている場合は、`/api/debug/leak` の呼び出しなど、メモリを保持し続ける処理がないか App Insights の `requests` で確認する。
3. 暫定対応は `DELETE /api/debug/leak`（デバッグ用のメモリ解放）、または App Service の再起動。

## エスカレーション

- 復旧操作（DB の起動、App Service の再起動、再デプロイ）は**承認制**とする。
- 30 分以内に復旧しない場合はアプリ担当チームにエスカレーションする（ハンズオンではこの手順は不要）。
