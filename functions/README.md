# Mental Zen Cloud Functions

This directory contains Firebase Cloud Functions for the Mental Zen app.

## Setup

1. Install dependencies:
```bash
cd functions
npm install
```

2. Deploy functions:
```bash
firebase deploy --only functions
```

## Functions

### sendScheduledNotifications

A scheduled function that runs every 5 minutes to check for reminders and send push notifications.

- Checks all enabled reminders in the `users/{userId}/reminders` subcollection
- Matches current time and day of week
- Sends FCM notifications to users
- Creates notification job records in Firestore

## Firestore Index Required

The function uses a `collectionGroup` query which requires a composite index. Firebase will prompt you to create this index when you first deploy, or you can create it manually in the Firebase Console:

- Collection: `reminders` (collectionGroup)
- Fields: `isEnabled` (Ascending)

## Testing Locally

```bash
npm run serve
```

This starts the Firebase emulator suite for local testing.

