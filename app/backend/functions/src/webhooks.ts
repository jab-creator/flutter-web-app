import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: "2024-06-20",
});

export const stripeWebhook = functions.https.onRequest(async (request, response) => {
  const sig = request.headers["stripe-signature"] as string;
  const endpointSecret = functions.config().stripe.webhook_secret;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(request.rawBody, sig, endpointSecret);
  } catch (err) {
    functions.logger.error("Webhook signature verification failed", err);
    response.status(400).send(`Webhook Error: ${err}`);
    return;
  }

  try {
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session);
        break;
      case "payment_intent.succeeded":
        await handlePaymentIntentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;
      default:
        functions.logger.info(`Unhandled event type: ${event.type}`);
    }

    response.json({ received: true });
  } catch (error) {
    functions.logger.error("Webhook processing error", error);
    response.status(500).json({ error: "Webhook processing failed" });
  }
});

async function handleCheckoutSessionCompleted(session: Stripe.Checkout.Session) {
  functions.logger.info("Processing checkout session completed", { sessionId: session.id });

  const { childId, slug, gifterName, gifterEmail, message } = session.metadata || {};

  if (!childId || !gifterName || !gifterEmail) {
    functions.logger.error("Missing required metadata in session", { sessionId: session.id });
    return;
  }

  // Create gift record
  const giftData = {
    childId,
    slug,
    gifterName,
    gifterEmail,
    message: message || "",
    amount: session.amount_total || 0,
    currency: session.currency || "cad",
    status: "pending",
    stripeSessionId: session.id,
    stripePaymentIntentId: session.payment_intent,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await admin.firestore().collection("gifts").add(giftData);
  functions.logger.info("Gift record created", { sessionId: session.id, childId });
}

async function handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  functions.logger.info("Processing payment intent succeeded", { paymentIntentId: paymentIntent.id });

  // Find the gift record by payment intent ID
  const giftsSnapshot = await admin
    .firestore()
    .collection("gifts")
    .where("stripePaymentIntentId", "==", paymentIntent.id)
    .limit(1)
    .get();

  if (giftsSnapshot.empty) {
    functions.logger.error("No gift found for payment intent", { paymentIntentId: paymentIntent.id });
    return;
  }

  const giftDoc = giftsSnapshot.docs[0];
  const giftData = giftDoc.data();

  // Update gift status to succeeded
  await giftDoc.ref.update({
    status: "succeeded",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info("Gift status updated to succeeded", {
    giftId: giftDoc.id,
    paymentIntentId: paymentIntent.id,
  });

  // TODO: Send email notifications (will be implemented in separate issue)
  // - Send receipt to gifter
  // - Send notification to parent
}