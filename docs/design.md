# Which version of Roslyn analyzers should I use with Unity?

このリポジトリは、NuGet Galleryで公開されているRoslynアナライザーの使用しているMicrosoft.CodeAnalysis.CSharpを調査し、どのバージョンがUnityでも利用可能かを提供します。

構成は2つ。

1. リポジトリ直下にアナライザごとのMarkdown形式ファイルを置き、どのバージョンがUnityでも利用可能かを記載します
2. GitHub Actionsによって指定されたNuGetパッケージの各バージョンで使用している Microsoft.CodeAnalysis.CSharp のバージョンを取得し、1.のMarkdown形式ファイルを更新するPull Requestを作成するワークフロー

## Markdown書式

次の内容を記載します。

1. アナライザの名称
2. Unityの各バージョンで利用できるアナライザバージョンの表（各バージョンはNuGetへのリンク）

Unityの各バージョンで利用できる Microsoft.CodeAnalysis.Csharp バージョンは次のとおりです。

* Unity 2020.2: Microsoft.CodeAnalysis.Csharp v3.5
* Unity 2021.2: v3.8
* Unity 2022.1: v3.11
* Unity 6000.0: v4.3

Note: Newer versions of Microsoft.CodeAnalysis.CSharp may be backported to LTS releases. For example, Microsoft.CodeAnalysis.CSharp v4.3 is available in Unity 2022.3.12f1 and later.

### Markdownファイルフォーマット例

```markdown
# {アナライザ名}

| Version | Microsoft.CodeAnalysis.CSharp | Unity 2020.2 | Unity 2021.2 | Unity 2022.1 | Unity 6000.0 |
|---------|-------------------------------|--------------|--------------|--------------|--------------|
| x.x.x   | x.x.x.x                       | ✅ / ❌      | ✅ / ❌      | ✅ / ❌      | ✅ / ❌      |
```

バージョン番号はNuGet Galleryへのハイパーリンク

## GitHub Actionsワークフロー

ワークフロー check-analyzers.yml は、次の手順で動作します。

### inputs

| 名前 | 必須 | 説明 |
|------|------|------|
| nuget_package_id | Yes | NuGetパッケージID（例: `IDisposableAnalyzers`） |

### 処理フロー

1. on.workflow_dispatch で手動実行されます
2. NuGet API を使用して、指定されたパッケージの全バージョン一覧を取得します
   - `https://api.nuget.org/v3-flatcontainer/{package-id}/index.json`
   - semverにハイフンを含むバージョン（プレリリース版など）は除外します
3. 各バージョンに対して次の処理を行います
   1. .nupkg ファイルをダウンロードします
      - `https://api.nuget.org/v3-flatcontainer/{package-id}/{version}/{package-id}.{version}.nupkg`
   2. .nupkg を展開します
   3. analyzers/ ディレクトリ内の .dll ファイルを検索します
   4. PowerShell で `[System.Reflection.Assembly]::LoadFile()` を使用し、Microsoft.CodeAnalysis.CSharp の参照バージョンを取得します
4. すべてのバージョンの処理が終わったら、パッケージIDと同じMarkdown形式ファイルをリポジトリ直下に作成または更新します
5. 変更を新しいブランチにコミットし、Pull Requestを作成します

### 補足

- Microsoft.CodeAnalysis.CSharp を参照していない .dll はスキップ
- NuGet URLは `https://www.nuget.org/packages/{PackageId}` として自動生成
