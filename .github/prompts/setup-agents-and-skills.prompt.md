# GTG — Generate Agents, Skills, Workflows & Prompts

You are setting up a complete AI-assisted development environment for the **GTG** Flutter project. This is a venue discovery + route planning app targeting India & Dubai, built with Flutter, Firebase Blaze, Mapbox, Razorpay, and Provider state management.

---

## TASK

Generate the following files to create a comprehensive agent/skill/workflow system for this project:

---

## 1. AGENTS — Create `.github/agents/AGENTS.md`

Define these specialized agents:

### `flutter-ui` Agent
- **Purpose**: Build pixel-perfect Flutter screens from Figma designs
- **Tools**: Figma MCP, file read/write, terminal (flutter analyze)
- **Instructions**: Always use design tokens from `lib/theme/`, reuse widgets from `lib/widgets/`, follow existing screen patterns in `lib/screens/`

### `firebase-backend` Agent
- **Purpose**: Implement Firebase services, security rules, Cloud Functions
- **Tools**: File read/write, terminal (firebase deploy, flutter test)
- **Instructions**: Follow schemas in `plan-database.md`, security patterns in `plan-security-scaling.md`, never expose secrets client-side

### `state-management` Agent
- **Purpose**: Create/update Providers, models, and service integrations
- **Tools**: File read/write, Dart MCP tools
- **Instructions**: Use ChangeNotifier pattern, register in main.dart MultiProvider, follow existing patterns in `lib/providers/`

### `testing` Agent
- **Purpose**: Write unit tests, widget tests, integration tests
- **Tools**: File read/write, terminal (flutter test)
- **Instructions**: Test services and models with unit tests, critical flows with widget tests, maintain coverage

### `devops` Agent
- **Purpose**: Build, deploy, CI/CD, Firebase Hosting
- **Tools**: Terminal, file read/write
- **Instructions**: Follow `plan-launch-strategy.md`, use firebase deploy commands, verify security rules before deploy

---

## 2. SKILLS — Create files under `.github/skills/`

### `.github/skills/figma-to-flutter/SKILL.md`
```
- Extract design from Figma node ID using Figma MCP
- Map design tokens to existing `lib/theme/app_colors.dart`, `app_tokens.dart`
- Generate Flutter widget code matching the design
- Use existing reusable widgets (AppPrimaryButton, GtgBottomNav, VenueCard, etc.)
- Add proper GoRouter route in `lib/utils/router.dart`
- Run `flutter analyze` to verify
```

### `.github/skills/firebase-service/SKILL.md`
```
- Create/update service file in `lib/services/`
- Follow Firestore collection schemas from plan-database.md
- Implement CRUD operations with proper error handling
- Add real-time listeners where applicable
- Update corresponding Provider in `lib/providers/`
- Ensure Firestore security rules cover the new operations
```

### `.github/skills/model-creation/SKILL.md`
```
- Create Dart model class in `lib/models/`
- Use Equatable for value equality
- Include fromJson/toJson for Firestore serialization
- Add fromFirestore/toFirestore factory methods
- Match schema exactly from plan-database.md
```

### `.github/skills/provider-wiring/SKILL.md`
```
- Create ChangeNotifier in `lib/providers/`
- Expose loading/error/data states
- Wire to corresponding service in `lib/services/`
- Register in main.dart MultiProvider
- Handle dispose properly
```

### `.github/skills/route-guard/SKILL.md`
```
- Add new route to GoRouter in `lib/utils/router.dart`
- Apply auth redirect guard for protected routes
- Use ShellRoute for screens with bottom nav
- Follow named route pattern
```

---

## 3. WORKFLOWS — Create `.github/prompts/` workflow files

### `workflow-new-screen.prompt.md`
```
Workflow: Build a new screen end-to-end
1. Get Figma design (provide node ID)
2. Create screen file in lib/screens/
3. Map to design tokens and reuse widgets
4. Add GoRouter route
5. Create/update Provider if data-driven
6. Run flutter analyze
7. Update todo.md
```

### `workflow-firebase-feature.prompt.md`
```
Workflow: Implement a Firebase-backed feature
1. Review schema in plan-database.md
2. Create/update model in lib/models/
3. Create/update service in lib/services/
4. Create/update Provider in lib/providers/
5. Wire to UI screen
6. Update Firestore security rules if needed
7. Write tests
8. Update todo.md
```

### `workflow-deploy.prompt.md`
```
Workflow: Build and deploy
1. Run flutter analyze (fix all issues)
2. Run flutter test (fix failures)
3. flutter build web --release
4. firebase deploy --only hosting
5. Verify deployed site
6. Update plan-launch-strategy.md checklist
```

---

## 4. INSTRUCTIONS — Create `.github/copilot-instructions.md`

Include:
- Project: GTG — Flutter venue discovery app
- Stack: Flutter 3.x, Dart 3.11+, Firebase (Auth, Firestore, Storage, FCM, Hosting), Mapbox, Razorpay, Provider
- Architecture: `lib/` → screens, widgets, models, providers, services, theme, utils
- Design system: Tokens in `lib/theme/` (app_colors.dart, app_tokens.dart, app_theme.dart)
- State: Provider (ChangeNotifier) — one per feature
- Navigation: GoRouter with ShellRoute for bottom nav, auth guards
- Database: Cloud Firestore — schemas in `plan-database.md`
- Security: Follow `plan-security-scaling.md`, never expose keys client-side
- Naming: snake_case files, PascalCase classes, camelCase methods
- Testing: Unit tests for services/models, widget tests for critical flows
- Plans: Reference `plan-master-development.md` for phases
- Related app: GTG Partner (venue owner app) shares same Firebase project

---

## 5. TODO LIST — Create/Update `todo.md`

Generate a comprehensive, phased todo list organized by the agents/skills above. Each item should be a discrete, actionable task that can be completed by invoking one agent+skill combination. Structure:

### Phase A — Firebase Setup & Infrastructure
- [ ] Create Firebase project and configure FlutterFire
- [ ] Set up Firestore security rules (from plan-security-scaling.md)
- [ ] Configure Firebase Auth providers (Phone, Email, Google, Apple)
- [ ] Set up Firebase Storage bucket and rules
- [ ] Set up Firebase Hosting
- [ ] Implement ShellRoute with persistent bottom nav
- [ ] Add auth guards to GoRouter

### Phase B — Authentication
- [ ] Implement AuthService (all sign-in methods)
- [ ] Refactor AuthProvider to use AuthService
- [ ] Add form validation to auth screens
- [ ] Wire auth state to route guards
- [ ] Test auth flows

### Phase C — Data Models & Services
- [ ] Create/verify all Firestore models (User, Venue, Route, Stop, ChatRoom, Message, Review, Notification, Payment, Report)
- [ ] Create VenueService (CRUD + real-time + geo-queries)
- [ ] Create RouteService (CRUD + sharing)
- [ ] Create UserService (profile + preferences)
- [ ] Create NotificationService (FCM + in-app)
- [ ] Create ChatService (rooms + messages + real-time)
- [ ] Wire all services to Providers

### Phase D — Venue Discovery & Search
- [ ] Integrate Mapbox map on HomeScreen
- [ ] Implement venue markers on map
- [ ] Build VenueDetailScreen from Figma
- [ ] Implement venue search with filters
- [ ] Seed initial venue data

### Phase E — Route Planning
- [ ] Integrate Mapbox Directions API
- [ ] Build RouteOverviewScreen
- [ ] Build RouteStopsScreen
- [ ] Wire GTG Flow wizard → route generation
- [ ] Implement route CRUD (save/edit/delete)

### Phase F — Profile & Settings
- [ ] Build EditProfileScreen from Figma
- [ ] Wire SettingsScreen to real user data
- [ ] Build NotificationsScreen
- [ ] Implement FCM push notifications
- [ ] Implement Refer & Earn feature

### Phase G — Chat & Real-time
- [ ] Build ChatListScreen
- [ ] Build ChatScreen with real-time messages
- [ ] Implement live location sharing
- [ ] Customer support chat type

### Phase H — Payments
- [ ] Integrate Razorpay Flutter SDK
- [ ] Build PaymentScreen
- [ ] Create Cloud Function for order creation
- [ ] Handle payment callbacks and store records

### Phase I — Polish & Testing
- [ ] Replace Figma CDN URLs with local/Storage assets
- [ ] Add loading skeletons (shimmer)
- [ ] Add error/empty states
- [ ] Implement dark theme
- [ ] Write unit tests for all services
- [ ] Write widget tests for auth, venue detail, payment
- [ ] Cross-browser and responsive testing

### Phase J — Deploy
- [ ] Production Firestore security rules audit
- [ ] flutter build web --release
- [ ] firebase deploy --only hosting
- [ ] Firebase Analytics dashboards
- [ ] Error reporting setup

---

## EXECUTION

Generate ALL the files listed above. For each file:
1. Create it at the specified path
2. Include detailed, actionable content (not placeholders)
3. Reference existing project files where relevant
4. Ensure consistency across all generated files

After generating, confirm the complete file list created.
