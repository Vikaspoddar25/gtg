# GTG — Launch Strategy Plan

## Hosting: Firebase Hosting

### Why Firebase Hosting
- Already using Firebase for backend — single ecosystem
- Free SSL certificate (auto-provisioned)
- Global CDN (Fastly-backed)
- One-command deploy: `firebase deploy --only hosting`
- Free subdomain: `gtg-now.web.app` or `gtg-now.firebaseapp.com`
- Custom domain support when ready
- Preview channels for staging/testing
- 10 GB storage + 360 MB/day transfer on free tier

### Alternatives Considered

| Platform | Pros | Cons | Verdict |
|----------|------|------|---------|
| **Firebase Hosting** | Integrated ecosystem, CDN, free SSL, preview channels | Less build pipeline customization | ✅ Best fit |
| **Vercel** | Great DX, edge functions, analytics | Designed for Next.js/React, Flutter web is static SPA | ❌ Overkill |
| **Netlify** | Similar to Vercel, generous free tier | Same — optimized for JS frameworks | ❌ Overkill |
| **AWS S3 + CloudFront** | Enterprise-grade, infinite scale | Complex setup, multiple services to configure | ❌ Too complex for solo dev |
| **Cloudflare Pages** | Free, fast CDN, Workers | Less Firebase integration | ❌ Adds complexity |
| **GitHub Pages** | Free, simple | No server-side features, limited | ❌ Too basic |

---

## Pre-Launch Checklist

### Infrastructure
- [ ] Firebase project created (`gtg-app`)
- [ ] Blaze plan activated
- [ ] Firestore database provisioned (region: `asia-south1`)
- [ ] Firebase Auth providers enabled (Email, Phone, Google, Apple)
- [ ] Firebase Hosting site configured
- [ ] Firebase Storage bucket created (for user uploads, venue images)
- [ ] Cloud Functions deployed (payment order creation, denormalization fan-out)
- [ ] Firestore security rules deployed and tested
- [ ] Firebase Storage security rules deployed
- [ ] FCM configured for web push notifications

### Security (see security-plan.md for details)
- [ ] Firestore security rules: no open reads/writes
- [ ] Firebase Auth: rate limiting on phone OTP (default: 10 SMS/IP/hour)
- [ ] Razorpay: server-side signature verification via Cloud Function
- [ ] API keys restricted (Mapbox, Razorpay public key only in client)
- [ ] CORS configured on Firebase Hosting
- [ ] Content Security Policy headers set
- [ ] XSS prevention: sanitize user inputs before Firestore writes
- [ ] No secrets in client-side code (use Firebase Remote Config or Cloud Functions)

### Performance
- [ ] Flutter web build with `--release --web-renderer canvaskit`
- [ ] Enable gzip compression (Firebase Hosting does this automatically)
- [ ] Lazy-load routes with deferred loading: `GoRoute(builder: ..., routes: [...])`
- [ ] Image optimization: WebP format, max 800px width for venue images
- [ ] Firestore query pagination (limit 20 per page)
- [ ] Cache Firestore responses (offline persistence enabled)

### SEO & Web Vitals
- [ ] Update `web/index.html`: title, description, OG tags
- [ ] Add `robots.txt` allowing search engine crawling
- [ ] Add `sitemap.xml` (if venues are public pages)
- [ ] Set proper `<meta>` viewport tag (already in Flutter default)
- [ ] PWA manifest updated (`web/manifest.json`): name, icons, theme color
- [ ] Add service worker for offline support
- [ ] Favicon updated to GTG brand

### Analytics & Monitoring
- [ ] Firebase Analytics enabled
- [ ] Custom events: `sign_up`, `sign_in`, `venue_view`, `route_created`, `payment_completed`
- [ ] Firebase Performance Monitoring (web)
- [ ] Error logging: `FlutterError.onError` → Firebase Crashlytics (or custom Cloud Function logger for web)
- [ ] Uptime monitoring: use UptimeRobot (free) or Firebase Alerts

### Legal & Compliance
- [ ] Privacy Policy page (required for Google Sign-In, Apple Sign-In, Play Store)
- [ ] Terms of Service page
- [ ] Cookie consent banner (required for EU/Dubai visitors)
- [ ] GDPR data deletion support (Firebase Auth already supports account deletion)
- [ ] Razorpay compliance: PCI-DSS handled by Razorpay (no card data touches your server)

---

## Domain Strategy

### Phase 1 (Launch)
- Use Firebase free subdomain: `gtg-now.web.app`
- Pros: free, instant, SSL included
- Cons: not branded, not memorable

### Phase 2 (Post-traction)
- Buy custom domain: `gtgapp.in` or `gtg.app` or `goodtogo.app`
- Recommended registrars: Google Domains, Namecheap, Cloudflare Registrar
- Add to Firebase Hosting: `firebase hosting:channel:deploy production --only hosting`
- DNS: point A records to Firebase Hosting IPs
- SSL: auto-provisioned by Firebase (Let's Encrypt)
- Estimated cost: $10-40/year depending on TLD

### Recommended Domain Names
| Domain | TLD | Est. Price | Notes |
|--------|-----|------------|-------|
| `gtgapp.in` | .in | ~$3/year | India-focused, cheap |
| `gtgapp.com` | .com | ~$12/year | Universal |
| `goodtogo.app` | .app | ~$14/year | Branded, HTTPS-only TLD |
| `gtg.app` | .app | ~$14/year | Short, premium if available |

---

## Deployment Pipeline

### Manual Deploy (Phase 1)
```bash
# Build Flutter web
flutter build web --release --web-renderer canvaskit

# Deploy to Firebase
firebase deploy --only hosting
```

### CI/CD (Phase 2 — GitHub Actions)
```yaml
# .github/workflows/deploy.yml
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.11.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release --web-renderer canvaskit
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
```

### Preview Deploys (Staging)
```bash
# Deploy to preview channel (temporary URL)
firebase hosting:channel:deploy staging --expires 7d
# Gives URL like: gtg-app--staging-abc123.web.app
```

---

## Launch Phases

### Soft Launch (Week 1 post-build)
- Deploy to `gtg-now.web.app`
- Share with 10-20 friends/family for testing
- Collect feedback via Google Form or in-app feedback
- Fix critical bugs
- Seed venues for one city (Mumbai or Delhi)

### Beta Launch (Week 2-3)
- Open to broader audience (100-500 users)
- Share on social media, WhatsApp groups
- Monitor Firebase Analytics for engagement
- Monitor Firestore usage/costs
- A/B test onboarding flow

### Public Launch (Week 4+)
- Announce on Product Hunt, Reddit (r/india, r/mumbai), Twitter
- SEO optimization
- Add more cities
- Enable Refer & Earn feature
- Consider ASO for mobile (if you publish to Play Store/App Store)

---

## Scaling Strategy

### Firestore Auto-Scaling
- Firestore scales automatically — no server management
- Watch for hot spots: avoid monotonically increasing document IDs
- Use distributed counters for high-write fields (e.g., venue view count)

### Firebase Hosting CDN
- Already globally distributed via Fastly CDN
- No action needed — scales automatically

### Cloud Functions
- Auto-scale from 0 to 1000 instances
- Set min instances for critical functions (payment verification) to avoid cold starts
- Use 2nd gen Cloud Functions (Cloud Run-based) for better performance

### Cost Monitoring
- Set Firebase budget alerts: $10, $25, $50, $100
- Review usage weekly in Firebase Console
- Optimize queries: add composite indexes, use `.select()` to fetch only needed fields
- Consider Firestore bundle for public/cacheable data (venue listings)

---

## Rollback Strategy

### Firebase Hosting
- Firebase keeps all previous deploys
- Instant rollback: `firebase hosting:clone SOURCE_SITE:SOURCE_CHANNEL TARGET_SITE:live`
- Or use Firebase Console → Hosting → Release History → Roll back

### Firestore
- Use security rules versioning (keep in source control)
- Weekly Firestore exports to Cloud Storage for data recovery
- No built-in "undo" — design writes carefully

### Cloud Functions
- Each deploy creates a new version
- Roll back via: `gcloud functions deploy FUNCTION_NAME --source=gs://BUCKET/previous-version`
- Or redeploy from previous git commit
