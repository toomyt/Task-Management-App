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
- a swipe-to-delete feature on the task bar that prompts a confirmation message before deletion
   
Feature 2: Animation 
- animation whenever tasks are added or removed
  
