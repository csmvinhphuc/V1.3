param(
    [string]$Repo = 'csmvinhphuc/V1.3',
    [string]$Tag = 'v1.3',
    [string]$Asset = 'V1.3.exe',
    [string]$ExpectedSha256 = '5677AD307CDFB797295BC25D1B1F09E6E73905574B1AE11FCF841BEBF0776D6A',
    [switch]$Run
)

$ErrorActionPreference = 'Stop'

if ($Repo -notmatch '^[^/]+/[^/]+$') {
    throw "Repo must be in the form owner/name."
}

$url = "https://github.com/$Repo/releases/download/$Tag/$Asset"
$tempFile = Join-Path $env:TEMP $Asset

Write-Host "Downloading $Asset from $url"
Invoke-WebRequest -Uri $url -OutFile $tempFile -UseBasicParsing

$actualHash = (Get-FileHash -Algorithm SHA256 -Path $tempFile).Hash
if ($actualHash -ne $ExpectedSha256.ToUpperInvariant()) {
    Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
    throw "SHA256 mismatch. Expected $ExpectedSha256, got $actualHash."
}

Write-Host "Verified SHA256: $actualHash"
Write-Host "Saved to: $tempFile"

if ($Run) {
    Write-Host "Starting $Asset..."
    Start-Process -FilePath $tempFile -Wait
} else {
    Write-Host "Run it manually if you trust this file."
}