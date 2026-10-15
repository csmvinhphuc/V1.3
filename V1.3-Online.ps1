#Requires -Version 3.0
<#
.SYNOPSIS
  V1.3 Online Launcher - chay truc tiep tu GitHub:
    irm https://raw.githubusercontent.com/csmvinhphuc/V1.3/main/V1.3-Online.ps1 | iex
  Vi du:
    irm https://raw.githubusercontent.com/csmvinhphuc/V1.3/main/V1.3-Online.ps1 | iex
    & ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/csmvinhphuc/V1.3/main/V1.3-Online.ps1))) -Version v1.3 -NoRun
#>
param(
  [string]$Version = 'latest',   # 'latest' hoac tag cu the, vd: 'v1.3'
  [string]$ExePath = '',         # dung file exe co san (de test offline)
  [string]$Dir = '',             # thu muc tai ve (mac dinh %TEMP%\V1.3)
  [switch]$NoRun                 # chi tai + verify, khong chay exe
)

# ================= CAU HINH =================
$Repo           = 'csmvinhphuc/V1.3'
$Asset          = 'V1.3.exe'
$ExpectedSha256 = '5677AD307CDFB797295BC25D1B1F09E6E73905574B1AE11FCF841BEBF0776D6A'
# ============================================

$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

if (!$Dir) { $Dir = Join-Path $env:TEMP 'V1.3' }
New-Item -ItemType Directory -Force -Path $Dir | Out-Null
$dest = Join-Path $Dir $Asset

# --- Lay file exe ---
if ($ExePath -and (Test-Path $ExePath)) {
  Write-Host ('Dung file co san: ' + $ExePath)
  Copy-Item $ExePath $dest -Force
} else {
  if ($Version -eq 'latest') {
    $url = 'https://github.com/' + $Repo + '/releases/latest/download/' + $Asset
  } else {
    $url = 'https://github.com/' + $Repo + '/releases/download/' + $Version + '/' + $Asset
  }
  Write-Host ('Dang tai: ' + $url)
  try {
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
  } catch {
    Write-Host 'Link truc tiep loi, thu qua GitHub API...' -ForegroundColor Yellow
    if ($Version -eq 'latest') { $api = 'https://api.github.com/repos/' + $Repo + '/releases/latest' }
    else { $api = 'https://api.github.com/repos/' + $Repo + '/releases/tags/' + $Version }
    $rel = Invoke-RestMethod -Uri $api -TimeoutSec 30
    $a = @($rel.assets | Where-Object { $_.name -eq $Asset })
    if ($a.Count -eq 0) { throw ('Khong thay asset ' + $Asset + ' trong release. Hay Publish Release (khong phai Draft) va dinh kem dung ten file.') }
    Invoke-WebRequest -Uri $a[0].browser_download_url -OutFile $dest -UseBasicParsing
  }
  Write-Host ('Da tai xong (' + ((Get-Item $dest).Length / 1KB).ToString('0') + ' KB)')
}

if (!(Test-Path $dest)) { throw 'Tai that bai: khong co file exe.' }

# --- Verify SHA256 bat buoc truoc khi chay ---
$actual = (Get-FileHash -Algorithm SHA256 -Path $dest).Hash
if ($actual -ne $ExpectedSha256.ToUpperInvariant()) {
  Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
  throw ('SHA256 khong khop! Expected ' + $ExpectedSha256 + ', got ' + $actual + '. Da xoa file de an toan.')
}
Write-Host ('Verify OK: ' + $actual) -ForegroundColor Green

if ($NoRun) { Write-Host ('Xong (NoRun). File o: ' + $dest); return $dest }
Write-Host ('Dang chay: ' + $dest) -ForegroundColor Green
Start-Process -FilePath $dest
return $dest
