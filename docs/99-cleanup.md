# 99. 後片付け

> [!WARNING]
> SRE Agent は**停止しても課金が続きます**（always-on 課金）。課金を止めるには Agent を**削除**する必要があります。

## 1. スクリプトを止める

`traffic` / `leak` スクリプトを動かしているターミナルで **Ctrl+C** を押します。

## 2. SRE Agent を削除する

1. <https://sre.azure.com> で Agent を開きます。
2. **Settings** → **General** から Agent を削除します。
3. Azure ポータルで、Agent 用に作ったリソース グループ `rg-sre-agent-handson` も削除します（Agent 用の Application Insights などが残っている場合があるため）。

```bash
az group delete --name rg-sre-agent-handson --yes --no-wait
```

## 3. アプリ環境を削除する

```bash
azd down --purge --force
```

`rg-<環境名>` と、その中のリソースがすべて削除されます。

## 4. GitHub（任意）

- 作成したリポジトリが不要なら削除します。
- SRE Agent の GitHub 接続に OAuth を使った場合は、GitHub の **Settings** → **Applications** → **Authorized OAuth Apps** から、必要に応じてアクセスを取り消します（PAT を使った場合は PAT を削除します）。

お疲れさまでした！ほかのシナリオのアイデアは [future-scenarios.md](future-scenarios.md) を参照してください。
