const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

// Read environment variables loaded in Firebase Config context
const SUPABASE_URL = process.env.SUPABASE_URL || "https://your-supabase-project-id.supabase.co";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "placeholder_service_role_key";

/**
 * Auth Triggered Cloud Function.
 * Executed automatically whenever a user registers an account via Firebase Auth.
 * Syncs the user record directly into Supabase's PostgreSQL users table.
 */
exports.syncUserToPostgres = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;

  const fullName = displayName || email.split("@")[0] || "Traveler";
  const userRow = {
    id: uid,
    email: email,
    full_name: fullName,
    role: "user", // Default fallback role
    avatar_url: user.photoURL || null,
  };

  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/users`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "Prefer": "resolution=merge-duplicates"
      },
      body: JSON.stringify(userRow),
    });

    if (!response.ok) {
      const errText = await response.text();
      functions.logger.error("Failed to synchronize user profile row with Supabase:", errText);
      throw new Error(`Supabase profile syncer failed with status: ${response.status}`);
    }

    functions.logger.info(`Successfully synchronized Firebase UID: ${uid} to Supabase users profile table.`);
    return null;
  } catch (error) {
    functions.logger.error("Failed executing user profile database sync trigger:", error);
    throw error;
  }
});

/**
 * HTTPS API Gateway Endpoint.
 * Placeholder for complex transport pricing calculation or railway schedules processing.
 */
exports.queryTransitSchedules = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "GET");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.status(204).send("");
    return;
  }

  const { source, destination, type } = req.query;

  if (!source || !destination) {
    res.status(400).json({ message: "Parameters 'source' and 'destination' are required." });
    return;
  }

  functions.logger.info(`Transit Query received: From ${source} to ${destination} for ${type || "all"}`);

  // Stub response representing structured cloud functions calculations
  res.status(200).json({
    status: "success",
    timestamp: new Date().toISOString(),
    results: [
      {
        id: "cf-route-001",
        mode: type || "train",
        origin: source,
        destination: destination,
        estimatedDurationMinutes: 180,
        basePriceUSD: 25.50
      }
    ]
  });
});
