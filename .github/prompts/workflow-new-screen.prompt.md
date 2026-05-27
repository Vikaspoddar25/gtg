# Workflow: Build a New Screen End-to-End

Build a complete screen from Figma design to working route with data integration.

## Required Input
- **Figma node ID**: (e.g., `349:144`)
- **Screen name**: (e.g., `VenueDetailScreen`)
- **Route path**: (e.g., `/venue-detail/:venueId`)
- **Has bottom nav?**: Yes/No
- **Is data-driven?**: Yes/No (needs Provider/Service)

## Steps

### Step 1 — Get Figma Design
Use the `figma-to-flutter` skill:
- File key: `wzigfuOA1J8AF0Mya8A1jr`
- Extract design context for the given node ID
- Take note of layout, colors, typography, components

### Step 2 — Create Screen File
- Create `lib/screens/<screen_name>.dart`
- Map all Figma values to `AppColors`, `AppTokens`
- Reuse existing widgets: `AppPrimaryButton`, `VenueCard`, `GtgBottomNav`, `GtgSmallLogo`
- Follow existing screen patterns (check any file in `lib/screens/`)
- Make responsive (no hardcoded widths)

### Step 3 — Add GoRouter Route
Use the `route-guard` skill:
- Add route to `lib/utils/router.dart`
- Inside `ShellRoute` if bottom nav, outside if full-page
- Add to `_publicPaths` if no auth required
- Add screen import

### Step 4 — Create/Update Provider (if data-driven)
Use the `provider-wiring` skill:
- Create `lib/providers/<feature>_provider.dart`
- Wire to existing or new service
- Register in `main.dart` `MultiProvider`

### Step 5 — Verify
```bash
flutter analyze
```
Fix any issues.

### Step 6 — Update Todo
Mark the corresponding item in `todo.md` as complete: `- [x]`

## Agents Used
- `@flutter-ui` — Steps 1-2 (design extraction and screen creation)
- `@state-management` — Step 4 (provider creation)
- `@firebase-backend` — If new service needed
