# RESP Gift Platform

A Flutter web application for collecting educational savings gifts for children's RESP accounts.

## Project Structure

```
├── app/
│   ├── frontend/          # Flutter web application
│   │   ├── lib/           # Dart source code
│   │   ├── web/           # Web-specific files
│   │   ├── test/          # Flutter tests
│   │   └── pubspec.yaml   # Flutter dependencies
│   └── backend/           # Firebase backend
│       ├── functions/     # Cloud Functions (TypeScript)
│       ├── firestore.rules
│       ├── firestore.indexes.json
│       └── storage.rules
├── docs/                  # Documentation
├── .github/workflows/     # CI/CD pipelines
├── firebase.json          # Firebase configuration
└── .firebaserc           # Firebase project settings
```

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24.3+)
- [Node.js](https://nodejs.org/) (20+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Git](https://git-scm.com/)

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd flutter-web-app

# Install Flutter dependencies
cd app/frontend
flutter pub get

# Install Cloud Functions dependencies
cd ../backend/functions
npm install
```

### 2. Firebase Project Setup

**⚠️ Manual Setup Required:**

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - Authentication (Email/Password provider)
   - Firestore Database
   - Cloud Storage
   - Cloud Functions
   - Hosting
3. Update `.firebaserc` with your project ID
4. Configure Firebase for Flutter Web:
   ```bash
   firebase login
   flutterfire configure
   ```
5. Set up Stripe integration:
   ```bash
   firebase functions:config:set stripe.secret_key="sk_test_..." stripe.webhook_secret="whsec_..."
   firebase functions:config:set app.base_url="https://your-domain.com"
   ```
6. Set up Resend for email notifications:
   ```bash
   firebase functions:config:set resend.api_key="re_..."
   ```

### 3. Development

#### Frontend Development
```bash
cd app/frontend
flutter run -d chrome
```

#### Backend Development
```bash
cd app/backend/functions
npm run serve  # Starts Firebase emulators
```

#### Run Tests
```bash
# Flutter tests
cd app/frontend
flutter test

# Cloud Functions tests
cd app/backend/functions
npm test
```

## Deployment

### Automatic Deployment
Push to `main` branch triggers automatic deployment via GitHub Actions.

### Manual Deployment
```bash
# Build Flutter web
cd app/frontend
flutter build web --release

# Deploy to Firebase
cd ../..
firebase deploy
```

## Environment Configuration

### Required Firebase Function Config
```bash
firebase functions:config:set \
  stripe.secret_key="sk_..." \
  stripe.webhook_secret="whsec_..." \
  app.base_url="https://your-domain.com" \
  resend.api_key="re_..."
```

### Required GitHub Secrets
- `FIREBASE_TOKEN`: Firebase CI token (`firebase login:ci`)

## Key Features

- **Parent Dashboard**: Create and manage children's gift pages
- **Public Gift Pages**: Shareable pages for collecting gifts
- **Stripe Integration**: Secure payment processing
- **Email Notifications**: Automated receipts and notifications
- **Real-time Updates**: Live gift tracking with Firestore
- **Responsive Design**: Mobile-first Flutter web UI

## Tech Stack

- **Frontend**: Flutter Web, Material Design 3
- **Backend**: Firebase (Auth, Firestore, Functions, Storage, Hosting)
- **Payments**: Stripe Checkout
- **Email**: Resend API
- **CI/CD**: GitHub Actions
- **Language**: Dart (Frontend), TypeScript (Backend)

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Run tests: `flutter test` and `npm test`
4. Submit a pull request

## License

Private project - All rights reserved.