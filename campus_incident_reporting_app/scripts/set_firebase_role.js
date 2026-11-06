const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const serviceAccount = require('../serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

async function assignAuthenticatedRole() {
  let nextPageToken;

  try {
    do {
      const result = await getAuth().listUsers(1000, nextPageToken);

      for (const user of result.users) {
        const existingClaims = user.customClaims || {};

        await getAuth().setCustomUserClaims(user.uid, {
          ...existingClaims,
          role: 'authenticated',
        });

        console.log(`Updated: ${user.email || user.uid}`);
      }

      nextPageToken = result.pageToken;
    } while (nextPageToken);

    console.log('Successfully assigned authenticated roles!');
  } catch (error) {
    console.error('Error assigning roles:', error);
    process.exitCode = 1;
  }
}

assignAuthenticatedRole();
