# Which version of Roslyn analyzers should I use with Unity?

This repository provides compatibility information for Roslyn analyzers with different Unity versions.

Unity uses specific versions of Microsoft.CodeAnalysis.CSharp, which means not all analyzer versions work with all Unity versions. This repository helps you find the right analyzer version for your Unity project.

## Supported Unity Versions

| Unity Version | Microsoft.CodeAnalysis.CSharp |
|---------------|-------------------------------|
| Unity 2020.2  | 3.5                           |
| Unity 2021.2  | 3.8                           |
| Unity 2022.1  | 3.11                          |
| Unity 6000.0  | 4.3                           |

Note: Newer versions of Microsoft.CodeAnalysis.CSharp may be backported to LTS releases. For example, Microsoft.CodeAnalysis.CSharp v4.3 is available in Unity 2022.3.12f1 and later.

## Analyzer Compatibility

Check the markdown files in this repository for compatibility information on specific analyzers:

<!-- Add links to analyzer files here as they are created -->

## Contributing

Want to add a new analyzer or update version information?

1. **Fork this repository**
2. **Run the workflow** in your fork:
   - Go to Actions > "Check Roslyn Analyzer Versions"
   - Click "Run workflow"
   - Enter the GitHub repository URL of the analyzer (e.g., `https://github.com/dotnet/roslynator`)
3. The workflow will create a Pull Request in your fork. **Change the base repository** to this upstream repository when submitting.
