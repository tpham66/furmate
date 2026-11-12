# 🐾 FurMate

**FurMate** is a cross-platform pet care management application built with Flutter, Firebase, and Google Gemini AI. It helps pet owners organize their pets' daily activities, manage care schedules, set reminders, and gain AI-powered insights into their pets' routines.

Designed for both **iOS and web**, FurMate provides a simple, intuitive interface for keeping pet care information organized and accessible across devices.

[![Live Demo](https://img.shields.io/badge/Live_Demo-FurMate_Web-blue)](https://furmate-b50c4.web.app)

## Features

### Pet Profile Management
- Create, edit, and delete personalized pet profiles.
- Store pet information, including name, age, species, breed, weight, gender, and notes.
- Add photos to personalize pet profiles.
- Synchronize pet information across sessions using Cloud Firestore.

### Activity Tracking & Calendar
- Record and manage pet care activities such as feeding, walking, bathroom breaks, and custom events.
- Schedule activities with specific dates and times.
- View upcoming and past events.
- Explore scheduled activities through an interactive calendar.
- Edit or remove existing events.

### Smart Reminders
- Schedule local notifications for upcoming pet care activities on supported mobile platforms.
- Manage notification preferences.
- Store notification settings in Firebase Firestore.

### AI-Powered Pet Insights
- Integrate Google Gemini AI through Firebase AI Logic.
- Analyze recorded pet activities to generate personalized weekly summaries.
- Identify activity patterns and provide practical pet care suggestions.
- Generate insights based on individual pets' activity histories.

### Data Export
- Export pet activity records as CSV files.
- Share or save exported files using platform-supported sharing options.

### Authentication & Data Synchronization
- Secure authentication with Firebase Authentication.
- Support Google Sign-In.
- Store pet profiles and event records in Cloud Firestore.
- Access synchronized account data across supported devices.

## Tech Stack

| Category | Technologies |
|---|---|
| Framework | Flutter, Dart |
| Platforms | iOS, Web |
| Authentication | Firebase Authentication, Google Sign-In |
| Database | Cloud Firestore |
| AI Integration | Firebase AI Logic, Google Gemini |
| Security | Firebase App Check |
| Notifications | flutter_local_notifications |
| Calendar | table_calendar |
| Data Export | share_plus, CSV |
| Navigation | GetX |
| UI | Flutter Material Design |

## Project Structure

```text
furmate/
├── lib/
│   ├── data/                  # Pet and event models
│   ├── screens/               # Application screens
│   ├── services/
│   │   ├── ai/                # Gemini AI integration
│   │   ├── authentication/    # Authentication services
│   │   ├── events/            # Event-related services
│   │   ├── export/            # Data export functionality
│   │   └── settings/          # Notification preferences
│   ├── widgets/               # Reusable UI components
│   ├── firebase_options.dart  # Firebase configuration
│   └── main.dart              # Application entry point
├── assets/                    # Images and icons
├── ios/                       # iOS configuration
├── android/                   # Android configuration
├── web/                       # Web configuration
└── pubspec.yaml
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)
- Xcode for iOS development
- Chrome for web development
- A Firebase project with Authentication and Cloud Firestore configured

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/tpham66/furmate.git
cd furmate
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Configure Firebase**

```bash
flutterfire configure
```

Select the Firebase project and target platforms.

Configure Firebase Authentication, Firestore security rules, and App Check as appropriate for each platform.

**4. Run on iOS**

```bash
flutter run -d ios
```

Alternatively, list available devices using:

```bash
flutter devices
```

Then select an iOS simulator or connected device.

**5. Run on web**

```bash
flutter run -d chrome
```

For web development, ensure Firebase Authentication authorized domains and App Check are configured correctly.

## How AI Insights Work

FurMate uses Firebase AI Logic to communicate with Google Gemini.

1. Retrieve the authenticated user's pet activity records from Cloud Firestore.
2. Filter events by the selected pet and reporting period.
3. Calculate activity counts and prepare a structured prompt.
4. Send the information to Gemini for analysis.
5. Display a personalized summary and practical care suggestions.

AI-generated insights are informational only and are not a substitute for professional veterinary advice.

## Future Improvements

- AI-powered daily routine recommendations.
- Natural-language event creation.
- AI pet care chatbot.
- Weekly activity comparisons and trend visualization.
- Activity completion tracking.
- Improved responsive layouts for desktop browsers.
- Expanded cross-platform notification support.

## Project Status

**Active Development**

FurMate is a personal software development project focused on combining cross-platform application development, cloud services, and generative AI into a practical pet care management system.

## License

License information has not yet been specified.
