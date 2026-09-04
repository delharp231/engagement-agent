# run-daily.ps1 - Task Scheduler entry point. Pull -> headless Claude curates -> Gmail SMTP send.
$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "..\config.ps1")
$log = Join-Path $Config.RuntimeDir "run.log"
function Log($m){ ("[" + (Get-Date -Format s) + "] " + $m) | Out-File $log -Append -Encoding utf8 }
Log "=== run start ==="

# Stage 1: deterministic pull
$pullOut = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "pull.ps1")
$pullOut | ForEach-Object { Log ("pull: " + $_) }

# Stage 2: curate + write email files via headless Claude.
# The long-lived token (from: claude setup-token) lets claude -p authenticate unattended. Whitespace is stripped defensively.
$oauth = $env:CLAUDE_CODE_OAUTH_TOKEN
if (-not $oauth) { try { $oauth = (Get-ItemProperty 'HKCU:\Environment' -Name CLAUDE_CODE_OAUTH_TOKEN -ErrorAction Stop).CLAUDE_CODE_OAUTH_TOKEN } catch {} }
if ($oauth) { $env:CLAUDE_CODE_OAUTH_TOKEN = ($oauth -replace '\s','') } else { Log "WARN: CLAUDE_CODE_OAUTH_TOKEN not set - headless auth will fail" }

$today = Join-Path $Config.RuntimeDir "today.json"
$subjF = Join-Path $Config.RuntimeDir "outbox-subject.txt"
$bodyF = Join-Path $Config.RuntimeDir "outbox-body.html"
$brief = Join-Path $PSScriptRoot "curate-prompt.txt"
Remove-Item $subjF,$bodyF -ErrorAction SilentlyContinue

Set-Location $Config.ClaudeCwd
# Short, clean prompt that supplies file paths and points Claude at the full brief (avoids CLI arg truncation).
$shortPrompt = "Read the candidate posts in '$today' and follow the instructions in the file '$brief' exactly. Write the subject line to '$subjF' and the full HTML email body to '$bodyF'. Do not ask questions - complete the task by writing those two files."
$claudeOut = & claude -p $shortPrompt --allowedTools "Read,Write" --output-format text
$claudeOut | ForEach-Object { Log ("claude: " + $_) }

# Stage 3: send the email via Gmail SMTP (a headless run cannot use an interactive Gmail connector).
if ((Test-Path $subjF) -and (Test-Path $bodyF)) {
  $apppw = $env:GMAIL_APP_PASSWORD
  if (-not $apppw) { try { $apppw = (Get-ItemProperty 'HKCU:\Environment' -Name GMAIL_APP_PASSWORD -ErrorAction Stop).GMAIL_APP_PASSWORD } catch {} }
  if ($apppw) {
    $apppw = ($apppw -replace '\s','')
    $subj = (Get-Content $subjF -Raw).Trim()
    $html = Get-Content $bodyF -Raw
    try {
      $sec  = ConvertTo-SecureString $apppw -AsPlainText -Force
      $cred = New-Object System.Management.Automation.PSCredential($Config.EmailFrom,$sec)
      Send-MailMessage -From $Config.EmailFrom -To $Config.EmailTo -Subject $subj -Body $html -BodyAsHtml -SmtpServer $Config.SmtpServer -Port $Config.SmtpPort -UseSsl -Credential $cred -Encoding ([System.Text.Encoding]::UTF8)
      Log "EMAIL_SENT via SMTP"
    } catch { Log ("EMAIL_FAILED SMTP: " + $_.Exception.Message) }
  } else { Log "EMAIL_SKIPPED: GMAIL_APP_PASSWORD not set" }
} else { Log "EMAIL_SKIPPED: Claude did not write the outbox files" }
Log "=== run done ==="
