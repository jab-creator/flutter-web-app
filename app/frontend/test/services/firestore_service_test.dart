import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../lib/services/firestore_service.dart';
import '../../lib/models/user_model.dart';
import '../../lib/models/child_model.dart';
import '../../lib/models/gift_page_model.dart';
import '../../lib/models/gift_model.dart';
import '../../lib/models/slug_index_model.dart';

void main() {
  group('FirestoreService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeFirestore);
    });

    group('User Operations', () {
      test('createUser creates user document', () async {
        final user = User(
          id: 'user-123',
          email: 'test@example.com',
          fullName: 'Test User',
          createdAt: DateTime.now(),
        );

        await firestoreService.createUser(user);

        final doc = await fakeFirestore.collection('users').doc('user-123').get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['email'], equals('test@example.com'));
        expect(doc.data()!['fullName'], equals('Test User'));
      });

      test('getUser returns user when exists', () async {
        final userData = {
          'email': 'test@example.com',
          'fullName': 'Test User',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('users').doc('user-123').set(userData);

        final user = await firestoreService.getUser('user-123');

        expect(user, isNotNull);
        expect(user!.id, equals('user-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.fullName, equals('Test User'));
      });

      test('getUser returns null when user does not exist', () async {
        final user = await firestoreService.getUser('non-existent');

        expect(user, isNull);
      });

      test('updateUser updates existing user', () async {
        final originalUser = User(
          id: 'user-123',
          email: 'test@example.com',
          fullName: 'Test User',
          createdAt: DateTime.now(),
        );
        await firestoreService.createUser(originalUser);

        final updatedUser = originalUser.copyWith(fullName: 'Updated User');
        await firestoreService.updateUser(updatedUser);

        final doc = await fakeFirestore.collection('users').doc('user-123').get();
        expect(doc.data()!['fullName'], equals('Updated User'));
      });

      test('deleteUser removes user document', () async {
        final user = User(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );
        await firestoreService.createUser(user);

        await firestoreService.deleteUser('user-123');

        final doc = await fakeFirestore.collection('users').doc('user-123').get();
        expect(doc.exists, isFalse);
      });
    });

    group('Child Operations', () {
      test('createChild creates child with unique slug', () async {
        final child = Child(
          id: '',
          userId: 'user-123',
          firstName: 'John',
          slug: '',
          createdAt: DateTime.now(),
        );

        final createdChild = await firestoreService.createChild(child);

        expect(createdChild.id, isNotEmpty);
        expect(createdChild.slug, equals('john'));
        expect(createdChild.userId, equals('user-123'));
        expect(createdChild.firstName, equals('John'));

        // Verify child document exists
        final childDoc = await fakeFirestore.collection('children').doc(createdChild.id).get();
        expect(childDoc.exists, isTrue);

        // Verify slug index exists
        final slugDoc = await fakeFirestore.collection('slugIndex').doc('john').get();
        expect(slugDoc.exists, isTrue);
        expect(slugDoc.data()!['childId'], equals(createdChild.id));
      });

      test('createChild generates unique slug when conflict exists', () async {
        // Create first child with 'john' slug
        final child1 = Child(
          id: '',
          userId: 'user-123',
          firstName: 'John',
          slug: '',
          createdAt: DateTime.now(),
        );
        final createdChild1 = await firestoreService.createChild(child1);
        expect(createdChild1.slug, equals('john'));

        // Create second child with same first name
        final child2 = Child(
          id: '',
          userId: 'user-456',
          firstName: 'John',
          slug: '',
          createdAt: DateTime.now(),
        );
        final createdChild2 = await firestoreService.createChild(child2);
        expect(createdChild2.slug, equals('john1'));

        // Verify both slug indexes exist
        final slugDoc1 = await fakeFirestore.collection('slugIndex').doc('john').get();
        final slugDoc2 = await fakeFirestore.collection('slugIndex').doc('john1').get();
        expect(slugDoc1.exists, isTrue);
        expect(slugDoc2.exists, isTrue);
      });

      test('getChild returns child when exists', () async {
        final childData = {
          'userId': 'user-123',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('children').doc('child-123').set(childData);

        final child = await firestoreService.getChild('child-123');

        expect(child, isNotNull);
        expect(child!.id, equals('child-123'));
        expect(child.firstName, equals('John'));
        expect(child.slug, equals('john'));
      });

      test('getChildBySlug returns child when slug exists', () async {
        // Create child
        final childData = {
          'userId': 'user-123',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('children').doc('child-123').set(childData);

        // Create slug index
        final slugData = {'childId': 'child-123'};
        await fakeFirestore.collection('slugIndex').doc('john').set(slugData);

        final child = await firestoreService.getChildBySlug('john');

        expect(child, isNotNull);
        expect(child!.id, equals('child-123'));
        expect(child.firstName, equals('John'));
      });

      test('getChildBySlug returns null when slug does not exist', () async {
        final child = await firestoreService.getChildBySlug('non-existent');

        expect(child, isNull);
      });

      test('getChildrenForUser returns user\'s children', () async {
        // Create children for user
        final child1Data = {
          'userId': 'user-123',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.now(),
        };
        final child2Data = {
          'userId': 'user-123',
          'firstName': 'Jane',
          'slug': 'jane',
          'createdAt': Timestamp.now(),
        };
        final child3Data = {
          'userId': 'user-456',
          'firstName': 'Bob',
          'slug': 'bob',
          'createdAt': Timestamp.now(),
        };

        await fakeFirestore.collection('children').doc('child-1').set(child1Data);
        await fakeFirestore.collection('children').doc('child-2').set(child2Data);
        await fakeFirestore.collection('children').doc('child-3').set(child3Data);

        final children = await firestoreService.getChildrenForUser('user-123');

        expect(children.length, equals(2));
        expect(children.map((c) => c.firstName), containsAll(['John', 'Jane']));
      });

      test('deleteChild removes child and associated data', () async {
        // Create child
        final childData = {
          'userId': 'user-123',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('children').doc('child-123').set(childData);

        // Create slug index
        await fakeFirestore.collection('slugIndex').doc('john').set({'childId': 'child-123'});

        // Create gift page
        final giftPageData = {
          'childId': 'child-123',
          'headline': 'Help John',
          'blurb': 'Save for education',
          'theme': 'default',
          'isPublic': true,
        };
        await fakeFirestore.collection('giftPages').doc('page-123').set(giftPageData);

        await firestoreService.deleteChild('child-123');

        // Verify child is deleted
        final childDoc = await fakeFirestore.collection('children').doc('child-123').get();
        expect(childDoc.exists, isFalse);

        // Verify slug index is deleted
        final slugDoc = await fakeFirestore.collection('slugIndex').doc('john').get();
        expect(slugDoc.exists, isFalse);

        // Verify gift page is deleted
        final giftPageDoc = await fakeFirestore.collection('giftPages').doc('page-123').get();
        expect(giftPageDoc.exists, isFalse);
      });
    });

    group('Gift Page Operations', () {
      test('createGiftPage creates gift page document', () async {
        const giftPage = GiftPage(
          id: '',
          childId: 'child-123',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
          theme: GiftPageTheme.soft,
          isPublic: true,
        );

        final createdGiftPage = await firestoreService.createGiftPage(giftPage);

        expect(createdGiftPage.id, isNotEmpty);
        expect(createdGiftPage.childId, equals('child-123'));
        expect(createdGiftPage.headline, equals('Help John\'s RESP grow'));

        final doc = await fakeFirestore.collection('giftPages').doc(createdGiftPage.id).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['childId'], equals('child-123'));
      });

      test('getGiftPageByChildId returns gift page for child', () async {
        final giftPageData = {
          'childId': 'child-123',
          'headline': 'Help John',
          'blurb': 'Save for education',
          'theme': 'default',
          'isPublic': true,
        };
        await fakeFirestore.collection('giftPages').doc('page-123').set(giftPageData);

        final giftPage = await firestoreService.getGiftPageByChildId('child-123');

        expect(giftPage, isNotNull);
        expect(giftPage!.id, equals('page-123'));
        expect(giftPage.childId, equals('child-123'));
      });

      test('getGiftPagesForUser returns gift pages for user\'s children', () async {
        // Create children
        final child1Data = {
          'userId': 'user-123',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.now(),
        };
        final child2Data = {
          'userId': 'user-123',
          'firstName': 'Jane',
          'slug': 'jane',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('children').doc('child-1').set(child1Data);
        await fakeFirestore.collection('children').doc('child-2').set(child2Data);

        // Create gift pages
        final giftPage1Data = {
          'childId': 'child-1',
          'headline': 'Help John',
          'blurb': 'Save for education',
          'theme': 'default',
          'isPublic': true,
        };
        final giftPage2Data = {
          'childId': 'child-2',
          'headline': 'Help Jane',
          'blurb': 'Save for education',
          'theme': 'soft',
          'isPublic': false,
        };
        await fakeFirestore.collection('giftPages').doc('page-1').set(giftPage1Data);
        await fakeFirestore.collection('giftPages').doc('page-2').set(giftPage2Data);

        final giftPages = await firestoreService.getGiftPagesForUser('user-123');

        expect(giftPages.length, equals(2));
        expect(giftPages.map((p) => p.headline), containsAll(['Help John', 'Help Jane']));
      });
    });

    group('Gift Operations', () {
      test('getGiftsForChild returns gifts for child', () async {
        final gift1Data = {
          'childId': 'child-123',
          'gifterName': 'John Doe',
          'amountCents': 2500,
          'stripePaymentIntent': 'pi_test1',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };
        final gift2Data = {
          'childId': 'child-123',
          'gifterName': 'Jane Smith',
          'amountCents': 5000,
          'stripePaymentIntent': 'pi_test2',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        };
        final gift3Data = {
          'childId': 'child-456',
          'gifterName': 'Bob Wilson',
          'amountCents': 1000,
          'stripePaymentIntent': 'pi_test3',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };

        await fakeFirestore.collection('gifts').doc('gift-1').set(gift1Data);
        await fakeFirestore.collection('gifts').doc('gift-2').set(gift2Data);
        await fakeFirestore.collection('gifts').doc('gift-3').set(gift3Data);

        final gifts = await firestoreService.getGiftsForChild('child-123');

        expect(gifts.length, equals(2));
        expect(gifts.map((g) => g.gifterName), containsAll(['John Doe', 'Jane Smith']));
      });

      test('getSuccessfulGiftsForChild returns only succeeded gifts', () async {
        final gift1Data = {
          'childId': 'child-123',
          'gifterName': 'John Doe',
          'amountCents': 2500,
          'stripePaymentIntent': 'pi_test1',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };
        final gift2Data = {
          'childId': 'child-123',
          'gifterName': 'Jane Smith',
          'amountCents': 5000,
          'stripePaymentIntent': 'pi_test2',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        };
        final gift3Data = {
          'childId': 'child-123',
          'gifterName': 'Bob Wilson',
          'amountCents': 1000,
          'stripePaymentIntent': 'pi_test3',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };

        await fakeFirestore.collection('gifts').doc('gift-1').set(gift1Data);
        await fakeFirestore.collection('gifts').doc('gift-2').set(gift2Data);
        await fakeFirestore.collection('gifts').doc('gift-3').set(gift3Data);

        final gifts = await firestoreService.getSuccessfulGiftsForChild('child-123');

        expect(gifts.length, equals(2));
        expect(gifts.every((g) => g.status == GiftStatus.succeeded), isTrue);
        expect(gifts.map((g) => g.gifterName), containsAll(['John Doe', 'Bob Wilson']));
      });

      test('getTotalRaisedForChild calculates total from successful gifts', () async {
        final gift1Data = {
          'childId': 'child-123',
          'amountCents': 2500, // $25.00
          'stripePaymentIntent': 'pi_test1',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };
        final gift2Data = {
          'childId': 'child-123',
          'amountCents': 5000, // $50.00
          'stripePaymentIntent': 'pi_test2',
          'status': 'pending', // Should not be included
          'createdAt': Timestamp.now(),
        };
        final gift3Data = {
          'childId': 'child-123',
          'amountCents': 1000, // $10.00
          'stripePaymentIntent': 'pi_test3',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };

        await fakeFirestore.collection('gifts').doc('gift-1').set(gift1Data);
        await fakeFirestore.collection('gifts').doc('gift-2').set(gift2Data);
        await fakeFirestore.collection('gifts').doc('gift-3').set(gift3Data);

        final total = await firestoreService.getTotalRaisedForChild('child-123');

        expect(total, equals(35.0)); // $25.00 + $10.00
      });
    });

    group('Utility Methods', () {
      test('isSlugAvailable returns true for available slug', () async {
        final isAvailable = await firestoreService.isSlugAvailable('available-slug');

        expect(isAvailable, isTrue);
      });

      test('isSlugAvailable returns false for taken slug', () async {
        await fakeFirestore.collection('slugIndex').doc('taken-slug').set({'childId': 'child-123'});

        final isAvailable = await firestoreService.isSlugAvailable('taken-slug');

        expect(isAvailable, isFalse);
      });
    });

    group('Stream Methods', () {
      test('watchChildrenForUser streams user\'s children', () async {
        // Create initial children
        final child1Data = {
          'userId': 'user-123',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('children').doc('child-1').set(child1Data);

        final stream = firestoreService.watchChildrenForUser('user-123');
        
        // Listen to first emission
        final children = await stream.first;
        expect(children.length, equals(1));
        expect(children.first.firstName, equals('John'));

        // Add another child and verify stream updates
        final child2Data = {
          'userId': 'user-123',
          'firstName': 'Jane',
          'slug': 'jane',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('children').doc('child-2').set(child2Data);

        // Note: In a real test with actual Firestore, you'd test stream updates
        // FakeFirebaseFirestore has limitations with real-time updates
      });

      test('watchGiftsForChild streams gifts for child', () async {
        final giftData = {
          'childId': 'child-123',
          'gifterName': 'John Doe',
          'amountCents': 2500,
          'stripePaymentIntent': 'pi_test1',
          'status': 'succeeded',
          'createdAt': Timestamp.now(),
        };
        await fakeFirestore.collection('gifts').doc('gift-1').set(giftData);

        final stream = firestoreService.watchGiftsForChild('child-123');
        
        final gifts = await stream.first;
        expect(gifts.length, equals(1));
        expect(gifts.first.gifterName, equals('John Doe'));
      });
    });

    group('Error Handling', () {
      test('handles non-existent document gracefully', () async {
        final user = await firestoreService.getUser('non-existent');
        final child = await firestoreService.getChild('non-existent');
        final giftPage = await firestoreService.getGiftPage('non-existent');
        final gift = await firestoreService.getGift('non-existent');

        expect(user, isNull);
        expect(child, isNull);
        expect(giftPage, isNull);
        expect(gift, isNull);
      });

      test('handles empty collections gracefully', () async {
        final children = await firestoreService.getChildrenForUser('non-existent-user');
        final gifts = await firestoreService.getGiftsForChild('non-existent-child');
        final giftPages = await firestoreService.getGiftPagesForUser('non-existent-user');

        expect(children, isEmpty);
        expect(gifts, isEmpty);
        expect(giftPages, isEmpty);
      });
    });
  });
}