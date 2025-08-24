import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export all functions
export { paymentsCheckout } from "./payments";
export { publicChildBySlug } from "./public";
export { stripeWebhook } from "./webhooks";

// Health check function
export const healthCheck = functions.https.onRequest((request, response) => {
  functions.logger.info("Health check requested", { structuredData: true });
  response.json({ status: "ok", timestamp: new Date().toISOString() });
});