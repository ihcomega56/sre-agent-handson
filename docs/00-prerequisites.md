# 00. 事前準備

## 1. Azure サブスクリプションと権限

| 必要なもの | 理由 |
| --- | --- |
| 有効な Azure サブスクリプション | アプリ環境と SRE Agent を作成します |
| サブスクリプションの **所有者 (Owner)**、または **共同作成者 (Contributor) + ユーザー アクセス管理者 (User Access Administrator)** | SRE Agent の作成時と、Agent のマネージド ID へのロール割り当てに必要です（[前提条件](https://learn.microsoft.com/azure/sre-agent/create-and-set-up#prerequisites)） |

> [!NOTE]
> PIM（Privileged Identity Management）を使っている場合は、ハンズオン開始前にロールをアクティブ化してください。

## 2. SRE Agent を作成できるリージョンの確認

SRE Agent を作成できるリージョンはサブスクリプションごとに決まります。

1. <https://sre.azure.com> を開いてサインインします。
2. **Create agent** を選び、使うサブスクリプションを選択します。
3. **Region** のドロップダウンを開き、選択肢が表示されることを確認します（ここではまだ作成しません）。

> [!IMPORTANT]
> **Region** が空の場合、そのサブスクリプションは SRE Agent に登録されていません。[登録リクエスト](https://github.com/microsoft/sre-agent/issues/new?labels=registration&title=Subscription+registration+request) を送ってください（[サポートされているリージョン](https://learn.microsoft.com/azure/sre-agent/supported-regions)）。

アプリ（App Service など）と SRE Agent は**別のリージョンでも問題ありません**。Agent は権限を与えたリソースならリージョンをまたいで操作できます。

## 3. ネットワーク

社内プロキシなどを使っている場合は、ブラウザから `*.azuresre.ai`（WebSocket を含む）と `sre.azure.com` に接続できることを確認してください。チャットが応答しないときは、シークレットウィンドウでも試してください（[ネットワーク要件](https://learn.microsoft.com/azure/sre-agent/network-requirements)）。

## 4. GitHub

- GitHub アカウント
- （シナリオ 2 の最後のステップ用・任意）**Copilot coding agent** を使える Copilot プラン。Copilot coding agent を使わない場合でも、Issue の作成までは体験できます。

## 5. ローカルのツール

| ツール | バージョンの目安 | 確認コマンド |
| --- | --- | --- |
| JDK | 21 | `java -version` |
| Azure CLI | 最新 | `az version` |
| Azure Developer CLI (azd) | 最新 | `azd version` |
| Git | 任意 | `git --version` |
| bash または PowerShell 7 | - | スクリプトの実行に使います |

> [!TIP]
> GitHub Codespaces や Azure Cloud Shell など、上記のツールがそろった環境を使ってもかまいません。

## 6. ハンズオン用リポジトリを自分のアカウントに用意する

シナリオ 2 では、SRE Agent が**あなたのリポジトリ**のコードを読み、Issue を作ります。そのため、このリポジトリを自分のアカウントにコピーして使います。

1. このリポジトリの GitHub ページで **Use this template** → **Create a new repository** を選びます。
2. **Include all branches** に**チェックを入れます**（シナリオ 2 で `incident/app-bug` ブランチを使うため）。
3. 公開範囲は Public / Private のどちらでもかまいません。
4. 作成したリポジトリをクローンします。

```bash
git clone https://github.com/<your-account>/<your-repo>.git
cd <your-repo>
git branch -a   # remotes/origin/incident/app-bug が表示されることを確認
```

## 7. コストについて

| リソース | 課金の考え方 |
| --- | --- |
| App Service (B1 または P0v3) / PostgreSQL Flexible Server (B1ms) / Log Analytics / Application Insights | 時間課金・従量課金。ハンズオン後に `azd down` で削除します |
| Azure SRE Agent | **Agent が存在する間ずっと** always-on 課金（4 AAU/時間）が発生します。これに加えて、チャットやインシデント調査、Scheduled Task の実行に応じた active flow 課金がかかります（[価格と課金](https://learn.microsoft.com/azure/sre-agent/pricing-billing)） |

> [!WARNING]
> SRE Agent は**停止しても always-on 課金が続きます**。ハンズオンが終わったら必ず [99. 後片付け](99-cleanup.md) で**削除**してください。初めて使う場合は [評価期間](https://learn.microsoft.com/azure/sre-agent/evaluate)（最初の 30 日は always-on 課金が免除）が適用されることがあります。

---

次へ: [01. アプリのデプロイ](01-deploy.md)
