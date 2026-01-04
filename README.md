# eSignature App

A comprehensive Flutter application for signing, sealing, and delivering documents digitally. This app allows users to upload PDFs, add interactive fields (signatures, text, dates), publish them for signing, and export the final signed documents.

## Features

**User Authentication**: Secure login and signup using Firebase Auth.
**Document Management**: Upload, view, and manage PDF documents.
**Smart Editor**:
 **Draft Mode**: Save progress at any time and finish later.
 **Drag & Drop Fields**: Add Signature, Text, and Date fields.
 **Resize & Move**: fully interactive field manipulation.
 **Publish Mode**: Lock field positions for signers to fill in.
 **JSON Import/Export**: Save and load field configurations.
**Secure Signing**:
 **Digital Signature**: Draw and upload signatures securely.
 **Signature Locking**: Signatures are permanently locked after saving to ensure integrity.
**PDF Generation**: overlay fields and signatures onto the original PDF and export the final result.
**Dark/Light Mode**: Full Material 3 support.

## Architecture

This project follows a **Feature-based Clean Architecture** combined with **Riverpod** for state management.

```
lib/
├── app/
│   ├── core/           # Core utilities (LocalData, Constants, etc.)
│   ├── feature/        # Feature modules
│   │   ├── authentication/
│   │   ├── document/   # Document listing & management
│   │   ├── editor/     # PDF Editor & Logic
│   │   └── home/
│   ├── route/          # AutoRoute configuration
│   └── theme/          # App Theme & UI Components
└── main.dart
```

### Key Technologies

**State Management**: `flutter_riverpod`
**Navigation**: `auto_route`
**Dependency Injection**: `get_it` (primary), `riverpod` (providers)
**Backend**: `Firebase` (Auth, Firestore, Storage)
**Local Storage**: `shared_preferences`

## Setup Instructions

### Prerequisites

Flutter SDK: `^3.10.0`
Dart SDK: `^3.0.0`
Firebase Account

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/muntasir-ifaz574/e-Signature.git
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Code Generation** (for Routes, Freezed, JsonSerializable):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

## Firebase Configuration

This app requires Firebase for Authentication, Firestore, and Storage.

1.  **Create a Firebase Project**: Go to the [Firebase Console](https://console.firebase.google.com/).
2.  **Add Android App**:
    -   Register app with package name (e.g., `com.example.esignature`).
    -   Download `google-services.json`.
    -   Place it in `android/app/google-services.json`.
3.  **Add iOS App**:
    -   Register app with Bundle ID.
    -   Download `GoogleService-Info.plist`.
    -   Open `ios/Runner.xcworkspace` in Xcode.
    -   Drag and drop the file into the `Runner` folder within Xcode.
4.  **Enable Services**:
    -   **Authentication**: Enable Email/Password provider.
    -   **Firestore**: Create database (Test Mode recommended for dev).
    -   **Storage**: Create storage bucket (Test Mode recommended for dev).

## Key Packages

| Package | Purpose |
| :--- | :--- |
| **flutter_riverpod** | State Management |
| **auto_route** | Navigation & Routing |
| **firebase_core** | Firebase Initialization |
| **cloud_firestore** | NoSQL Database |
| **firebase_storage** | File Storage |
| **pdfx** | PDF Rendering & Viewing |
| **pdf** | PDF Creation |
| **printing** | PDF Printing & Sharing |
| **signature** | Signature Drawing Canvas |
| **file_picker** | File Selection |
| **mocktail** | Testing & Mocking |

## Testing

Run unit and widget tests to verify functionality:

```bash
flutter test
```

Currently implemented tests:
`test/app/feature/document/domain/entity/document_entity_test.dart`: Unit tests for data models.
`test/app/feature/authentication/presentation/view/sign_in_screen_test.dart`: Widget tests for UI components.
