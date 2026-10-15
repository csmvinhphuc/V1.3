# Distribution kit for V1.3.exe

Safer GitHub release flow than irm | iex.

Users should download release asset, verify SHA256, then run only after verification.

Expected checksum: see SHA256SUMS.txt

Local verification:
Get-FileHash -Algorithm SHA256 .\V1.3.exe

GitHub release steps:
1. Create repository csmvinhphuc/V1.3
2. Create release tag v1.3
3. Upload V1.3.exe as asset
4. Include SHA256SUMS.txt in release
5. Share install script only if user verifies hash first

Do not distribute as irm url | iex without hash verification.