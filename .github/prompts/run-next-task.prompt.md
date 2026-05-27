# GTG — Run Next Task (Orchestrated)

This prompt drives the GTG Orchestrator to pick the next unchecked task from `todo.md`, execute it fully, and report back.

---

## Instructions

You are the GTG Orchestrator. Follow these steps precisely:

### Step 1 — Read the Todo List
Read `todo.md`. Find the **first unchecked item** (`- [ ]`) across all phases in order (Phase A first, then B, C, etc.).

### Step 2 — Read the Relevant Skill
Based on the task type, read the matching skill file before doing anything:

| Task contains... | Read this skill |
|---|---|
| screen, Figma node, UI, layout | `.github/skills/figma-to-flutter/SKILL.md` |
| Service, Firestore, CRUD, stream | `.github/skills/firebase-service/SKILL.md` |
| model, schema, Equatable | `.github/skills/model-creation/SKILL.md` |
| Provider, ChangeNotifier, wire | `.github/skills/provider-wiring/SKILL.md` |
| route, GoRouter, guard | `.github/skills/route-guard/SKILL.md` |
| test, unit test, widget test | `.github/agents/testing.agent.md` |
| deploy, build, firebase deploy | `.github/agents/devops.agent.md` |

### Step 3 — Check for Blockers
If the task requires a **manual human action** (Firebase Console, API key, credentials), stop and tell the user exactly:
- What they need to do
- Where to do it (URL/console)
- What information to provide you when done

### Step 4 — Execute the Task
Follow the skill steps exactly. For every task:
- Read relevant existing code before writing new code
- Use design tokens (never hardcode colors/spacing)
- Follow existing patterns in `lib/screens/`, `lib/services/`, `lib/providers/`
- Reference `plan-database.md` for all Firestore schemas

### Step 5 — Verify
```bash
flutter analyze
```
Fix ALL issues before proceeding. If tests were written, also run:
```bash
flutter test
```

### Step 6 — Mark Complete
Update `todo.md`: change `- [ ] Task description` to `- [x] Task description`.

### Step 7 — Report & Ask
Tell the user:
1. ✅ What was completed
2. 📁 Which files were created/changed
3. ⏭️ What the next pending task is
4. ❓ Ask: "Continue to the next task, or stop here?"

---

## Running Multiple Tasks

If the user says "continue", "run all", or "do the next N tasks", repeat Steps 1–7 for each subsequent task, pausing only when:
- A manual human action is required
- `flutter analyze` fails and can't be auto-fixed
- A deploy step needs user verification

---

## Phase Reference

```
Phase A — Firebase Setup & Infrastructure
Phase B — Authentication  
Phase C — Data Models & Services
Phase D — Venue Discovery & Search
Phase E — Route Planning
Phase F — Profile & Settings
Phase G — Chat & Real-time
Phase H — Payments
Phase I — Polish & Testing
Phase J — Platform Configuration
Phase K — Deploy
```

---

## Quick Commands

| You say... | Orchestrator does... |
|---|---|
| "next task" | Executes the single next `- [ ]` item |
| "do Phase C" | Executes all tasks in Phase C in order |
| "run until blocked" | Keeps going until a manual step or verify failure |
| "status" | Lists completed ✅ and pending ⬜ tasks by phase |
| "what's next?" | Reports the next 3 pending tasks without executing |
| "skip this task" | Marks current task as `- [~]` (skipped) and moves on |
