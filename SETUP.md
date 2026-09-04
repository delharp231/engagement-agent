# Setup (~15 minutes)

Prerequisites: Windows, PowerShell, and [Claude Code](https://claude.com/claude-code) installed and signed in.

## 1. Get the three credentials

Each is stored as a user environment variable — never in the repo.

**Apify token** (the post-search API)
1. Sign up free at [console.apify.com](https://console.apify.com) (no card).
2. Copy your token from **Settings → API & Integrations**.
3. `setx APIFY_TOKEN "paste-token"`

**Claude token** (lets the scheduled run authenticate headlessly)
1. In a terminal: `claude setup-token` → authorize in the browser → copy the token it prints.
2. `setx CLAUDE_CODE_OAUTH_TOKEN "paste-token"`  *(paste carefully — a stray space breaks it; the script also strips whitespace defensively)*

**Gmail app password** (to send the email)
1. Enable 2-Step Verification on the Google account, then create an app password at [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords).
2. `setx GMAIL_APP_PASSWORD "the 16-char password"`  *(spaces are fine)*

> `setx` only affects **new** processes — open a fresh terminal (or reboot) after setting these. The scripts also read them straight from the registry as a fallback.

## 2. Configure

1. Copy `config.example.ps1` to `config.ps1` (git-ignored).
2. Fill in `RuntimeDir`, `ClaudeCwd`, `EmailTo`, `EmailFrom`, and your `Queries` / `LaneTargets`.
3. Edit the **"WHO THIS IS FOR"** section at the top of `scripts/curate-prompt.txt` to describe the person and their two lanes.

## 3. Test once, then schedule

Run a single pass by hand to confirm an email lands:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-daily.ps1
```

Check `RuntimeDir\run.log` — you want to see `PULL_OK`, `EMAIL_WRITTEN`, then `EMAIL_SENT via SMTP`. Once that works:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\register-task.ps1
```

That registers the scheduled task (defaults to Tue/Wed/Thu 08:00, catching up if the machine was off).

## Cost control

Each run is ~$0.28 (about 50 posts at the actor's per-result price). Three runs/week keeps you near ~$3.60/month, inside Apify's $5 free tier. To spend less, lower `MaxResults` or run fewer days.

## If it ever stops emailing

Read `RuntimeDir\run.log`. The usual cause is the Claude token expiring — re-run `claude setup-token` and reset `CLAUDE_CODE_OAUTH_TOKEN`. No stale email is ever re-sent (the outbox is cleared before each run).
