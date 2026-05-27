---
description: "Auto-commit and push all changes to GitHub after completing any task"
mode: "agent"
---

After completing any code changes, automatically commit and push to GitHub:

```bash
cd /Users/apple/Personal\ Projects/gtg
git add -A
git commit -m "<type>: <concise description of changes>"
git push origin main
```

Use conventional commit prefixes: `feat:` / `fix:` / `refactor:` / `style:` / `chore:` / `docs:`

Repository: `Vikaspoddar25/gtg` on GitHub.
