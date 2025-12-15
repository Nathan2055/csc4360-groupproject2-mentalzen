const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Scheduled function that runs every 5 minutes to check for reminders
 * and send push notifications to users
 */
exports.sendScheduledNotifications = functions.pubsub
  .schedule('every 5 minutes')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    // Get current time in Eastern Time (America/New_York)
    const now = new Date();
    const easternDate = new Date(now.toLocaleString('en-US', {timeZone: 'America/New_York'}));
    
    // Extract time in HH:MM format
    const hours = easternDate.getHours().toString().padStart(2, '0');
    const minutes = easternDate.getMinutes().toString().padStart(2, '0');
    const currentTime = `${hours}:${minutes}`;
    
    // JavaScript Date.getDay() returns 0-6 (Sunday-Saturday)
    // Convert to 1-7 (Monday-Sunday) format
    const currentDay = easternDate.getDay() === 0 ? 7 : easternDate.getDay();

    console.log(`⏰ Checking reminders at ${currentTime} ET on day ${currentDay}`);

    try {
      // Query all reminders across all users (no filter to avoid index requirement)
      const remindersSnapshot = await db.collectionGroup('reminders').get();

      if (remindersSnapshot.empty) {
        console.log('❌ No reminders found in database');
        return null;
      }

      console.log(`📊 Total reminders in database: ${remindersSnapshot.size}`);

      // Filter enabled reminders in code
      const enabledReminders = remindersSnapshot.docs.filter(doc => {
        const data = doc.data();
        return data.isEnabled === true;
      });

      if (enabledReminders.length === 0) {
        console.log('⚠️  No enabled reminders found');
        return null;
      }

      console.log(`✨ Found ${enabledReminders.length} enabled reminders (out of ${remindersSnapshot.size} total)`);

      for (const reminderDoc of enabledReminders) {
        const reminder = reminderDoc.data();
        const userId = reminder.userId;
        const reminderTime = reminder.time;
        const reminderDays = reminder.daysOfWeek || [];

        // Parse reminder time (HH:MM format)
        const [reminderHour, reminderMinute] = reminderTime.split(':').map(Number);
        const reminderTotalMinutes = reminderHour * 60 + reminderMinute;
        
        // Parse current time
        const [currentHour, currentMinute] = currentTime.split(':').map(Number);
        const currentTotalMinutes = currentHour * 60 + currentMinute;
        
        // Check if time matches (within 5 minute window)
        // e.g., if function runs at 19:52, it checks reminders for 19:50-19:54
        const windowStart = Math.floor(currentTotalMinutes / 5) * 5;
        const windowEnd = windowStart + 5;
        const timeMatches = reminderTotalMinutes >= windowStart && reminderTotalMinutes < windowEnd;

        // Check if day matches
        const daysMatch = reminderDays.includes(currentDay);

        // Debug logging - only log skipped reminders to reduce noise
        if (!timeMatches || !daysMatch) {
          const reason = [];
          if (!timeMatches) reason.push(`Time: ${reminderTime} not in window [${String(Math.floor(windowStart/60)).padStart(2,'0')}:${String(windowStart%60).padStart(2,'0')}-${String(Math.floor(windowEnd/60)).padStart(2,'0')}:${String(windowEnd%60).padStart(2,'0')}]`);
          if (!daysMatch) reason.push(`Day ${currentDay} not in [${reminderDays.join(',')}]`);
          console.log(`⏭️  Skipped: ${userId} - ${reason.join(', ')}`);
        }

        if (timeMatches && daysMatch) {
          console.log(`✅ Processing reminder for user ${userId} at ${reminderTime}`);

          // Get user's FCM token
          const userDoc = await db.collection('users').doc(userId).collection('fcmToken')
          .doc('fcmToken').get();
          if (!userDoc.exists) {
            console.log(`User ${userId} not found, skipping`);
            continue;
          }

          const userData = userDoc.data();
          const fcmToken = userData?.fcmToken;

          if (!fcmToken) {
            console.log(`⚠️  No FCM token for user ${userId}, skipping`);
            continue;
          }

          console.log(`📱 FCM Token found for ${userId}, sending notifications...`);

          // Process each reminder type
          const types = reminder.types || [];
          if (types.length === 0) {
            console.log(`⚠️  No reminder types defined for ${userId}, skipping`);
            continue;
          }

          for (const type of types) {
            const message = generateMessage(type);

            // Create notification job
            const jobRef = db.collection('notification_jobs').doc();
            const jobData = {
              userId: userId,
              type: type,
              title: message.title,
              message: message.body,
              scheduledTime: admin.firestore.Timestamp.now(),
              status: 'pending',
              createdAt: admin.firestore.Timestamp.now(),
            };

            await jobRef.set(jobData);
            console.log(`📋 Created notification job for ${userId}/${type}`);

            // Send FCM message
            try {
              const response = await messaging.send({
                notification: {
                  title: message.title,
                  body: message.body,
                },
                data: {
                  deepLink: `mentalzen://reminder/${type}`,
                  type: type,
                },
                token: fcmToken,
                android: {
                  priority: 'high',
                },
                apns: {
                  headers: {
                    'apns-priority': '10',
                  },
                },
              });

              // Update job status
              await jobRef.update({
                status: 'sent',
                sentAt: admin.firestore.Timestamp.now(),
                fcmMessageId: response,
              });

              console.log(`🔔 Notification sent successfully to ${userId}/${type}: ${response}`);
            } catch (error) {
              console.error(`❌ Error sending notification to ${userId}/${type}: ${error.message}`);
              await jobRef.update({
                status: 'failed',
                error: error.message,
              });
            }
          }
        }
      }

      return null;
    } catch (error) {
      console.error('Error in sendScheduledNotifications:', error);
      throw error;
    }
  });

/**
 * Helper function to generate notification messages based on type
 */
function generateMessage(type) {
  const messages = {
    workout: {
      title: 'Time to Exercise',
      body: "Let's get some movement in today! 💪",
    },
    water: {
      title: 'Stay Hydrated',
      body: 'Remember to drink some water! 💧',
    },
    diet: {
      title: 'Healthy Eating Time',
      body: 'Time for a nutritious meal! 🥗',
    },
    snack: {
      title: 'Snack Time',
      body: 'Grab a healthy snack! 🍎',
    },
  };

  return messages[type] || {
    title: 'Wellness Reminder',
    body: 'Check Mental Zen for your wellness reminder',
  };
}

