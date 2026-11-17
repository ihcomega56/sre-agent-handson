# 02. SRE Agent の作成と接続

この手順では、次の 4 つを行います。

1. SRE Agent を作成する
2. アプリのリソース グループと GitHub リポジトリを Agent に接続する
3. Azure Monitor のアラートを Agent が受け取れるよう、**応答プラン (response plan)** を作る
4. チャットで動作を確認する

> [!NOTE]
> SRE Agent のポータルは頻繁に更新されます。ボタン名や配置が違う場合は [Create and set up your agent](https://learn.microsoft.com/azure/sre-agent/create-and-set-up) を参照してください。

## 1. Agent を作成する

1. <https://sre.azure.com> を開き、**Create agent** を選びます。
2. **Basics** で次のように入力します。

   | 項目 | 値 |
   | --- | --- |
   | Subscription | 自分のサブスクリプション |
   | Resource group | **新規作成**: `rg-sre-agent-handson`（アプリとは別の RG を推奨） |
   | Agent name | 例: `sre-handson-<名前>` |
   | Region | ドロップダウンに表示されるリージョン |
   | Model provider | 既定値のまま |
   | Application Insights | 既定値（新規作成）のまま。Agent 自身の動作ログ用です |

3. **Review** → **Deploy** を選びます。2〜5 分で完了します。
4. 完了したら **Set up your agent** を選びます。

## 2. Azure リソースを接続する（Quickstart タブ）

**Set up your agent** の Quickstart タブに、**Code** / **Logs** / **Azure resources** / **Incidents** のカードが並んでいます。

### Azure resources

1. **Azure resources** を選び、アプリのリソース グループ `rg-<環境名>` を追加します。
2. **Permission level** は **Privileged** を選びます。

| Permission level | Agent のマネージド ID に付与されるロール | このハンズオンでの意味 |
| --- | --- | --- |
| Reader | Reader / Monitoring Reader / Log Analytics Reader | 調査はできるが、DB の起動などの操作はできない |
| **Privileged** | 上記に加えて Contributor 相当 | 承認を経て、PostgreSQL の起動などの**修復操作**ができる |

> [!IMPORTANT]
> ロールの割り当てには、そのスコープでの Owner または User Access Administrator の権限が必要です。割り当てに失敗する場合は、[00. 事前準備](00-prerequisites.md) の権限を確認してください。

### Logs

**Logs** で、アプリの Application Insights（`appi-...`）と Log Analytics ワークスペース（`log-...`）を接続します。Azure resources で RG を追加済みなら、自動で候補に表示されます。

### Code

1. **Code** を選び、**GitHub** を選びます。
2. 認証方式は **OAuth** が簡単です（PAT や GitHub App も使えます）。
3. [00. 事前準備](00-prerequisites.md) で作った**自分のリポジトリ**を選びます。

あとから変更する場合は **Build + setup** → **Context** → **Code access** から設定できます。

## 3. Azure Monitor のアラートを受け取る

### インシデント プラットフォームを接続する

1. **Incidents**（または **Build + setup** → **Triggers & response plans**）を開きます。
2. **Connect an incident platform** → **Azure Monitor** を選びます。

> [!TIP]
> 接続すると `quickstart_handler`（Sev0〜2 を Autonomous で処理）のようなクイックスタート用のプランが自動で作られることがあります。このハンズオンでは専用のプランを作るので、**削除**しておくと二重に調査されません。

### 応答プランを作る

**Create response plan** を選び、次のように設定します。

| 項目 | 値 | 理由 |
| --- | --- | --- |
| Name | `order-api-alerts` | |
| Severity | **Sev2** と **Sev3** | 3 つのアラートはすべてこのどちらか |
| Title contains | `order-api` | ハンズオンのアラート名はすべて `order-api-` で始まる |
| Response subagent | 既定値 | |
| Autonomy level | **Review** | Azure リソースへの**書き込み操作の前に承認を求める**モード。シナリオ 1 で承認を体験します |

**Next** でマッチするインシデントのプレビューが表示されます（まだ 0 件で問題ありません）。**Create** を選びます。

> [!NOTE]
> **Autonomous** にすると、Agent は承認なしで修復まで行います。ハンズオン後、Autonomous に変えて違いを試してみるのもおすすめです。

### Runbook を教える（推奨）

リポジトリの [`docs/runbooks/order-api-runbook.md`](runbooks/order-api-runbook.md) には、このシステムの構成と一次対応の手順をまとめています。Agent は接続したリポジトリのコードやドキュメントを参照できるので、応答プランの指示（instructions）を編集できる場合は、次のように追記しておくと調査の精度が上がります。

```text
order-api のインシデントでは、まず GitHub リポジトリの docs/runbooks/order-api-runbook.md を読み、その手順に沿って調査してください。
調査結果は「影響範囲」「原因」「根拠（クエリ・ログ）」「推奨対応」の順に日本語でまとめてください。
```

## 4. チャットで動作を確認する

Agent のチャットで、次のように話しかけてみます（`<環境名>` は自分のものに置き換えます）。

```text
rg-<環境名> にあるリソースの構成と、それぞれの役割を説明してください。
```

```text
order-api（App Service）の直近 30 分のリクエスト数、失敗率、平均応答時間を教えてください。
```

```text
接続されている GitHub リポジトリで、注文の合計金額を計算している処理はどこですか？
```

Azure のリソース一覧、App Insights のメトリクス、GitHub のコードの 3 つを参照して答えられれば、準備は完了です。

---

次へ: [03. シナリオ 1: インフラ側インシデント](03-scenario-infra.md)
