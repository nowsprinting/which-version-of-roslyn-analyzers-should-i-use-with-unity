#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Check Microsoft.CodeAnalysis.CSharp version bundled in Unity Editor.

.DESCRIPTION
    This script pulls a Unity Editor Docker image from GameCI and finds
    all Microsoft.CodeAnalysis.CSharp.dll files, then outputs their assembly versions.

.PARAMETER UnityVersion
    Unity version (e.g., 6000.2.10f1 or 2022.3.10f1)

.EXAMPLE
    ./check-unity-roslyn-version.ps1 6000.0.31f1
#>

param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$UnityVersion
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# GameCI image version (hardcoded)
$GameCiVersion = "3"

# Validate argument exists
if (-not $UnityVersion) {
    Write-Error "Unity version is required. Usage: ./check-unity-roslyn-version.ps1 <UnityVersion>"
    exit 1
}

# Validate version format (both old and new formats)
# Old: 2020.3.10f1, 2021.3.10f1, 2022.3.10f1, 2023.1.10f1
# New: 6000.0.10f1
if ($UnityVersion -notmatch '^(20[2-9]\d\.\d+\.\d+f\d+|6\d{3}\.\d+\.\d+f\d+)$') {
    Write-Error "Invalid Unity version format. Expected: 2022.3.10f1 or 6000.0.10f1"
    exit 1
}

$imageName = "unityci/editor:$UnityVersion-base-$GameCiVersion"
$containerName = "unity-roslyn-check-$((Get-Random))"

Write-Host "Unity Version: $UnityVersion"
Write-Host "Docker Image: $imageName"
Write-Host ""

# Pull Docker image
Write-Host "Pulling Docker image..."
docker pull $imageName
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to pull Docker image: $imageName"
    exit 1
}

# Create container (not started)
Write-Host "Creating container..."
docker create --name $containerName $imageName | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create container"
    exit 1
}

try {
    # Find Microsoft.CodeAnalysis.CSharp.dll in the container
    Write-Host "Searching for Microsoft.CodeAnalysis.CSharp.dll..."
    $dllPaths = docker run --rm $imageName find /opt/unity -name "Microsoft.CodeAnalysis.CSharp.dll" 2>$null

    if (-not $dllPaths) {
        Write-Warning "No Microsoft.CodeAnalysis.CSharp.dll found in the Unity installation."
        exit 0
    }

    # Create temp directory
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "unity-roslyn-check-$((Get-Random))"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        Write-Host ""
        Write-Host "Found DLLs:"
        Write-Host "==========="

        $dllPathArray = $dllPaths -split "`n" | Where-Object { $_ -ne "" }

        foreach ($dllPath in $dllPathArray) {
            $dllPath = $dllPath.Trim()
            if (-not $dllPath) { continue }

            # Copy DLL from container to host
            $fileName = Split-Path $dllPath -Leaf
            $localPath = Join-Path $tempDir "$((Get-Random))-$fileName"

            docker cp "${containerName}:${dllPath}" $localPath 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to copy: $dllPath"
                continue
            }

            # Get assembly version
            try {
                $assemblyName = [System.Reflection.AssemblyName]::GetAssemblyName($localPath)
                $version = $assemblyName.Version.ToString()
                Write-Host "$dllPath"
                Write-Host "  Assembly Version: $version"
                Write-Host ""
            }
            catch {
                Write-Warning "Failed to read assembly version: $dllPath"
            }
        }
    }
    finally {
        # Cleanup temp directory
        if (Test-Path $tempDir) {
            Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
        }
    }
}
finally {
    # Cleanup container
    Write-Host "Cleaning up..."
    docker rm $containerName 2>$null | Out-Null
}

Write-Host "Done!"
