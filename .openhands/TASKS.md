# Task List

1. ✅ Analyze Firestore schema requirements from spec.md
Analyzed spec.md section 2 - need users, children, giftPages, gifts, slugIndex collections
2. ✅ Update User model with Firestore serialization
Added fullName field and Firestore toFirestore/fromFirestore methods
3. ✅ Create Child model with slug generation
Created child_model.dart with slug generation, Firestore serialization, and validation
4. ✅ Create GiftPage model
Created gift_page_model.dart with theme enum and Firestore serialization
5. ✅ Create Gift model with money handling
Created gift_model.dart with amountCents as source of truth, CAD conversion, and status handling
6. ✅ Implement Firestore service
Created comprehensive firestore_service.dart with CRUD operations, slug generation, and real-time streams
7. ✅ Create Firestore security rules
Updated firestore.rules with comprehensive security rules following spec requirements
8. ✅ Create Firestore indexes configuration
Updated firestore.indexes.json with composite indexes for efficient queries
9. 🔄 Create unit tests for all models
Test serialization, validation, and business logic for all data models
10. ⏳ Create Firestore service tests
Test CRUD operations and error handling with Firestore emulator

