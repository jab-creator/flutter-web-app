import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: "2024-06-20",
});

export const paymentsCheckout = functions.https.onRequest(async (request, response) => {
  // CORS headers
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (request.method === "OPTIONS") {
    response.status(204).send("");
    return;
  }

  if (request.method !== "POST") {
    response.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const { slug, amount, gifterName, gifterEmail, message } = request.body;

    if (!slug || !amount || !gifterName || !gifterEmail) {
      response.status(400).json({ error: "Missing required fields" });
      return;
    }

    // Validate amount (minimum $2.00 CAD)
    if (amount < 200) {
      response.status(400).json({ error: "Minimum gift amount is $2.00 CAD" });
      return;
    }

    // Get child and gift page data
    const slugDoc = await admin.firestore().collection("slugIndex").doc(slug).get();
    if (!slugDoc.exists) {
      response.status(404).json({ error: "Gift page not found" });
      return;
    }

    const childId = slugDoc.data()?.childId;
    const childDoc = await admin.firestore().collection("children").doc(childId).get();
    const giftPageDoc = await admin.firestore().collection("giftPages").doc(childId).get();

    if (!childDoc.exists || !giftPageDoc.exists) {
      response.status(404).json({ error: "Gift page not found" });
      return;
    }

    const child = childDoc.data();
    const giftPage = giftPageDoc.data();

    // Create Stripe checkout session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "cad",
            product_data: {
              name: `RESP Gift for ${child?.firstName}`,
              description: message || `A gift towards ${child?.firstName}'s education`,
            },
            unit_amount: amount,
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: `${functions.config().app.base_url}/thanks?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${functions.config().app.base_url}/for/${slug}`,
      metadata: {
        childId,
        slug,
        gifterName,
        gifterEmail,
        message: message || "",
      },
    });

    response.json({ sessionId: session.id });
  } catch (error) {
    functions.logger.error("Payment checkout error", error);
    response.status(500).json({ error: "Internal server error" });
  }
});