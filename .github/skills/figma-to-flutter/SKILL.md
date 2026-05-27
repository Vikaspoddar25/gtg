---
description: "Skill: Convert a Figma design node into a Flutter screen or widget using GTG design tokens"
---

# Figma-to-Flutter Skill

Convert a Figma design into a Flutter screen/widget for the GTG app, matching the design pixel-perfectly using project design tokens.

## Inputs Required
- **Figma node ID** (e.g., `349:144`) — the specific frame to implement
- **Screen name** — e.g., `VenueDetailScreen`
- **Route path** — e.g., `/venue-detail` (if adding a route)

## Steps

### 1. Extract Design from Figma
```
Use Figma MCP get_design_context:
- fileKey: wzigfuOA1J8AF0Mya8A1jr
- nodeId: <provided node ID, convert "-" to ":" if from URL>
```
Analyze the returned code, screenshot, and hints.

### 2. Map Design Tokens
Map Figma values to existing project tokens:

| Figma Value | Maps To |
|---|---|
| `#CE3131` (red) | `AppColors.primary` |
| `#3F3F3F` (dark text) | `AppColors.textPrimary` |
| `#FFFFFF` (white) | `AppColors.surface` |
| `#EBEBEB` (hint) | `AppColors.textHint` |
| `#6FD44C` (green) | `AppColors.success` |
| `#FFF4F4` (light pink bg) | `AppColors.primaryLight` |
| Any spacing value | Check `AppTokens` for matching constants |
| Any text style | Check `AppTokens` typography styles |

If a color or value doesn't exist in tokens, add it to `lib/theme/app_colors.dart` or `lib/theme/app_tokens.dart`.

### 3. Check Reusable Widgets
Before building custom UI, check if these existing widgets apply:
- `AppPrimaryButton` — for primary CTA buttons
- `GtgBottomNav` — for bottom navigation (handled by ShellRoute)
- `GtgSmallLogo` — for the GTG logo
- `VenueCard` — for venue list items

### 4. Create Screen File
Create `lib/screens/<screen_name>.dart` following existing screen patterns.

### 5. Add GoRouter Route
In `lib/utils/router.dart`:
- **With bottom nav**: Add inside `ShellRoute.routes` list
- **Without bottom nav**: Add as top-level `GoRoute`
- **Auth-protected**: Default (redirect guard handles it)
- **Public**: Add path to `_publicPaths` set

### 6. Verify
```bash
flutter analyze
```
Fix any issues before marking complete.

## Quality Checklist
- [ ] All colors use `AppColors.xxx`
- [ ] All spacing uses `AppTokens.xxx` or explicit `SizedBox`
- [ ] Responsive layout (no hardcoded widths for containers)
- [ ] `const` constructors used wherever possible
- [ ] File name is `snake_case.dart`
- [ ] Class name is `PascalCase`
- [ ] Route added to `router.dart`
- [ ] `flutter analyze` passes
