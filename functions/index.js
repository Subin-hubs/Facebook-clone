const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Trigger on new post inside a user's subcollection
exports.sendNotificationOnNewPost = functions.firestore
  .document("users/{userId}/posts/{postId}")
  .onCreate(async (snap, context) => {
    const newPost = snap.data();

    const message = {
      notification: {
        title: "📢 New Post!",
        body: `${newPost.username || "Someone"} posted: ${newPost.caption || ""}`,
      },
      topic: "allUsers",
    };

    await admin.messaging().send(message);
    console.log("✅ Post notification sent to all users");
  });

// Trigger on new reel
exports.sendNotificationOnNewReel = functions.firestore
  .document("users/{userId}/reels/{reelId}")
  .onCreate(async (snap, context) => {
    const newReel = snap.data();

    const message = {
      notification: {
        title: "🎬 New Reel!",
        body: `${newReel.username || "Someone"} shared a reel`,
      },
      topic: "allUsers",
    };

    await admin.messaging().send(message);
    console.log("✅ Reel notification sent to all users");
  });
