# Which version of Roslyn analyzers should I use with Unity?

This repository provides compatibility information for Roslyn analyzers and source generators with different Unity versions.

Unity uses specific versions of Microsoft.CodeAnalysis.CSharp, which means not all analyzer versions work with all Unity versions. This repository helps you find the right analyzer version for your Unity project.

## Supported Unity Versions

| Unity Version     | Microsoft.CodeAnalysis.CSharp version                                                                                                              |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| Unity 6000.0      | 4.3 (stated in [Manual: Create and use a source generator](https://docs.unity3d.com/6000.0/Documentation/Manual/create-source-generator.html))     |
| Unity 2022.3.12f1 | 4.3 (backported)                                                                                                                                   |
| Unity 2022.2      | 4.1                                                                                                                                                |
| Unity 2021.2      | 3.9 (stated "3.8" in [Manual: Roslyn analyzers and source generators](https://docs.unity3d.com/2021.2/Documentation/Manual/roslyn-analyzers.html)) |
| Unity 2020.2      | 3.5                                                                                                                                                |

Note: Newer versions of Microsoft.CodeAnalysis.CSharp may be backported to LTS releases. For example, Microsoft.CodeAnalysis.CSharp v4.3 is available in Unity 2022.3.12f1 and later.

## Analyzer Compatibility

Check the markdown files in this repository for compatibility information on specific analyzers:

<!-- Add links to analyzer files here as they are created -->
- [IDisposableAnalyzers](IDisposableAnalyzers.md)
- [Microsoft.CodeAnalysis.BannedApiAnalyzers](Microsoft.CodeAnalysis.BannedApiAnalyzers.md)
- [Microsoft.Unity.Analyzers](Microsoft.Unity.Analyzers.md)
- [NSubstitute.Analyzers.CSharp](NSubstitute.Analyzers.CSharp.md)
- [NUnit.Analyzers](NUnit.Analyzers.md)
- [Roslynator.Analyzers](Roslynator.Analyzers.md)

## Want to use an analyzer not listed here?

You can add a new analyzer or update version information by following these steps:

1. **Fork this repository**
2. **Run the workflow** in your fork:
   - Go to **Actions > Check Roslyn Analyzer Versions**
   - Click **Run workflow**
   - Enter the NuGet package ID (e.g., `Microsoft.Unity.Analyzers`)
   - Click **Run workflow**
3. The workflow will push a branch and display a URL. Click the URL to create a Pull Request to this upstream repository.
