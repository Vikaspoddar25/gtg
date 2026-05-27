---
description: "Skill: Automatically commit and push changes to GitHub after any code modification"
---

# Git Auto-Commit Skill

Automatically commit and push all changes to the `Vikaspoddar25/gtg` GitHub repository after code modifications are made.

**Pushing to `main` automatically triggers deployment to https://goodtog-b1420.web.app/ via GitHub Actions.**

## When to Invoke
This skill should be triggered **after every meaningful code change** — including:
- New files created
- Existing files modified
- Files deleted
- Configuration changes
- Any task completed by any agent

## Repository Details
- **Remote**: `https://github.com/Vikaspoddar25/gtg.git`
- **Branch**: `main` (default)
- **Username**: `Vikaspoddar25`

## Steps

### 1. Stage Changes
```bash
cd /Users/apple/Personal\ Projects/gtg
git add -A
```

### 2. Generate Commit Message
Create a concise, descriptive commit message following conventional commits:
- `feat: <description>` — new feature or screen
- `fix: <description>` — bug fix
- `refactor: <description>` — code restructure without behavior change
- `style: <description>` — UI/design changes
- `chore: <description>` — config, dependencies, tooling
- `docs: <description>` — documentation only

### 3. Commit
```bash
git commit -m "<type>: <concise description>"
```

### 4. Push
```bash
git push origin main
```

### 5. Confirm
Report the commit hash and confirm push was successful.

## Error Handling
- If push fails due to diverged branches: `git pull --rebase origin main` then retry push
- If merge conflicts occur: resolve them, then commit and push
- Never force push (`--force`) without explicit user approval

## Commit Message Examples
| Change | Message |
|---|---|
| Added venue detail screen | `feat: add venue detail screen with map integration` |
| Fixed auth redirect bug | `fix: correct auth redirect on OTP verification` |
| Updated design tokens | `style: update color tokens to match Figma` |
| Added provider for bookings | `feat: add booking provider with Firestore service` |
| Updated pubspec dependencies | `chore: update firebase_core to v4.8.0` |
