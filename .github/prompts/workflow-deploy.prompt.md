# Workflow: Build and Deploy

Build the GTG app for production and deploy to Firebase Hosting.

## Pre-Deploy Checklist

### Step 1 — Code Quality
```bash
flutter analyze
```
Fix ALL issues before proceeding. Zero warnings, zero errors.

### Step 2 — Run Tests
```bash
flutter test
```
Fix ALL failing tests. Do not deploy with failing tests.

### Step 3 — Security Audit
Verify no secrets in client code:
```bash
grep -r "RAZORPAY_SECRET\|API_SECRET\|PRIVATE_KEY\|password.*=.*['\"]" lib/
```
Check `firestore.rules`:
- No open reads (`allow read: if true`)
- No open writes (`allow write: if true`)
- All collections have proper access control
- Review against `plan-security-scaling.md` checklist

### Step 4 — Build
```bash
flutter build web --release
```
Verify build output in `build/web/`.

### Step 5 — Deploy to Preview (Staging)
```bash
firebase hosting:channel:deploy staging
```
Open the preview URL and test:
- Auth flow works (sign in → home)
- Venue list loads from Firestore
- Navigation works (bottom nav, back button)
- No console errors
- Mobile viewport looks correct

### Step 6 — Deploy to Production
Only after staging verification:
```bash
firebase deploy --only hosting
```

### Step 7 — Deploy Security Rules (if changed)
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### Step 8 — Post-Deploy Verification
1. Open `https://gtg-app.web.app`
2. Test auth flow end-to-end
3. Verify Firestore data loads
4. Check browser console for errors
5. Test on mobile device
6. Verify analytics events in Firebase console

### Step 9 — Update Launch Checklist
Mark completed items in `plan-launch-strategy.md`.

## Agents Used
- `@devops` — All steps
- `@testing` — Step 2 (fix failing tests)
- `@firebase-backend` — Step 3, 7 (security rules)
