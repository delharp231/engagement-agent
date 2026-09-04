# pull.ps1 - Stage 1: fetch fresh LinkedIn posts via the Apify no-login actor, pre-filter, write today.json
$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "..\config.ps1")

$tok = $env:APIFY_TOKEN
if (-not $tok) { try { $tok = (Get-ItemProperty 'HKCU:\Environment' -Name APIFY_TOKEN -ErrorAction Stop).APIFY_TOKEN } catch {} }
if (-not $tok) { Write-Output "PULL_FAIL: APIFY_TOKEN not set"; exit 1 }

$h = @{ Authorization = "Bearer $tok"; "Content-Type" = "application/json" }
$uri = "https://api.apify.com/v2/acts/unseenuser~linkedin-post-seach-scraper/run-sync-get-dataset-items"

# recruiter / job / event-blast noise that keyword search drags in
$block = @('hiring','job description','apply now','we are looking for','bench sales',' c2c',' c2h','walk-in','job title','immediate hiring','send me your','open position','we are hiring','resume to')

$cand = @()
foreach ($q in $Config.Queries) {
  $body = @{ mode="search"; searchKeywords=$q.kw; datePosted=$Config.DatePosted; sortBy="date"; maxResults=$Config.MaxResults } | ConvertTo-Json
  try { $items = Invoke-RestMethod -Uri $uri -Headers $h -Method POST -Body $body -TimeoutSec 240 }
  catch { Write-Output ("query failed: " + $q.kw + " -> " + $_.Exception.Message); continue }
  foreach ($it in @($items)) {
    $txt = ($it.content -replace "\s+"," ").Trim()
    if ($txt.Length -lt 200) { continue }
    $low = $txt.ToLower(); $spam = $false
    foreach ($b in $block) { if ($low.Contains($b)) { $spam = $true; break } }
    if ($spam) { continue }
    $cand += [pscustomobject]@{
      lane=$q.lane; url=$it.linkedinUrl; author=$it.author.name; authorType=$it.author.type
      ago=$it.postedAt.postedAgoShort; postedAt=$it.postedAt.date
      likes=$it.engagement.likes; comments=$it.engagement.comments; text=$txt
    }
  }
}
$cand = $cand | Sort-Object url -Unique
if (-not (Test-Path $Config.RuntimeDir)) { New-Item -ItemType Directory -Force -Path $Config.RuntimeDir | Out-Null }
$cand | ConvertTo-Json -Depth 6 | Out-File -FilePath (Join-Path $Config.RuntimeDir "today.json") -Encoding utf8
Write-Output ("PULL_OK candidates=" + $cand.Count)
