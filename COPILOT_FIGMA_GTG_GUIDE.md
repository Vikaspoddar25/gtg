# Copilot + Figma GTG Workflow

This project already uses Flutter (`dart`, `provider`, `go_router`) and GTG design tokens.

## 1) GitHub Copilot in Cursor (Dart/Flutter)

1. Open Extensions in Cursor and install:
   - `GitHub Copilot`
   - `GitHub Copilot Chat` (optional but recommended)
2. Open command palette and run `GitHub: Sign in`.
3. Verify Copilot is enabled for Dart files.
4. Open `lib/main.dart` and type inside a widget; accept a ghost suggestion with `Tab`.

Prompt examples:
- "Create a reusable Flutter card widget with image, title, subtitle, and CTA."
- "Refactor hardcoded spacing to AppSpacing tokens."
- "Generate a golden test scaffold for HomeScreen."

## 2) Figma GTG source nodes to implement

Figma file: `wzigfuOA1J8AF0Mya8A1jr`

Selected primary screens:
- `58:35` - Phone input / OTP request screen
- `72:150` - OTP verification screen
- `117:105` - Home / discovery screen

Reference URL:
- https://www.figma.com/design/wzigfuOA1J8AF0Mya8A1jr/GTG?node-id=0-1&m=dev&t=xjqNSR8pWaY6S9w6-1

## 3) Implementation sequence

1. Keep tokens centralized in `lib/theme/`.
2. Reuse shared widgets from `lib/widgets/`.
3. Implement and iterate screen-by-screen in `lib/screens/`.
4. Run `flutter analyze` and verify mobile + web layouts.
