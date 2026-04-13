# Task_Management_App

A task management app on Flutter.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup Instructions
To run this project locally you will need your own Firebase project. The credentials are excluded from source control via .gitignore.

Prerequisites
- Flutter SDK (3.x or later)
- A Firebase account at console.firebase.google.com
- FlutterFire CLI: dart pub global activate flutterfire_cli
- Node.js (for FlutterFire CLI)
  
Steps
1. Clone the repository and run flutter pub get
2. Create a new Firebase project in the Firebase Console
3. Enable Firestore Database in test mode
4. Run: flutterfire configure and follow the prompts
5. Run the app: flutter run
   
Required Dependencies (pubspec.yaml)
- firebase_core: ^3.x.x
- cloud_firestore: ^4.x.x

## Enhanced Features
Feature 1: Swipe-to-delete
- Tasks can be dismissed by swiping left on any task tile. A confirmation dialog appears before the deletion is committed, preventing accidental data loss. If the user cancels, the tile snaps back into place. The delete operation is wired directly to Firestore, so the task is permanently removed from the cloud on confirmation.
   
Feature 2: Animation 
- Tasks animate in and out of the list using a combination of SizeTransition and FadeTransition, driven by AnimatedList. Rather than using StreamBuilder, the app subscribes to the Firestore stream directly via a StreamSubscription in initState, which allows the diff logic to run once per Firestore event without triggering rebuild loops. New tasks slide and fade in from the top, deleted tasks collapse and fade out in place.

## Known Limitations
- Firestore test mode rules expire after 30 days, after which all reads and writes return a permission-denied error until the rules are manually updated.
  
- There is no user authentication, meaning anyone with the Firebase project credentials can read and write all tasks.
  
- The app loads the entire tasks collection on startup with no pagination, which will degrade performance and increase Firestore read costs significantly as the number of tasks grows.
