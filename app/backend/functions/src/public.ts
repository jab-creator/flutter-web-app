import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const publicChildBySlug = functions.https.onRequest(async (request, response) => {
  // CORS headers
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "GET, OPTIONS");
  response.set("Access-Control-Allow-Headers", "Content-Type");

  if (request.method === "OPTIONS") {
    response.status(204).send("");
    return;
  }

  if (request.method !== "GET") {
    response.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const slug = request.query.slug as string;

    if (!slug) {
      response.status(400).json({ error: "Slug parameter required" });
      return;
    }

    // Get child ID from slug index
    const slugDoc = await admin.firestore().collection("slugIndex").doc(slug).get();
    if (!slugDoc.exists) {
      response.status(404).json({ error: "Gift page not found" });
      return;
    }

    const childId = slugDoc.data()?.childId;

    // Get child and gift page data
    const [childDoc, giftPageDoc] = await Promise.all([
      admin.firestore().collection("children").doc(childId).get(),
      admin.firestore().collection("giftPages").doc(childId).get(),
    ]);

    if (!childDoc.exists || !giftPageDoc.exists) {
      response.status(404).json({ error: "Gift page not found" });
      return;
    }

    const child = childDoc.data();
    const giftPage = giftPageDoc.data();

    // Check if gift page is public
    if (!giftPage?.isPublic) {
      response.status(404).json({ error: "Gift page not found" });
      return;
    }

    // Get recent gifts (last 10, successful only)
    const giftsSnapshot = await admin
      .firestore()
      .collection("gifts")
      .where("childId", "==", childId)
      .where("status", "==", "succeeded")
      .orderBy("createdAt", "desc")
      .limit(10)
      .get();

    const recentGifts = giftsSnapshot.docs.map((doc) => {
      const gift = doc.data();
      return {
        id: doc.id,
        gifterName: gift.gifterName,
        amount: gift.amount,
        message: gift.message,
        createdAt: gift.createdAt,
      };
    });

    // Calculate total raised
    const totalRaised = recentGifts.reduce((sum, gift) => sum + gift.amount, 0);

    response.json({
      child: {
        id: childDoc.id,
        firstName: child?.firstName,
        heroPhotoUrl: child?.heroPhotoUrl,
      },
      giftPage: {
        title: giftPage?.title,
        description: giftPage?.description,
        goalAmount: giftPage?.goalAmount,
        theme: giftPage?.theme,
        isPublic: giftPage?.isPublic,
      },
      totalRaised,
      recentGifts,
      slug,
    });
  } catch (error) {
    functions.logger.error("Public child by slug error", error);
    response.status(500).json({ error: "Internal server error" });
  }
});