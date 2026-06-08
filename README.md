# 📱 flutter_voxlink

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)
![WebRTC](https://img.shields.io/badge/WebRTC-P2P-333333)
![License](https://img.shields.io/badge/License-MIT-green)

A production-ready **peer-to-peer video calling app** built with Flutter, WebRTC & Firebase Firestore — no third-party paid services, 100% free stack.

---

## 📸 Screenshots

> _Add screenshots here after running on real device_

---

## Features

- 🎥 Real-time P2P video calling (no server relay)
- 🔇 Mute / unmute microphone
- 📷 Camera on/off toggle
- 🔄 Front / back camera switch
- 🔊 Speaker toggle
- 🔗 Room ID based call joining
- 🗑️ Auto room cleanup after call ends
- 🌙 Dark theme UI

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | Riverpod 2.x |
| Video / Audio | flutter_webrtc 0.10.x |
| Signaling Server | Firebase Firestore |
| ICE / STUN | Google Free STUN |
| Navigation | GoRouter |
| Permissions | permission_handler |

---

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # STUN server config
│   ├── router/
│   │   └── app_router.dart         # GoRouter setup
│   └── theme/
│       └── app_theme.dart          # Dark theme
├── features/
│   ├── home/
│   │   ├── home_screen.dart        # Room ID create/join UI
│   │   └── home_controller.dart    # Riverpod controller
│   └── call/
│       ├── call_screen.dart        # Full screen video UI
│       ├── call_controller.dart    # WebRTC + call logic
│       ├── call_state.dart         # State model
│       └── widgets/
│           ├── camera_view.dart    # RTCVideoRenderer wrapper
│           └── call_controls.dart  # Mute/cam/flip/end buttons
├── services/
│   ├── webrtc_service.dart         # PeerConnection & streams
│   ├── signaling_service.dart      # Firebase SDP exchange
│   └── permission_service.dart     # Camera/mic permissions
└── models/
    ├── room_model.dart
    └── ice_candidate_model.dart
```

---

## How It Works

```
Phone A (Caller)              Firebase            Phone B (Callee)
      |                           |                      |
      |--- createOffer() -------> |                      |
      |--- ICE candidates ------> |                      |
      |                           | <-- joinRoom() ------|
      |                           | <-- ICE candidates --|
      |<-- answer SDP ----------- |                      |
      |                           |                      |
      |<====== Direct P2P Video Stream ================> |
      |       (Firebase no longer involved)              |
```

1. **Caller** taps "New Call" → Room ID is generated & copied to clipboard
2. Room ID is shared via WhatsApp/SMS to the other person
3. **Callee** pastes Room ID → taps "Join Call"
4. Firebase Firestore handles SDP offer/answer exchange (one-time only)
5. Google STUN discovers public IPs of both devices
6. **Direct P2P connection** established — media flows phone-to-phone

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Firebase account (free)
- Two real physical devices for testing

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/flutter_voxlink.git
cd flutter_voxlink

# 2. Install dependencies
flutter pub get

# 3. Firebase setup
# - Go to console.firebase.google.com
# - Create new project
# - Add Android/iOS app
# - Download google-services.json → place in android/app/
# - Download GoogleService-Info.plist → place in ios/Runner/
# - Enable Firestore Database (test mode)

# 4. Run on real device
flutter run
```

### Firebase Firestore Rules (development only)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## Testing

> iOS Simulator / Android Emulator does **not** support WebRTC camera/mic.
> Always test on **two real physical devices**.

**Steps:**
1. Install app on both devices
2. Device A → tap "New Call Shuru Karo" → Room ID auto-copies
3. Send Room ID to Device B via WhatsApp/SMS
4. Device B → paste Room ID → tap "Call Join Karo"
5. Allow camera and microphone permissions on both

---

## Cost Breakdown

| Service | Plan | Cost |
|---|---|---|
| flutter_webrtc | Open source | Rs. 0 |
| Firebase Firestore | Free Spark tier | Rs. 0 |
| Google STUN server | Free | Rs. 0 |
| **Total** | | **Rs. 0** |

---

## Dependencies

```yaml
flutter_webrtc: ^0.10.0
flutter_riverpod: ^2.5.1
firebase_core: ^3.3.0
cloud_firestore: ^5.3.0
go_router: ^14.2.0
permission_handler: ^11.3.1
uuid: ^4.4.0
```

---

## Roadmap

- [ ] Push notifications for incoming calls
- [ ] Text chat during call
- [ ] Screen sharing
- [ ] Group calls (3+ participants)
- [ ] Call history

---

## License

MIT License — feel free to use in your own projects.

---

## Author

Built as part of a 100 Flutter repos portfolio project.

[![GitHub](https://img.shields.io/badge/GitHub-flutterbysunny-181717?logo=github)](https://github.com/YOUR_USERNAME)
