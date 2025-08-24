import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/gift_page_model.dart';
import '../models/gift_model.dart';
import '../models/slug_index_model.dart';

/// Service for interacting with Firestore database.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _children =>
      _firestore.collection('children');
  CollectionReference<Map<String, dynamic>> get _giftPages =>
      _firestore.collection('giftPages');
  CollectionReference<Map<String, dynamic>> get _gifts =>
      _firestore.collection('gifts');
  CollectionReference<Map<String, dynamic>> get _slugIndex =>
      _firestore.collection('slugIndex');

  // User operations
  /// Creates or updates a user document.
  Future<void> createUser(User user) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  /// Gets a user by ID.
  Future<User?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  }

  /// Updates a user document.
  Future<void> updateUser(User user) async {
    await _users.doc(user.id).update(user.toFirestore());
  }

  /// Deletes a user document.
  Future<void> deleteUser(String userId) async {
    await _users.doc(userId).delete();
  }

  // Child operations
  /// Creates a child with a unique slug.
  Future<Child> createChild(Child child) async {
    // Generate unique slug
    final uniqueSlug = await _generateUniqueSlug(child.firstName);
    final childWithSlug = child.copyWith(slug: uniqueSlug);

    // Use a batch to ensure atomicity
    final batch = _firestore.batch();
    
    // Create child document
    final childRef = _children.doc();
    final finalChild = childWithSlug.copyWith(id: childRef.id);
    batch.set(childRef, finalChild.toFirestore());

    // Create slug index entry
    final slugIndexRef = _slugIndex.doc(uniqueSlug);
    final slugIndex = SlugIndex(slug: uniqueSlug, childId: childRef.id);
    batch.set(slugIndexRef, slugIndex.toFirestore());

    await batch.commit();
    return finalChild;
  }

  /// Gets a child by ID.
  Future<Child?> getChild(String childId) async {
    final doc = await _children.doc(childId).get();
    if (!doc.exists) return null;
    return Child.fromFirestore(doc);
  }

  /// Gets a child by slug.
  Future<Child?> getChildBySlug(String slug) async {
    // First get the child ID from slug index
    final slugDoc = await _slugIndex.doc(slug).get();
    if (!slugDoc.exists) return null;
    
    final slugIndex = SlugIndex.fromFirestore(slugDoc);
    return getChild(slugIndex.childId);
  }

  /// Gets all children for a user.
  Future<List<Child>> getChildrenForUser(String userId) async {
    final query = await _children.where('userId', isEqualTo: userId).get();
    return query.docs.map((doc) => Child.fromFirestore(doc)).toList();
  }

  /// Updates a child document.
  Future<void> updateChild(Child child) async {
    await _children.doc(child.id).update(child.toFirestore());
  }

  /// Deletes a child and its associated data.
  Future<void> deleteChild(String childId) async {
    final batch = _firestore.batch();
    
    // Get the child to find its slug
    final child = await getChild(childId);
    if (child != null) {
      // Delete slug index entry
      batch.delete(_slugIndex.doc(child.slug));
      
      // Delete associated gift pages
      final giftPagesQuery = await _giftPages.where('childId', isEqualTo: childId).get();
      for (final doc in giftPagesQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Note: Gifts are typically not deleted as they represent financial records
      // They should be handled separately if needed
    }
    
    // Delete child document
    batch.delete(_children.doc(childId));
    
    await batch.commit();
  }

  // Gift Page operations
  /// Creates a gift page.
  Future<GiftPage> createGiftPage(GiftPage giftPage) async {
    final ref = _giftPages.doc();
    final finalGiftPage = giftPage.copyWith(id: ref.id);
    await ref.set(finalGiftPage.toFirestore());
    return finalGiftPage;
  }

  /// Gets a gift page by ID.
  Future<GiftPage?> getGiftPage(String pageId) async {
    final doc = await _giftPages.doc(pageId).get();
    if (!doc.exists) return null;
    return GiftPage.fromFirestore(doc);
  }

  /// Gets a gift page by child ID.
  Future<GiftPage?> getGiftPageByChildId(String childId) async {
    final query = await _giftPages.where('childId', isEqualTo: childId).limit(1).get();
    if (query.docs.isEmpty) return null;
    return GiftPage.fromFirestore(query.docs.first);
  }

  /// Gets all gift pages for a user's children.
  Future<List<GiftPage>> getGiftPagesForUser(String userId) async {
    // First get user's children
    final children = await getChildrenForUser(userId);
    final childIds = children.map((child) => child.id).toList();
    
    if (childIds.isEmpty) return [];
    
    final query = await _giftPages.where('childId', whereIn: childIds).get();
    return query.docs.map((doc) => GiftPage.fromFirestore(doc)).toList();
  }

  /// Updates a gift page.
  Future<void> updateGiftPage(GiftPage giftPage) async {
    await _giftPages.doc(giftPage.id).update(giftPage.toFirestore());
  }

  /// Deletes a gift page.
  Future<void> deleteGiftPage(String pageId) async {
    await _giftPages.doc(pageId).delete();
  }

  // Gift operations (read-only for client, writes handled by Cloud Functions)
  /// Gets a gift by ID.
  Future<Gift?> getGift(String giftId) async {
    final doc = await _gifts.doc(giftId).get();
    if (!doc.exists) return null;
    return Gift.fromFirestore(doc);
  }

  /// Gets all gifts for a child, ordered by creation date (newest first).
  Future<List<Gift>> getGiftsForChild(String childId) async {
    final query = await _gifts
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) => Gift.fromFirestore(doc)).toList();
  }

  /// Gets successful gifts for a child.
  Future<List<Gift>> getSuccessfulGiftsForChild(String childId) async {
    final query = await _gifts
        .where('childId', isEqualTo: childId)
        .where('status', isEqualTo: 'succeeded')
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) => Gift.fromFirestore(doc)).toList();
  }

  /// Gets the total amount raised for a child (successful gifts only).
  Future<double> getTotalRaisedForChild(String childId) async {
    final gifts = await getSuccessfulGiftsForChild(childId);
    final totalCents = gifts.fold<int>(0, (sum, gift) => sum + gift.amountCents);
    return totalCents / 100.0;
  }

  /// Gets gifts for all of a user's children.
  Future<List<Gift>> getGiftsForUser(String userId) async {
    final children = await getChildrenForUser(userId);
    final childIds = children.map((child) => child.id).toList();
    
    if (childIds.isEmpty) return [];
    
    final query = await _gifts
        .where('childId', whereIn: childIds)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) => Gift.fromFirestore(doc)).toList();
  }

  // Utility methods
  /// Generates a unique slug for a child.
  Future<String> _generateUniqueSlug(String firstName) async {
    String baseSlug = Child.generateBaseSlug(firstName);
    String candidateSlug = baseSlug;
    int counter = 1;

    while (await _slugExists(candidateSlug)) {
      candidateSlug = '$baseSlug$counter';
      counter++;
    }

    return candidateSlug;
  }

  /// Checks if a slug already exists.
  Future<bool> _slugExists(String slug) async {
    final doc = await _slugIndex.doc(slug).get();
    return doc.exists;
  }

  /// Checks if a slug is available.
  Future<bool> isSlugAvailable(String slug) async {
    return !(await _slugExists(slug));
  }

  // Stream methods for real-time updates
  /// Stream of children for a user.
  Stream<List<Child>> watchChildrenForUser(String userId) {
    return _children
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Child.fromFirestore(doc)).toList());
  }

  /// Stream of gifts for a child.
  Stream<List<Gift>> watchGiftsForChild(String childId) {
    return _gifts
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());
  }

  /// Stream of gift page for a child.
  Stream<GiftPage?> watchGiftPageByChildId(String childId) {
    return _giftPages
        .where('childId', isEqualTo: childId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty 
            ? null 
            : GiftPage.fromFirestore(snapshot.docs.first));
  }
}