const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// HTTP function to delete all users
exports.deleteAllUsers = functions.https.onRequest(async (req, res) => {
  try {
    // Get all users
    const listUsersResult = await admin.auth().listUsers();
    // Iterate through each user and delete them
    await Promise.all(
        // eslint-disable-next-line max-len
        listUsersResult.users.map((userRecord) => admin.auth().deleteUser(userRecord.uid)),
    );
    res.status(200).send("All users have been deleted.");
  } catch (error) {
    console.error("Error deleting users:", error);
    res.status(500).send("An error occurred while deleting users.");
  }
});
