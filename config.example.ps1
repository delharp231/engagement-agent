# config.example.ps1  --  Copy to config.ps1 and fill in. config.ps1 is git-ignored; never commit it.
#
# Secrets are NOT stored here. Set these as user environment variables (setx "NAME" "value"):
#   APIFY_TOKEN              - from https://console.apify.com  (Settings > API & Integrations)
#   CLAUDE_CODE_OAUTH_TOKEN  - run:  claude setup-token
#   GMAIL_APP_PASSWORD       - Google Account > Security > App passwords (requires 2-Step Verification)

$Config = @{
  # Folder where runtime files are written (today.json, outbox, run.log). Keep this OUTSIDE the repo:
  RuntimeDir = "C:\path\to\linkedin-agent-runtime"
  # Working directory for the headless Claude run (any dir where your Claude Code install is valid):
  ClaudeCwd  = "C:\path\to\a-claude-project-dir"

  EmailTo    = "you@example.com"          # where the digest is sent
  EmailFrom  = "you@gmail.com"            # the Gmail account the app password belongs to
  SmtpServer = "smtp.gmail.com"
  SmtpPort   = 587

  DatePosted = "week"                     # freshness window: 24h | week | month
  MaxResults = 10                         # posts per query; ~5 queries x 10 = ~50 = ~$0.28/run

  # Your two lanes and the keyword phrase to search for each. Rename the lanes and edit freely.
  Queries = @(
    @{ lane = "career";  kw = "your first career-lane keyword phrase" },
    @{ lane = "career";  kw = "another career-lane phrase" },
    @{ lane = "bizdev";  kw = "your first bizdev-lane phrase" },
    @{ lane = "bizdev";  kw = "another bizdev-lane phrase" },
    @{ lane = "bizdev";  kw = "a third bizdev-lane phrase" }
  )
  # How many picks from each lane in the final email:
  LaneTargets = @{ career = 2; bizdev = 3 }

  # Schedule (used by register-task.ps1):
  Days = @("Tuesday","Wednesday","Thursday")
  Time = "08:00"
}
