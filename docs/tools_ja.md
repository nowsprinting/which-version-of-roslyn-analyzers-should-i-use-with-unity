# ツール設計ドキュメント

## check-unity-roslyn-version.ps1

### 概要

Unity各バージョンに内包されている Microsoft.CodeAnalysis.CSharp のアセンブリバージョンを調べるPowerShellスクリプト。

### 目的

Roslynアナライザーの互換性を判断するために、特定のUnityバージョンがどのバージョンのRoslynを使用しているかを確認する。

### 使用方法

```bash
pwsh tools/check-unity-roslyn-version.ps1 <UnityVersion>
```

#### 引数

| 引数 | 必須 | 説明 |
|------|------|------|
| UnityVersion | Yes | Unityバージョン（例: `6000.0.31f1`, `2022.3.10f1`） |

#### 使用例

```bash
# Unity 6
pwsh tools/check-unity-roslyn-version.ps1 6000.0.31f1

# Unity 2022 LTS
pwsh tools/check-unity-roslyn-version.ps1 2022.3.10f1
```

### 前提条件

- PowerShell (pwsh) がインストールされていること
- Docker がインストールされ、実行可能な状態であること
- インターネット接続（Docker Hubからイメージをpullするため）

### 処理フロー

```
1. 引数バリデーション
   ├─ 引数がない場合 → エラー終了
   └─ フォーマット不正の場合 → エラー終了

2. Dockerイメージ取得
   └─ unityci/editor:{version}-base-{GameCiVersion} をpull

3. コンテナ作成
   └─ docker create で一時コンテナを作成

4. DLL検索
   └─ /opt/unity 配下の Microsoft.CodeAnalysis.CSharp.dll を検索

5. バージョン取得
   ├─ docker cp でDLLをホストにコピー
   └─ [System.Reflection.AssemblyName] でアセンブリバージョンを取得

6. 結果出力
   └─ 見つかったDLLのパスとバージョンをコンソールに出力

7. クリーンアップ
   ├─ 一時ディレクトリ削除
   └─ Dockerコンテナ削除
```

### バージョンフォーマット

以下の形式をサポート:

| 形式 | 正規表現パターン | 例 |
|------|------------------|-----|
| 旧形式 | `20[2-9]\d\.\d+\.\d+f\d+` | `2020.3.10f1`, `2022.3.10f1` |
| 新形式 | `6\d{3}\.\d+\.\d+f\d+` | `6000.0.31f1` |

### Dockerイメージ

[GameCI](https://game.ci/) が提供するUnity Editorイメージを使用。

- レジストリ: Docker Hub
- イメージ名: `unityci/editor`
- タグ形式: `{UnityVersion}-base-{GameCiVersion}`
- 例: `unityci/editor:6000.0.31f1-base-3`

GameCIバージョンはスクリプト内にハードコードされている（現在: `3`）。

### 出力例

```
Unity Version: 6000.0.31f1
Docker Image: unityci/editor:6000.0.31f1-base-3

Pulling Docker image...
Creating container...
Searching for Microsoft.CodeAnalysis.CSharp.dll...

Found DLLs:
===========
/opt/unity/Editor/Data/DotNetSdkRoslyn/Microsoft.CodeAnalysis.CSharp.dll
  Assembly Version: 4.9.0.0

Cleaning up...
Done!
```

### エラーハンドリング

| エラー | 原因 | 対処 |
|--------|------|------|
| Unity version is required | 引数未指定 | Unityバージョンを指定する |
| Invalid Unity version format | フォーマット不正 | 正しい形式で指定する（例: `2022.3.10f1`） |
| Failed to pull Docker image | イメージが存在しない | Unityバージョンが正しいか、GameCIでサポートされているか確認 |
| No Microsoft.CodeAnalysis.CSharp.dll found | DLLが見つからない | 古いUnityバージョンではRoslynが含まれていない可能性あり |

### 技術的詳細

#### アセンブリバージョン取得方法

```powershell
$assemblyName = [System.Reflection.AssemblyName]::GetAssemblyName($dllPath)
$version = $assemblyName.Version.ToString()
```

.NETの `System.Reflection.AssemblyName` クラスを使用して、DLLファイルからアセンブリバージョンを直接取得する。

#### Unityインストールパス

GameCIのDockerイメージでは、Unityは `/opt/unity` にインストールされる。
