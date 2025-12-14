# Which version of Roslyn analyzers should I use with Unity?

このリポジトリは、GitHubで公開されているRoslynアナライザーの使用しているMicrosoft.CodeAnalysis.CSharpを調査し、どのバージョンがUnityでも利用可能かを提供します。

構成は2つ。

1. リポジトリ直下にアナライザごとのMarkdown形式ファイルを置き、どのバージョンがUnityでも利用可能かを記載します
2. GitHub Actionsによって指定されたアナライザのリポジトリから各バージョンで使用している Microsoft.CodeAnalysis.CSharp のバージョンを取得し、1.のMarkdown形式ファイルを更新するPull Requestを作成するワークフロー

## Markdown書式

次の内容を記載します。

1. アナライザの名称
2. NuGet GalleryのURL
3. GitHubリポジトリのURL
4. Unityの各バージョンで利用できるアナライザバージョンの表

Unityの各バージョンで利用できる Microsoft.CodeAnalysis.Csharp バージョンは次のとおりです。

* Unity 2020.2: Microsoft.CodeAnalysis.Csharp v3.5
* Unity 2021.2: v3.8
* Unity 2022.1: v3.11
* Unity 6000.0: v4.3

Note: Newer versions of Microsoft.CodeAnalysis.CSharp may be backported to LTS releases. For example, Microsoft.CodeAnalysis.CSharp v4.3 is available in Unity 2022.3.12f1 and later.

### Markdownファイルフォーマット例

```markdown
# {アナライザ名}

- NuGet: {NuGet GalleryのURL}
- GitHub: {GitHubリポジトリのURL}

## {アセンブリ名}（複数ある場合のみ）

| Version | Microsoft.CodeAnalysis.CSharp | Unity 2020.2 | Unity 2021.2 | Unity 2022.1 | Unity 6000.0 |
|---------|-------------------------------|--------------|--------------|--------------|--------------|
| x.x.x   | x.x.x                         | ✅ / ❌      | ✅ / ❌      | ✅ / ❌      | ✅ / ❌      |
```

※ アセンブリが1つの場合は `## アセンブリ名` は省略

## GitHub Actionsワークフロー

ワークフロー check-analyzers.yml は、次の手順で動作します。

### inputs

| 名前 | 必須 | 説明 |
|------|------|------|
| github_url | Yes | RoslynアナライザーのGitHubリポジトリURL（例: `https://github.com/dotnet/roslynator`） |

### 処理フロー

1. on.workflow_dispatch で手動実行されます
2. 指定されたリポジトリをクローンします。depthは全コミットを取得
3. Gitのタグ一覧を取得し、セマンティックバージョン形式（`v1.0.0`、`1.0.0`、`release-1.0.0` など）のタグをフィルタリング
4. 各タグに対して次の処理を行います
   1. タグをチェックアウトします
   2. `Microsoft.CodeAnalysis.CSharp` を参照している .csproj ファイルを検索
   3. 見つかった各 .csproj から:
      - パッケージのバージョン番号を取得（`<Version>` または `<PackageVersion>`）
      - `Microsoft.CodeAnalysis.CSharp` のバージョンを取得（`<PackageReference>`）
5. すべてのタグの処理が終わったら、リポジトリ名と同じMarkdown形式ファイルをリポジトリ直下に作成または更新します
6. 変更を新しいブランチにコミットし、Pull Requestを作成します

### 補足

- Microsoft.CodeAnalysis.CSharp を参照していない .csproj はスキップ
- 複数の .csproj が該当する場合、それぞれ別の表として出力（`## アセンブリ名` で区切る）
- バージョン番号は .csproj 内の値を使用（タグ名ではない）
- NuGet URLは .csproj の `<PackageId>` から自動生成（`https://www.nuget.org/packages/{PackageId}`）