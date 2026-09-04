# Recreate this for your own topics

The agent is config-driven, so you don't have to write any code — you just supply your topics and three free credentials. The fastest path is to hand the prompt below to **Claude Code** (running on your Windows machine, from a clone of this repo) and let it drive the whole setup: it will suggest keywords, fill in your config and persona, walk you through the credentials, test it, and schedule it.

## What you'll need

- Windows with PowerShell and [Claude Code](https://claude.com/claude-code) installed and signed in
- A free [Apify](https://console.apify.com) account, a Claude subscription (for the token), and a Gmail account with 2-Step Verification turned on
- ~15 minutes

## The prompt

Copy this, fill in the five bracketed lines, and paste it into Claude Code from a clone of this repo:

```text
I want to set up the LinkedIn Engagement Agent in this repository for my own topics.

About me:
- Professional lane ("career"): [your day job and how you want to be seen on LinkedIn]
- Growth lane ("bizdev"): [your side goal and who you want to reach]
- My voice: [e.g. blunt, plain, no jargon; any framework you use]
- Send the digest to: [your email address]
- Send it from this Gmail account: [your gmail address]

Please:
1. Propose 5 strong LinkedIn search-keyword phrases for these lanes (2 for "career",
   3 for "bizdev") and confirm them with me before continuing.
2. Create config.ps1 from config.example.ps1 with my details, those keywords, and
   sensible RuntimeDir / ClaudeCwd paths on my machine.
3. Rewrite the "WHO THIS IS FOR" section of scripts/curate-prompt.txt with my persona.
4. Walk me through getting and setting the three credentials as environment variables:
   - APIFY_TOKEN         (free account at console.apify.com > Settings > API)
   - CLAUDE_CODE_OAUTH_TOKEN  (run: claude setup-token)
   - GMAIL_APP_PASSWORD  (Google app password; requires 2-Step Verification)
5. Do one test run of scripts/run-daily.ps1, read RuntimeDir\run.log, and fix anything
   that fails until a real email lands in my inbox.
6. Once it works, register the scheduled task with scripts/register-task.ps1.

Rules: never post, comment, connect, or message on LinkedIn on my behalf. The agent only
emails me suggested targets and angles — I write and post every comment myself. Keep
everything inside the free tiers and confirm the monthly cost with me.
```

## Notes

- The keyword phrases are what make it good — spend a minute with Claude refining the five to match the exact people and conversations you want to show up in.
- If email delivery is blocked (some Google accounts can't create app passwords), ask Claude for the Brevo/SMTP alternative or have it deliver to a file instead.
- Everything runs on your machine; the agent needs it powered on at the scheduled time (it catches up on the next boot if it was off).
