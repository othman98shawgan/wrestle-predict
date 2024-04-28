const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  // Replace 'YOUR_PROJECT_ID' with your Firebase project ID
  databaseURL: 'https://wrestle-predict.firebaseio.com',
});

// Get all users
admin
  .auth()
  .listUsers()
  .then((listUsersResult) => {
    // Iterate through each user and delete them
    listUsersResult.users.forEach((userRecord) => {
      admin
        .auth()
        .deleteUser(userRecord.uid)
        .then(() => {
          console.log(`Successfully deleted user: ${userRecord.uid}`);
        })
        .catch((error) => {
          console.error(`Error deleting user: ${userRecord.uid}`, error);
        });
    });
  })
  .catch((error) => {
    console.error('Error listing users:', error);
  });
