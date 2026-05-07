# Darwish Interserve — Mobile App

Integrated facility management mobile app for **Darwish Interserve Facility
Management W.L.L.** Built with Flutter + Firebase, designed to be
imported into FlutterFlow for visual editing.

## Stack

- **Frontend:** Flutter (Material 3, `google_fonts` Poppins)
- **Auth:** Firebase Auth (email/password for employees, OTP flow for guests)
- **Database:** Cloud Firestore
- **Storage:** Firebase Storage
- **Push:** Firebase Cloud Messaging
- **Routing:** `go_router`
- **State:** `provider`

Brand: Navy `#1B3A5B`, Gold `#C5A84C`, Background `#EEF4F7`, Primary `#13A8E8`.

## Folder layout

```
lib/
├── firebase/        # Firebase options (placeholder until `flutterfire configure`)
├── models/          # AppUser, CompanyProject, CompanyEvent
├── screens/
│   ├── splash/      # Animated splash with DI logo
│   ├── auth/        # Welcome, guest login, Gmail OTP, employee register, SMS OTP
│   ├── home/        # Hero, About, Services, Quick actions
│   ├── events/      # Featured event + news cards
│   ├── projects/    # Portfolio with sector cards & stats
│   └── profile/     # User card, Vision & Mission
├── services/        # AuthService (guest + employee flows)
├── theme/           # AppTheme, AppColors
├── utils/           # AppRouter
└── widgets/         # AuthScaffold, ScreenHeader, OtpField
```

## Auth flows

1. **Guest:** Name + Gmail → 6-digit OTP → home (`AuthRole.guest`).
2. **Employee:** Full name + Employee ID + mobile + password → SMS OTP
   verification → home (`AuthRole.employee`).

`AuthService` is a `ChangeNotifier` exposed via `provider`. The Firestore
rules in `firestore.rules` enforce employee-only writes on `projects`,
`events`, and `announcements`, while keeping reads public for visitor flows.

## Setup

```bash
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure   # overwrites lib/firebase/firebase_options.dart
flutter run
```

In the Firebase console enable: Authentication (Email/Password + Phone),
Cloud Firestore, Storage, Cloud Messaging.

Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules
```

## FlutterFlow import

This project mirrors the FlutterFlow recommended structure (`screens/`,
`widgets/`, `services/`, `models/`). When opening in FlutterFlow:

1. Create a new FlutterFlow project pointing at this Firebase project.
2. Use **Import Code** to bring screens in module-by-module.
3. Wire FlutterFlow's Firebase Auth actions to the same collections used
   here (`users`, `projects`, `events`, `announcements`).
