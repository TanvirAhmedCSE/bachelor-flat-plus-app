<div align="center">

<br/>

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/BLoC-7B1FA2?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/OneSignal-E54B4B?style=for-the-badge&logo=onesignal&logoColor=white" />
<img src="https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white" />

<br/><br/>

</div>

# BachelorFlat+

A full-featured **Flutter flat management app** built for bachelor roommates — covering meals, expenses, tasks, chat, bazar lists, notices, and a real-time **SOS emergency alert system** with live location tracking. Everything a shared flat needs, in one clean app.

---

## Features

**Authentication & Flat System**
- Email/password registration with Firebase Authentication
- Email verification before accessing the app
- Two registration modes: **Create a new flat** (becomes Admin) or **Join an existing flat** (via Flat Code)
- Auto-generated unique Flat Codes (e.g. `FLAT-A3X9`)
- Admin approval system for join requests — pending members wait until approved
- Soft-delete member removal (data preserved, access revoked)
- Admin transfer between members
- Flat Code clipboard copy for easy sharing

**Home Dashboard**
- Time-aware greeting (Good Morning / Noon / Afternoon / Evening / Night)
- Live stats: today's date, active member count, personal pending task count
- Quick-access 3×3 navigation grid for all features
- Admin badge shown on profile card

**Meal Tracker**
- Spreadsheet-style interactive meal table with per-day per-member input
- Zoomable & scrollable (InteractiveViewer) for large flat sizes
- Per-member bazar contribution tracking (linked from Expense → Grocery)
- Auto-calculated: Total Bazar, Total Meals, Meal Rate, Meal Cost, Balance per member
- Month & year selector with dropdown

**Expense Manager**
- Add expenses with category: Rent, Utility, Grocery, Event, Festival Bonus, Other
- Filter by category, member, and month
- Filtered total shown on a live summary card
- All expenses logged to Activity Log

**Task Manager**
- Create tasks with title, description, due date, and multi-member assignment
- Select All / individual assignment with checkboxes
- Three tabs: **My Pending**, **Others' Tasks**, **Completed**
- Overdue indicator (red due date)
- Per-member completion tracking — task marks "completed" only when all assigned members are done
- Task Details screen with Mark as Done button

**Chat**
- Flat group chat (auto-created on flat setup)
- Private 1-on-1 chats between flat members
- Image sharing via Cloudinary (tap to view fullscreen)
- Chat list with last message preview and timestamp
- New Chat dialog to start private conversations

**Bazar List**
- Create structured grocery/shopping lists with a dynamic table (Product, Weight, Count, Taka columns)
- Add custom columns via dialog
- Auto-calculated Taka total
- Attach multiple images (Cloudinary upload)
- Month filter, edit & view detail screen
- Activity logged on add/update

**Notices**
- Post notices with category: Grocery, Rent, Essentials, Electricity, Water, Gas, Maid Charge, Event, Festival Bonus, Others
- Attach images to notices (Cloudinary)
- Filter by category and month
- Notice detail screen with fullscreen image viewer

**Activity Log**
- Flat-wide activity feed (last 100 entries)
- Filter chips: All, Notices, Expenses, Meals, Bazar List, Tasks Created, Tasks Completed
- "You" badge on own activities
- Icons and colors per activity type

**SOS Emergency Alert 🚨**
- Hold-to-activate SOS button (1-second hold with progress ring animation)
- Sends **OneSignal push notification** to all flat members instantly
- Streams live GPS location to Firestore in real-time (every 10m movement)
- Receivers see a full-screen SOS popup with live coordinates and pulsing location dot
- **flutter_map + OpenStreetMap** for in-app live map tracking (no Google Maps API needed)
- Pulsing red marker on map that animates while SOS is active
- Open in Google Maps or share via WhatsApp
- SOS is cancellable — all receivers see the cancellation instantly
- Alarm sound (`sos_alarm.mp3`) + vibration pattern on both sender and receiver
- Notification tap opens directly to SOS location screen

**Profile & Members**
- Current user card with name, email, role badge, flat name, and copyable Flat Code
- Full member list with Admin badge
- Admin controls: Make Admin, Remove Member
- Pending join requests badge with multi-select approve dialog
- Logout with instant Firestore cache clear

---

## Screenshots

### Log in

<table>
  <tr>
    <td align="center"><img src="app screenshots/1a.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/2a.jpg" width="220"/></td>
  </tr>
</table>

---

### Join Flat

<table>
  <tr>
    <td align="center"><img src="app screenshots/3.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/4.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/5.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/5a.jpg" width="220"/></td>
  </tr>
</table>

---

### Create Flat

<table>
  <tr>
    <td align="center"><img src="app screenshots/6.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/7.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/8.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/9.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/10.jpg" width="220"/></td>
  </tr>
</table>

---

### Meals

<table>
  <tr>
    <td align="center"><img src="app screenshots/11.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/12.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/13.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/14.jpg" width="220"/></td>
  </tr>
</table>

---

### Expenses

<table>
  <tr>
    <td align="center"><img src="app screenshots/15.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/16.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/17.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/18.jpg" width="220"/></td>
  </tr>
</table>

---

### Tasks

<table>
  <tr>
    <td align="center"><img src="app screenshots/19.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/20.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/21.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/22.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/23.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/24.jpg" width="220"/></td>
  </tr>
</table>

---

### Chats

<table>
  <tr>
    <td align="center"><img src="app screenshots/25.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/26.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/27.jpg" width="220"/></td>
  </tr>
</table>

---

### Notices

<table>
  <tr>
    <td align="center"><img src="app screenshots/28.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/28a.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/29.jpg" width="220"/></td>
  </tr>
</table>

---

### Bazar Lists

<table>
  <tr>
    <td align="center"><img src="app screenshots/30.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/31.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/32.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/33.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/34.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/35.jpg" width="220"/></td>
  </tr>
</table>

---

### Activity Log, Profile & Members

<table>
  <tr>
    <td align="center"><img src="app screenshots/36.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/37.jpg" width="220"/></td>
  </tr>

---

### Emergency SOS Help

<table>
  <tr>
    <td align="center"><img src="app screenshots/38.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/39.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/40.jpg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><img src="app screenshots/41.jpg" width="220"/></td>
    <td align="center"><img src="app screenshots/42.jpg" width="220"/></td>
  </tr>
</table>

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | BLoC (`flutter_bloc`) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Cloudinary (images) |
| Push Notifications | OneSignal |
| Maps | flutter_map + OpenStreetMap (no API key needed) |
| Location | Geolocator (live GPS stream) |
| Audio | audioplayers |
| Fonts | Nunito (Google Fonts) |
| Utilities | uuid, intl, image_picker, cached_network_image, vibration, url_launcher |

---

## Architecture

```
lib/
├── main.dart
├── app/
│   ├── app.dart                        # BachelorFlatApp root widget, OneSignal handler
│   └── theme.dart                      # AppColors, AppTheme (Material 3)
├── models/
│   ├── user_model.dart
│   ├── message_model.dart
│   ├── expense_model.dart
│   ├── meal_model.dart
│   ├── task_model.dart
│   ├── notice_model.dart
│   ├── sos_alert_model.dart
│   ├── bazar_list_model.dart
│   └── activity_log_model.dart
├── services/
│   ├── auth_service.dart               # Register (create/join flat), login, logout
│   ├── firestore_service.dart          # All Firestore reads/writes/streams
│   ├── cloudinary_service.dart         # Image upload via unsigned preset
│   └── onesignal_service.dart          # Push notification init & player ID
├── bloc/
│   ├── auth_bloc/                      # Login, logout, email verification
│   ├── home_bloc/                      # User status (active/pending/removed)
│   ├── chat_bloc/                      # Messages stream, send text/image
│   ├── expense_bloc/                   # Expense stream, filters, add
│   ├── meal_bloc/                      # Meal stream, month/year selection
│   ├── task_bloc/                      # Task stream, add, complete
│   ├── notice_bloc/                    # Notice stream, filters, add
│   ├── bazar_bloc/                     # Bazar list stream, month filter
│   └── sos_bloc/                       # Active SOS alerts stream
├── controllers/
│   ├── auth_controller.dart
│   ├── chat_controller.dart
│   ├── expense_controller.dart
│   ├── expense_controller_headless.dart
│   ├── meal_controller.dart
│   ├── notice_controller.dart
│   ├── task_controller.dart
│   ├── bazar_list_controller.dart
│   └── sos_controller.dart             # triggerSos, cancelSos, GPS stream, alarm
└── views/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── verify_email_screen.dart
    ├── home/
    │   └── home_screen.dart
    ├── meal/
    │   └── meal_screen.dart
    ├── expense/
    │   └── expense_screen.dart
    ├── task/
    │   ├── task_screen.dart
    │   └── task_details_screen.dart
    ├── chat/
    │   ├── chat_list_screen.dart
    │   └── chat_screen.dart
    ├── notice/
    │   ├── notice_list_screen.dart
    │   └── notice_details_screen.dart
    ├── bazar/
    │   ├── bazar_list_screen.dart
    │   ├── bazar_list_details_screen.dart
    │   └── create_and_edit_bazar_list_screen.dart
    ├── profile/
    │   └── profile_screen.dart
    ├── activity/
    │   └── activity_screen.dart
    └── sos/
        ├── sos_button.dart
        ├── sos_listener.dart
        └── sos_location_screen.dart
```

**Auth Flow**

```
App Launch
    └── FirebaseAuth.authStateChanges()
            ├── No user              →  LoginScreen
            ├── Not verified         →  VerifyEmailScreen (polls every 3s)
            └── Verified
                    └── HomeBloc loads user
                            ├── status: active   →  HomeScreen (NormalHome)
                            ├── status: pending  →  Waiting for approval screen
                            └── status: removed  →  Submit new join request screen
```

**SOS Flow**

```
User holds SOS button (1s)
    └── SosController.triggerSos()
            ├── Get GPS position
            ├── Create SosAlert doc in Firestore (isActive: true)
            ├── Start alarm + vibration
            ├── Send OneSignal push to all flat members
            └── Start Geolocator.getPositionStream() → update Firestore every 10m

Receiver app (SosListener via SosBloc)
    └── Firestore stream detects new active alert
            ├── Play alarm + vibrate
            └── Show SOS popup dialog
                    └── "View & Track Location" → SosLocationScreen
                                └── StreamBuilder watches Firestore → updates map marker live

Victim cancels SOS
    └── SosController.cancelSos()
            ├── Set isActive: false in Firestore
            ├── Stop GPS stream
            └── Stop alarm + vibration
                    └── Receivers: SosBloc emits SosAlertCancelled → popup auto-dismisses
```

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.x
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled
- A [Cloudinary](https://cloudinary.com) account with an **unsigned upload preset**
- A [OneSignal](https://onesignal.com) account with an Android/iOS app configured

### Setup

1. **Clone the repository**

```bash
git clone https://github.com/TanvirAhmedCSE/bachelor-flat-plus-app.git
cd bachelor-flat-plus-app
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Firebase setup**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Email/Password** authentication
   - Enable **Cloud Firestore**
   - Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) into the correct platform directories
   - Run `flutterfire configure` or manually add your `firebase_options.dart`

4. **Cloudinary setup**
   - Create a free account at [cloudinary.com](https://cloudinary.com)
   - Create an **unsigned upload preset** named `bachelor_flat_plus` (or update `_uploadPreset` in `cloudinary_service.dart`)
   - Update `_cloudName` in `cloudinary_service.dart` with your cloud name

5. **OneSignal setup**
   - Create an app at [onesignal.com](https://onesignal.com) and get your App ID
   - Update `_appId` in `onesignal_service.dart`
   - Update `_oneSignalAppId` and `_oneSignalRestApiKey` in `sos_controller.dart`

6. **Add SOS alarm sound**
   - Place your alarm audio file at `assets/sounds/sos_alarm.mp3`
   - Make sure `pubspec.yaml` includes the assets entry

7. **Run the app**

```bash
flutter run
```

---

## Firestore Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuth() {
      return request.auth != null;
    }
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    function isActiveInFlat(flatId) {
      return isAuth()
        && getUserData().flatId == flatId
        && getUserData().status == 'active';
    }
    function isAdminOfFlat(flatId) {
      return isActiveInFlat(flatId) && getUserData().role == 'admin';
    }

    match /flats/{flatId} {
      allow read: if true;
      allow create: if isAuth();
      allow update: if isActiveInFlat(flatId);
      allow delete: if isAdminOfFlat(flatId);

      match /join_requests/{uid} {
        allow create, update: if isAuth() && request.auth.uid == uid;
        allow read, delete: if isAdminOfFlat(flatId);
      }

      match /{collection}/{docId} {
        allow read, write: if isActiveInFlat(flatId);
        match /messages/{msgId} {
          allow read, write: if isActiveInFlat(flatId);
        }
      }
    }

    match /users/{uid} {
      allow read: if isAuth();
      allow create: if isAuth() && request.auth.uid == uid;
      allow update: if isAuth() && (
        request.auth.uid == uid
        || isAdminOfFlat(resource.data.flatId)
        || isAdminOfFlat(request.resource.data.flatId)
      );
      allow delete: if isAdminOfFlat(resource.data.flatId);
    }
  }
}
```

---

## Key Dependencies

```yaml
firebase_core: ^4.10.0
firebase_auth: ^6.5.0
cloud_firestore: ^6.5.0
image_picker: ^1.1.7
http: ^1.2.2
intl: ^0.20.2
cached_network_image: ^3.3.2
uuid: ^4.5.1
onesignal_flutter: ^5.6.0
geolocator: ^14.0.2
audioplayers: ^6.7.1
vibration: ^3.1.8
url_launcher: ^6.3.2
flutter_bloc: ^9.1.1
flutter_map: ^8.3.0
latlong2: ^0.9.1
```

---

## Security Notes

- Firebase credentials (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) are **not included** in this repository. Configure your own Firebase project.
- OneSignal App ID and REST API key in `sos_controller.dart` and `onesignal_service.dart` should be stored in environment variables or a secrets file in production — do not commit them directly.
- Cloudinary unsigned preset is suitable for development. For production, consider using a signed upload with a backend.
- Firestore rules above enforce flat-level isolation — only active members of a flat can read/write its sub-collections.

---

## License

This project is open-source and available under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ and Flutter by **[TanvirAhmedCSE](https://github.com/TanvirAhmedCSE)**

*If you find this project useful, please give it a ⭐ on GitHub!*

</div>
