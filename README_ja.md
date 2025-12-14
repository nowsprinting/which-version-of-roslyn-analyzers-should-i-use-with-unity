# UnityでどのバージョンのRoslynアナライザーを使えばいい？

このリポジトリは、Roslynアナライザーと各Unityバージョンとの互換性情報を提供します。

Unityは特定のバージョンのMicrosoft.CodeAnalysis.CSharpを使用しているため、すべてのアナライザーバージョンがすべてのUnityバージョンで動作するわけではありません。このリポジトリは、Unityプロジェクトに適したアナライザーバージョンを見つけるのに役立ちます。

## サポートされているUnityバージョン

| Unityバージョン | Microsoft.CodeAnalysis.CSharp |
|----------------|-------------------------------|
| Unity 2020.2   | 3.5                           |
| Unity 2021.2   | 3.8                           |
| Unity 2022.1   | 3.11                          |
| Unity 6000.0   | 4.3                           |

注: 新しいバージョンのMicrosoft.CodeAnalysis.CSharpはLTSリリースにバックポートされることがあります。例えば、Microsoft.CodeAnalysis.CSharp v4.3はUnity 2022.3.12f1以降で利用可能です。

## アナライザーの互換性

特定のアナライザーの互換性情報については、このリポジトリ内のMarkdownファイルを確認してください。

<!-- アナライザーファイルが作成されたらここにリンクを追加 -->

## コントリビュート

新しいアナライザーを追加したい、またはバージョン情報を更新したい場合：

1. **このリポジトリをフォーク**
2. フォークした自分のリポジトリで**ワークフローを実行**:
   - Actions > "Check Roslyn Analyzer Versions" を開く
   - "Run workflow" をクリック
   - アナライザーのGitHubリポジトリURL（例: `https://github.com/dotnet/roslynator`）を入力
3. ワークフローがフォーク内にPull Requestを作成します。送信時に**baseリポジトリをこのフォーク元リポジトリに変更**してください。
