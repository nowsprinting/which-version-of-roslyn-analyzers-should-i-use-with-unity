# 全アナライザ一括更新チェック ワークフロー仕様

このドキュメントでは、リポジトリ内のすべてのアナライザを自動でチェックし、更新があれば各アナライザのバージョン情報を更新するGitHub Actionsワークフローの仕様を定義します。

## 概要

リポジトリルートに配置されたアナライザ用Markdownファイル（`{PackageId}.md`）を走査し、NuGet上の最新バージョンと比較して、更新が必要なアナライザのみ `check-analyzers.yml` を実行して情報を更新します。

## 実行契機

| トリガー                | 説明                                             |
|---------------------|------------------------------------------------|
| `workflow_dispatch` | 手動実行                                           |
| `schedule`          | cron式: `0 20 * * 0`（UTC日曜20:00 = 日本時間月曜5:00AM） |

## 処理フロー

### Job 1: check-updates

更新が必要なアナライザを特定するジョブです。

#### 出力

| 名前       | 型    | 説明                                                                      |
|----------|------|-------------------------------------------------------------------------|
| `matrix` | JSON | 更新が必要なアナライザIDの配列（例: `["Microsoft.Unity.Analyzers", "NUnit.Analyzers"]`） |

#### 処理ステップ

1. **リポジトリのチェックアウト**

2. **アナライザファイル一覧の取得**
   - リポジトリルートにある `*.md` ファイルを列挙
   - `README.md` を除外
   - ファイル名から拡張子を除いたものがNuGetパッケージID

3. **各アナライザの最新バージョン確認**（ループ処理）

   各ファイルに対して以下を実行:

   a. **ローカルの最新バージョン取得**
      - Markdownファイル内のテーブルから先頭行（最新バージョン）を取得
      - 正規表現例: `^\| \[([0-9.]+)\]` でバージョン番号を抽出

   b. **NuGet上の最新バージョン取得**
      - NuGet Registration API を使用
      - URL: `https://api.nuget.org/v3/registration5-gz-semver2/{package-id-lower}/index.json`
      - 条件:
        - `listed: true`（公開されているもの）
        - バージョン文字列にハイフン `-` を含まない（プレリリース版を除外）
      - 条件を満たすバージョンの中から最新を取得

   c. **バージョン比較**
      - ローカルとNuGetの最新バージョンが異なる場合、そのパッケージIDを記録

4. **結果の出力**
   - 更新が必要なアナライザのパッケージIDをJSON配列形式で `$GITHUB_OUTPUT` に出力（後続ジョブで参照するため）

### Job 2: update-analyzers

更新が必要なアナライザごとに `check-analyzers.yml` を実行するジョブです。

#### 条件

- `needs.check-updates.outputs.matrix != '[]'` の場合のみ実行（更新対象がある場合）

#### 設定

```yaml
strategy:
  fail-fast: false
  matrix:
    nuget_package_id: ${{ fromJson(needs.check-updates.outputs.matrix) }}
```

#### 実行

- Reusable workflow として `check-analyzers.yml` を呼び出し
- 各アナライザに対して並列で実行

## check-analyzers.yml への変更

既存の `check-analyzers.yml` に `workflow_call` トリガーを追加します。

### 追加するトリガー

```yaml
on:
  workflow_dispatch:
    inputs:
      nuget_package_id:
        description: 'NuGet package ID (e.g., Microsoft.Unity.Analyzers)'
        required: true
        type: string
  workflow_call:  # 追加
    inputs:
      nuget_package_id:
        description: 'NuGet package ID (e.g., Microsoft.Unity.Analyzers)'
        required: true
        type: string
```

## ワークフローファイル構成

```
.github/workflows/
├── check-analyzers.yml          # 既存（workflow_call追加）
└── check-all-analyzers.yml      # 新規作成
```

## エラーハンドリング

- 個別のアナライザ更新が失敗しても、他のアナライザの更新処理は継続（`fail-fast: false`）
- NuGet APIへのアクセス失敗時はそのアナライザをスキップ
- Markdownファイルのパースに失敗した場合はそのアナライザをスキップ

## 権限

```yaml
permissions:
  contents: write
  pull-requests: write
```

## 参考

- [NuGet Registration API](https://docs.microsoft.com/en-us/nuget/api/registration-base-url-resource)
- [GitHub Actions - Reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
