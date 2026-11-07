# AggieRide — Flutter Mobile App

> **"Where Aggies Go, Aggies Ride."**  
> Texas A&M Makeathon 2026. A student-powered community mobility network connecting Aggies heading to the same destinations across Bryan and College Station, Texas.

---

## 1. Overview & Architecture

**AggieRide** is a fully functional cross-platform mobile application built with **Flutter** and styled according to **Google Material Design 3 (MD3)** using official **Texas A&M University** visual tokens:
- **Aggie Maroon** (`#500000`)
- **Maroon Light Container** (`#FFD8D6`)
- **Aggie Brass / Sand Accent** (`#8F6A00`)
- **Warm Neutral Surface** (`#FFF8F7`)
- **Status Green & Amber Tokens** (`#15803D`, `#D97706`)

The app features a **Dual-Mode Engine**:
1. **Zero-Config Interactive Demo Mode**: Runs immediately out-of-the-box with pre-seeded Texas A&M data (11 Bryan-College Station routes, 5 student personas, and test requests) stored locally via `SharedPreferences`. Judges and developers can launch and test all features without needing an immediate Firebase project or credentials.
2. **Live Firebase Spark (100% Free Plan) Mode**: By dropping in your `google-services.json` or running `flutterfire configure`, the app seamlessly synchronizes with live Cloud Firestore, Firebase Authentication, and Firebase Cloud Messaging (FCM).

---

## 2. Free-Tier Cloud Architecture (Firebase Spark Plan)

AggieRide is engineered specifically to run entirely on **Firebase's Free Spark Plan** (\$0/month) with zero unexpected billing:

| Service | Spark Free Quota | How AggieRide Optimizes Usage |
| :--- | :--- | :--- |
| **Cloud Firestore** | 50,000 reads / day<br>20,000 writes / day<br>1 GiB stored data | Evaluates email tokens at the rule layer with **zero-read rules**, caches query results locally, and uses client batching. |
| **Firebase Cloud Messaging** | **Unlimited free push notifications** | Direct device targeting via FCM token updates when ride requests or acceptances happen. |
| **Local Notifications** | Completely free on-device | Uses `flutter_local_notifications` for instant sound, heads-up banners, and status alerts. |
| **Firebase Authentication** | Free unlimited email/pass & anonymous | `@tamu.edu` university domain validation. |
| **Firebase Hosting** | 10 GB storage, 360 MB/day transfer | Free web deployment of the Flutter Web build. |

---

## 3. Project File Structure

```
aggie_ride/
├── lib/
│   ├── main.dart                      # App entry point, MultiProvider setup, bottom nav, badges
│   ├── supabase_config.dart           # Supabase Project URL & Anon Key config
│   ├── theme/
│   │   └── app_theme.dart             # Texas A&M Maroon MD3 design tokens & themes
│   ├── models/
│   │   ├── user_model.dart            # TAMU student persona schema with verification flags
│   │   ├── ride_model.dart            # Bryan/CS trip model (route, seats, fuel share, recurring)
│   │   ├── request_model.dart         # Passenger booking request state machine
│   │   └── notification_model.dart    # In-app & push notification payload
│   ├── services/
│   │   ├── supabase_service.dart      # Supabase client, PostgreSQL queries, Realtime, Storage
│   │   ├── firebase_service.dart      # Dual-mode Firestore CRUD, caching, & 1-click seeder
│   │   ├── storage_service.dart       # Photo & vehicle uploads (Supabase Storage / Cloud Storage)
│   │   ├── notification_service.dart  # Flutter local notifications & FCM listener
│   │   └── seed_data_service.dart     # 11 College Station corridors, 5 students, popular spots
│   ├── state/
│   │   └── app_state.dart             # ChangeNotifier reactive state, search/filters, test flows
│   ├── widgets/
│   │   ├── evaluator_banner.dart      # 1-Click Makeathon Test Flow buttons & persona switcher
│   │   ├── ride_card.dart             # MD3 ride card with route pins, driver pill, and seats
│   │   ├── ride_detail_sheet.dart     # Comprehensive trip modal with booking action button
│   │   └── tamu_otp_dialog.dart       # 6-digit @tamu.edu OTP verification modal
│   └── screens/
│       ├── home_screen.dart           # Dashboard, greeting, search, category chips, ride feed
│       ├── find_rides_screen.dart     # Search & filter by origin, destination, seats, dates
│       ├── offer_ride_screen.dart     # Ride creation form, quick Bryan/CS chips, recurring days
│       ├── my_rides_screen.dart       # Driver 'Offering' (requests accordion) & Passenger 'Joining'
│       ├── profile_screen.dart        # Student credentials, rating, stats, safety report modal
│       └── notifications_screen.dart  # In-app real-time notification inbox
├── supabase/
│   └── schema.sql                     # Complete PostgreSQL tables, RLS, storage buckets & seed data
├── storage.rules                      # Cloud Storage security rules for avatars & vehicles
├── firestore.rules                    # Production Firestore rules (Spark plan zero-read model)
├── firestore.indexes.json             # Compound indexes for status & timestamp queries
├── firebase.json                      # Firebase project configuration
└── pubspec.yaml                       # Flutter dependencies
```

---

## 4. How to Run the Flutter App

### Prerequisites
- Flutter SDK 3.0+ installed (`flutter doctor`)
- An iOS simulator, Android emulator, or Chrome browser

### Quick Start
```bash
# 1. Navigate to the app directory
cd aggie_ride

# 2. Get Flutter dependencies
flutter pub get

# 3. Launch on your preferred device:
# For Chrome (Web):
flutter run -d chrome

# For macOS desktop:
flutter run -d macos

# For iOS Simulator:
flutter run -d ios

# For Android Emulator:
flutter run -d android
```

---

## 5. Connecting to Live Cloud Backends

The app has built-in support for **Supabase** (Free PostgreSQL + Realtime + Storage) as well as **Firebase** (Spark Plan).

### Option A: Connecting to Supabase (Recommended — Instant 60-Second Setup)

Supabase gives you a free hosted PostgreSQL database, Realtime subscriptions, and 1 GB file storage with zero organization blocks.

1. **Create a Free Project**: Sign in at [https://supabase.com](https://supabase.com) and create a project.
2. **Run the Database Schema**:
   - Go to your Supabase Dashboard → **SQL Editor** → **New Query**.
   - Copy & paste the contents of [`aggie_ride/supabase/schema.sql`](supabase/schema.sql).
   - Click **Run**. This automatically creates all tables (`users`, `rides`, `requests`, `notifications`), storage buckets (`avatars`, `vehicles`), security policies (RLS), and seeds all 11 College Station routes and student personas!
3. **Paste Your Credentials**:
   - Open [`lib/supabase_config.dart`](lib/supabase_config.dart).
   - Copy your **Project URL** and **anon public key** from Project Settings → API:
     ```dart
     class SupabaseConfig {
       static const String supabaseUrl = 'https://your-project.supabase.co';
       static const String supabaseAnonKey = 'your-anon-key';
     }
     ```
4. Run the app! It will immediately connect to your live Supabase cloud database with full photo storage and realtime sync.

---

### Option B: Connecting to Firebase

1. **Create a Firebase Project** at [https://console.firebase.google.com](https://console.firebase.google.com) (free Spark plan).
2. **Enable Cloud Firestore & Storage**:
   - Deploy the rules provided in this repo:
     ```bash
     firebase deploy --only firestore:rules,firestore:indexes,storage
     ```
3. **Register Your Apps**:
   - Android: Place `google-services.json` in `aggie_ride/android/app/`.
   - iOS: Place `GoogleService-Info.plist` in `aggie_ride/ios/Runner/`.
   - Or run `flutterfire configure`.

---

## 6. The Three Critical Makeathon Demonstration Flows

AggieRide has built-in **1-Click Makeathon Test Flow buttons** at the top of the screen to guide judges through all three required end-to-end user journeys:

### Flow 1: Passenger Finds a Ride
1. Tap the **"Flow 1: Find (Walmart)"** button in the top banner (or select *Carlos Hernandez* from the active persona dropdown).
2. The search bar is automatically queried for **"Walmart"**.
3. Tap on the **Park West → Walmart Supercenter** ride card.
4. Review the full trip sheet: Departure time (Saturday 11 AM), pickup spot (Tower 1 Circle), Maya Reed's verified driver profile (5.0 ⭐, Civic), trunk space notes, and $3 suggested contribution.
5. Tap **"Request to Join Ride"** and submit your note.
6. The app confirms the request and navigates to **My Rides → Rides I'm Joining**, displaying the status as **PENDING**.

### Flow 2: Driver Offers a Ride
1. Tap the **"Flow 2: Offer (H-E-B)"** button in the top banner (switches to *Maya Reed* on the **Offer** tab).
2. The trip form is pre-loaded:
   - Origin: *The Barracks Townhomes* (or tap the quick location chips).
   - Destination: *H-E-B (Jones Crossing)*.
   - Date & Time: *Sunday, Nov 9 at 1:00 PM*.
   - Capacity: *3 Seats*, Suggested fuel contribution: *$2*.
   - Pickup Spot: *Clubhouse Pool Circle*.
   - Recurring toggle: Easily select weekdays (e.g., *Mon, Wed, Fri* for campus commutes).
3. Tap **"Publish Ride to Feed"**.
4. An on-device notification confirms publication, and the new trip immediately appears at the top of the public discovery feed on the Home screen.

### Flow 3: Driver Accepts a Passenger Request
1. Tap the **"Flow 3: Accept Request"** button (switches to driver *Maya Reed* on **My Rides**).
2. Under Maya's *Park West → Walmart* ride, review Carlos Hernandez's incoming request: *"Howdy Maya! Need to grab groceries & snacks for my apartment. Can meet at Tower 1 circle!"*
3. Tap the green **"Accept"** button.
4. Watch the available seat count update from **2 seats to 1 seat**, and see Carlos move into the **Confirmed Passengers** list.
5. An instant notification confirms the seat reservation. Switch back to Carlos from the dropdown to verify that his request status instantly updated to **ACCEPTED / Seat Reserved**!

---

## 7. Safety & Trust Framework

- **`@tamu.edu` University Email Gate**: Only students with verified Texas A&M accounts can offer or request rides.
- **Simulated 6-Digit OTP Verification**: Test account *Sarah Chen* is pre-configured in an unverified state so judges can test the verification modal.
- **Verified Aggie Badge**: Displayed prominently on verified driver and passenger avatars across cards, sheets, and profiles.
- **Transparent Profiles & Ratings**: Displays student major, graduation year, verified car model, rides offered, rides joined, and on-time reliability ratings.
- **Aggie Trust Disclaimer**: The application clarifies that university email verification confirms student email access but is not an official background check or driving record inspection.
- **Report & Flagging Modal**: 1-click modal to report a user or ride concern directly to community moderators.

