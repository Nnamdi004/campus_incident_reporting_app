# Campus Report

Campus Report is a Flutter application for reporting and managing issues on a
university campus. Students can submit incident reports and follow their
statuses, while staff can review incoming reports and record progress. Report
data and account identity are handled with Firebase; optional report photos are
stored in Supabase Storage.

## What the app does

The app has two role-based experiences:

- **Students** can create an account or sign in, browse reports, submit an issue,
  view status updates, read in-app notifications, and sign out.
- **Staff** can review the report queue, search and filter reports, inspect
  report and submitter details, and update a report's status.

After sign-in, the app reads the user's `role` from the Firestore document
`users/{uid}`. A role of `staff` opens the staff dashboard; other or missing
roles open the student experience.

## Features

### Student experience

- **Account access:** email-and-password registration and sign-in using Firebase
  Authentication. Registration records the name as the Firebase display name.
- **Dashboard:** a greeting, shortcuts to create and browse reports, counts by
  status, and the three most recent reports.
- **Incident submission:** enter a title, category, campus location, and
  description. The title must be at least 5 characters, the location is
  required, and the description must be at least 15 characters.
- **Optional photo:** choose an image from the device gallery. Images larger
  than 5 MB are rejected. The app uploads the image and stores its path with
  the report.
- **Report browser:** search by title, location, or description; filter by
  category and status; open a report to see its description and, when available,
  its photo.
- **Status notifications:** see in-app notifications when a report's status is
  changed, mark an individual notification as read, or mark all as read. The
  dashboard displays an unread count.
- **Profile and sign-out:** view account information and sign out. Profile
  editing, notification preferences, and help/support are presented as
  unavailable placeholders.

### Staff experience

- **Dashboard summary:** counts for total, submitted, in-progress, and resolved
  reports, plus a rejected count alongside the report list.
- **Search and filters:** search by report title, student email, location, or
  category, and filter by status.
- **Report details:** inspect the issue description, location, submission date
  and time, submitter email and ID, and attached photo when available.
- **Status management:** change a report to `Submitted`, `In Progress`,
  `Resolved`, or `Rejected`. The student receives an in-app notification when
  the status actually changes.
- **Sign-out confirmation:** staff are asked to confirm before signing out.

Notifications are stored and displayed inside the app; the current
implementation does not send operating-system push notifications.

## How it works

1. Firebase Authentication maintains the signed-in user and their UID.
2. The app watches `users/{uid}` in Firestore to select the staff or student
   screen.
3. `ReportProvider` subscribes to the Firestore `reports` collection and
   publishes report updates to the UI. Reports are ordered newest first.
4. When a report is submitted, its text fields, initial `Submitted` status,
   student UID/email, creation time, and optional photo path are saved in
   Firestore.
5. If a photo is attached, the app uploads it to the Supabase Storage bucket
   `incident-photos` under a path beginning with the submitting user's UID.
   Screens request a time-limited signed URL to display that photo.
6. When staff changes a report's status, the app updates the Firestore report
   and creates a notification addressed to that report's student.
7. `NotificationProvider` listens for the signed-in user's notifications and
   keeps the unread count current.

### Data stored in Firestore

The application uses these collections:

- **`users/{uid}`** — role data used by the app's role router. Staff accounts
  need a document whose `role` value is `staff`.
- **`reports/{reportId}`** — `title`, `description`, `category`, `location`,
  `status`, `studentId`, `studentEmail`, `photoPath`, and `createdAt`.
- **`notifications/{notificationId}`** — `recipientId`, `reportId`, `title`,
  `message`, `status`, `isRead`, and `createdAt`.

The report categories are Electricity, Water Supply, Sanitation, Damaged
Furniture, Broken Facilities, Campus Safety, and Other. The status values used
by the interface are Submitted, In Progress, Resolved, and Rejected.

## Technology

- [Flutter](https://flutter.dev/) and Dart
- Firebase Core and Firebase Authentication
- Cloud Firestore
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
  and Supabase Storage for optional photos
- Provider for app state
- `image_picker` for selecting a photo
- Material 3, Google Fonts, Flex Color Scheme, Flutter Animate, and Iconsax for
  interface styling and components

## Project layout

The Flutter package is in [`campus_incident_reporting_app/`](./campus_incident_reporting_app/).

```text
campus_incident_reporting_app/
├── lib/
│   ├── main.dart                    # Firebase/Supabase initialization and app routing
│   ├── firebase_options.dart        # FlutterFire platform configuration
│   ├── models/                      # Firestore report and notification models
│   ├── providers/                   # Authentication, report, and notification state
│   ├── screens/
│   │   ├── auth/                    # Sign-in and account creation
│   │   ├── staff/                   # Staff dashboard and report details
│   │   └── student/                 # Student dashboard, reports, form, profile, notifications
│   └── services/
│       └── firestore_service.dart   # Firestore reads, writes, streams, and notifications
└── test/
    └── widget_test.dart             # Widget test for the auth initialization state
```

## Requirements

- Flutter SDK with a Dart SDK compatible with the constraint in
  `campus_incident_reporting_app/pubspec.yaml` (`^3.13.7`).
- A configured Firebase project with Email/Password Authentication and
  Cloud Firestore enabled.
- A Supabase project with an `incident-photos` Storage bucket if photo
  attachments are needed.
- A supported Flutter target and its platform tooling (for example, Android
  Studio/Android SDK for Android or Xcode for iOS).

## Configure and run

1. **Configure Firebase.** Set up a Firebase project, enable Email/Password
   sign-in and Firestore, and configure the required platform app(s) with
   FlutterFire. The app reads Firebase options from
   `campus_incident_reporting_app/lib/firebase_options.dart`; ensure this file
   matches the Firebase project you intend to use.
2. **Configure Supabase Storage.** Create the `incident-photos` bucket and
   configure storage access policies for the app's authentication integration.
   The app uses the Firebase user's ID token when initializing the Supabase
   client. Verify that the token and policies permit the intended uploads and
   signed-URL reads. Photo functionality is not available until this is
   configured.
3. **Provision staff roles.** Create a Firestore document at
   `users/{firebase-auth-uid}` for each staff account and set `role` to `staff`.
   New registrations do not automatically create a staff role document.
4. **Install dependencies and run the app:**

   ```sh
   cd campus_incident_reporting_app
   flutter pub get
   flutter run
   ```

   Select a connected device, emulator, or configured desktop/web target if
   Flutter prompts for one. The repository also includes the usual Flutter
   platform folders.

## Checks

Run these commands from `campus_incident_reporting_app/`:

```sh
flutter analyze
flutter test
```

## Important deployment and access-control notes

- **Configure Firebase Security Rules and Supabase Storage policies before
  deploying.** The role-based screens are client-side navigation, not a
  substitute for backend authorization.
- The current report provider subscribes to the whole Firestore `reports`
  collection, and the student report browser uses that collection feed. Set
  Firestore rules deliberately to determine who may read or change reports;
  do not assume the interface limits students to their own reports.
- The app stores submitter email and UID with each report. Restrict access to
  that information according to campus privacy requirements.
- Use only public/client-safe Firebase and Supabase app configuration in the
  Flutter client. Never include a Firebase Admin service-account key, Supabase
  service-role key, or other server credential in the app or a public
  repository. Keep privileged credentials on a trusted server and rotate any
  that may have been exposed.
- The app must be able to access Firebase and Supabase over the network to
  authenticate, sync report data, upload images, and load signed photo URLs.

## Current scope

This project provides client-side incident intake, report browsing, and staff
status management. It does not currently provide profile editing, report
comments, report deletion, password reset, or push notifications.
