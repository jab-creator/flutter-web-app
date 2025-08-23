RESP Gift — v1 App Design Spec (Firebase)
0) Goal & Roles

Same as before: Parent creates a public gift page → Gifter pays via Stripe → Parent sees gifts in a dashboard. Roles: Parent, Gifter, Admin.

1) Stack

Frontend: Flutter Web (Material 3), firebase_core, firebase_auth, cloud_firestore, firebase_analytics

Backend: Firebase

Auth: Email/Password

DB: Cloud Firestore

Server: Cloud Functions (Node 20, TypeScript)

Payments: Stripe Checkout (CAD) + Stripe webhooks in Cloud Functions

Email: Resend (Node SDK in Functions) or Gmail/SMTP via Nodemailer

Analytics: Firebase Analytics (web) + optional Plausible

Hosting: Firebase Hosting (Flutter build output) or Cloudflare Pages (optional)

CI/CD: GitHub Actions → flutter build web → firebase deploy

2) Firestore Data Model

Collections use auto‑ids unless noted.

/users/{userId}
  email: string
  fullName: string
  createdAt: timestamp

/children/{childId}
  userId: ref(/users/{userId})
  firstName: string
  lastName?: string
  dob?: timestamp
  slug: string      // unique across children
  heroPhotoUrl?: string
  goalCad?: number
  createdAt: timestamp

/giftPages/{pageId}
  childId: ref(/children/{childId})
  headline: string
  blurb: string
  theme: 'default' | 'soft' | 'bold'
  isPublic: boolean

/gifts/{giftId}
  childId: ref(/children/{childId})
  gifterName?: string
  gifterEmail?: string
  message?: string
  amountCad: number     // store dollars as integer cents? see note below
  amountCents: number   // recommended: **source of truth**
  stripePaymentIntent: string
  status: 'pending' | 'succeeded' | 'failed' | 'refunded'
  createdAt: timestamp

/slugIndex/{slug}        // for O(1) lookups by /for/:slug
  childId: ref(/children/{childId})


Money storage: Use amountCents (integer). Keep amountCad only if needed for display; derive in UI.

3) Firestore Security Rules (high‑level)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() { return request.auth != null; }
    function isOwner(userId) { return isSignedIn() && request.auth.uid == userId; }

    match /users/{uid} {
      allow read, update: if isOwner(uid);
      allow create: if request.auth.uid == uid;
    }

    match /children/{childId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }

    match /giftPages/{pageId} {
      // Public read if page isPublic
      allow get: if resource.data.isPublic == true || (isSignedIn() && isOwner(get(/databases/$(database)/documents/children/$(resource.data.childId.id)).data.userId));
      allow list: if false; // always query by id/slug via Cloud Function if needed
      allow create, update, delete: if isSignedIn() &&
        isOwner(get(/databases/$(database)/documents/children/$(request.resource.data.childId.id)).data.userId);
    }

    match /gifts/{giftId} {
      // Parents can read their own child’s gifts
      allow get, list: if isSignedIn() &&
        isOwner(get(/databases/$(database)/documents/children/$(resource.data.childId.id)).data.userId);
      // Writes only via Cloud Functions (server side)
      allow create, update, delete: if false;
    }

    match /slugIndex/{slug} {
      allow get: if true;   // public resolve
      allow create, update, delete: if request.auth.token.admin == true; // set via Functions
    }
  }
}

4) Cloud Functions (TypeScript)

Endpoints

POST /payments/checkout

Input: { childId, amountCents, gifterName?, gifterEmail?, message? }

Create gifts doc with status='pending'

Create Stripe Checkout Session (CAD)

Return url

POST /webhooks/stripe

Verify signature

On payment_intent.succeeded:

Find gift by paymentIntent.id

Set status='succeeded'

Send emails (Resend/Nodemailer)

GET /public/childBySlug/:slug

Read /slugIndex/{slug} → fetch giftPages + public child fields + last N messages (firstName + message, anonymized)

Function skeleton

export const paymentsCheckout = onRequest({ cors: true }, async (req, res) => {
  // validate body
  // check child exists and is public (or owned if authed)
  // create gifts doc (pending)
  // create Stripe Checkout Session with success/cancel URLs
  // return session.url
});

export const stripeWebhook = onRequest({ secrets: ["STRIPE_WEBHOOK_SECRET"] }, async (req, res) => {
  // verify event
  // handle payment_intent.succeeded -> update gift + send emails
  // handle payment_intent.payment_failed -> mark failed
  // res.sendStatus(200)
});

5) Flutter Pages & Flow

Unchanged from the Supabase spec, with Firebase packages:

/ Landing

/signup, /login (Firebase Auth)

/onboarding create child + page (write children, giftPages, slugIndex)

/for/:slug public gift page

Call GET /public/childBySlug/:slug (Function) or read slugIndex → giftPages directly if you prefer pure Firestore reads

Amount chips ($25, $50, $100, custom)

“Continue to secure checkout” → call payments/checkout → redirect to Stripe

/thanks success screen

/dashboard reads gifts where childId == selected child; sum of status='succeeded'

/admin (optional gated by custom claims)

6) Stripe Setup

Products not needed; use payment links via Checkout Session with custom amount

Currency CAD

Enable Apple Pay/Google Pay/Cards

Webhook events: payment_intent.succeeded, payment_intent.payment_failed

Success URL: https://app.example.com/thanks?child={id}

Cancel URL: https://app.example.com/for/{slug}

7) Emails (Functions)

Resend (recommended) or Nodemailer SMTP

Templates:

Gifter receipt: “Your gift to {{firstName}} was received — Thank you!”

Parent notify: “New gift for {{firstName}} ({{amount}})”

Trigger: on succeeded in webhook handler

8) Analytics Events

Use firebase_analytics:

landing_viewed, signup_complete, child_created, giftpage_viewed(slug)

checkout_started(amount_cents, slug)

payment_succeeded(amount_cents, slug)

export_csv

9) Hosting & CI/CD

Hosting: firebase init hosting → deploy build/web from Flutter

CI: GitHub Actions

Cache Flutter SDK

flutter pub get

flutter build web --release

npm ci in /functions then npm run build

firebase deploy --only hosting,functions

Required secrets

FIREBASE_TOKEN (CI), or use OIDC Workload Identity

STRIPE_SECRET_KEY, STRIPE_PUBLIC_KEY, STRIPE_WEBHOOK_SECRET

RESEND_API_KEY (optional)

10) Acceptance Criteria (Firebase)

Parent can sign up (Firebase Auth), create child + gift page; public URL via slugIndex.

Gifter completes Stripe payment from public page.

Webhook sets gift to succeeded and sends both emails.

Dashboard totals are correct; CSV export works (client‑side or Function).

Public page responsive; mobile/Desktop clean.

Analytics events fire.

11) Repository Layout
/app
  /frontend (Flutter)
    lib/
    web/
    assets/
    pubspec.yaml
  /backend
    /functions        // firebase functions (typescript)
      src/
        paymentsCheckout.ts
        stripeWebhook.ts
        publicChildBySlug.ts
        email.ts
      package.json
      tsconfig.json
    firestore.rules
    firestore.indexes.json
    .env.example
/.github/workflows
  ci.yml
firebase.json
.firebaserc
README.md

12) Agent “Build Tasks” (Firebase version)

Scaffold

Create repo per layout; firebase init (Firestore, Functions TS, Hosting)

Auth

Wire up Flutter Firebase Auth (email/pass, reset)

DB

Implement collections above; create firestore.rules as specified

Add composite indexes if needed (gifts by childId + createdAt)

Public Page

Slug resolution: slugIndex/{slug} → giftPages + children

Checkout

Function paymentsCheckout:

Validate amountCents ≥ 200 (e.g., $2 min)

Create pending gift

Create Stripe Checkout Session (metadata with giftId)

Return session.url

Webhook

Function stripeWebhook:

On success: update gifts/{giftId} to succeeded, set amountCents from event if needed

Send gifter receipt + parent notify

Dashboard

Query gifts by childId, sum status='succeeded'

Client CSV export (headers: date,name,email,amount_cents,status,message)

Analytics

Add events per section 8

Hosting/CI

GitHub Action to build & deploy hosting + functions

QA

Playwright (or Flutter integration test) for happy path in Stripe test mode

13) Seed Data (Firestore export‑style, illustrative)
{
  "users": {
    "parentUid": { "email": "parent@example.com", "fullName": "Lee Parent", "createdAt": 0 }
  },
  "children": {
    "childA": { "userId": "parentUid", "firstName": "Brennan", "slug": "brennan", "goalCad": 5000, "createdAt": 0 }
  },
  "giftPages": {
    "pageA": { "childId": "childA", "headline": "Help Brennan’s RESP grow", "blurb": "Instead of toys...", "theme": "default", "isPublic": true }
  },
  "slugIndex": {
    "brennan": { "childId": "childA" }
  },
  "gifts": {
    "gift1": { "childId": "childA", "gifterName": "Gran", "amountCents": 50000, "message": "With love", "status": "succeeded", "createdAt": 0 },
    "gift2": { "childId": "childA", "gifterName": "Uncle Sam", "amountCents": 25000, "message": "Go get 'em!", "status": "pending", "createdAt": 0 }
  }
}

14) Copy, Legal, Themes, Empty States

Same as prior spec (keep the RESP disclaimer).

15) Notes on Simplicity & Cost

Firebase free tier will comfortably handle v1 testing.

Avoid server VM ops entirely; Functions + Hosting is enough.

Keep writes to gifts behind Functions (no client‑side writes to gifts).

If you want, I can also drop in:

a ready‑to‑paste firestore.rules and

a minimal Functions paymentsCheckout.ts + stripeWebhook.ts starter

…so the agent has working stubs on day 1.

# RESP Gift — Product Spec

(Your evolving, human-readable spec here—UX notes, flows, screenshots, etc.)

---

## Work Items
```spec
epics:
  - key: A
    title: Core Gifting Flow
    description: From landing to confirmation with mock payment.
    stories:
      - key: A1
        title: Landing page scaffold
        labels: [agent:frontend, agent-ready]
        deliverables:
          - lib/pages/landing.dart
          - lib/widgets/hero.dart
        acceptance_criteria:
          - Hero and CTA render on mobile/desktop
          - CTA navigates to /gift/start
          - Lighthouse perf >= 90 on dev build
        test_hints:
          - flutter analyze passes
      - key: A2
        title: Gift creation wizard
        labels: [agent:frontend, agent-ready]
        deliverables:
          - lib/pages/gift_wizard/*
        acceptance_criteria:
          - 3 steps with validation
          - next/prev works; state preserved
          - unit tests for GiftDraft model
      - key: A3
        title: Mock payment service
        labels: [agent:backend, agent-ready]
        deliverables:
          - app/api/payments.py
          - tests/test_payments.py
        acceptance_criteria:
          - POST /api/payments/create-intent -> {client_secret: "test_..."}
          - pytest passes locally and in CI
  - key: B
    title: Account & Data
    stories:
      - key: B1
        title: Email magic link auth
        labels: [agent:backend, agent-ready]
        deliverables:
          - app/api/auth.py
          - tests/test_auth.py
        acceptance_criteria:
          - Request code -> verify -> session cookie set
          - Rate-limited; no PII in logs