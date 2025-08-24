import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';

/// Service for handling slug generation and validation.
class SlugService {
  SlugService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  
  /// Cache for slug availability checks to reduce Firestore calls
  final Map<String, bool> _availabilityCache = {};
  
  /// Timer for debouncing slug availability checks
  Timer? _debounceTimer;

  /// Collection reference for slug index
  CollectionReference<Map<String, dynamic>> get _slugIndex =>
      _firestore.collection('slugIndex');

  /// Generates a base slug from a first name.
  String generateBaseSlug(String firstName) {
    return Child.generateBaseSlug(firstName);
  }

  /// Validates slug format (alphanumeric, lowercase, no spaces).
  bool isValidSlugFormat(String slug) {
    if (slug.isEmpty) return false;
    if (slug.length < 2) return false;
    if (slug.length > 50) return false;
    
    // Only allow lowercase letters, numbers, and hyphens
    final validPattern = RegExp(r'^[a-z0-9-]+$');
    if (!validPattern.hasMatch(slug)) return false;
    
    // Cannot start or end with hyphen
    if (slug.startsWith('-') || slug.endsWith('-')) return false;
    
    // Cannot have consecutive hyphens
    if (slug.contains('--')) return false;
    
    return true;
  }

  /// Checks if a slug is available (not already taken).
  Future<bool> isSlugAvailable(String slug) async {
    if (!isValidSlugFormat(slug)) return false;
    
    // Check cache first
    if (_availabilityCache.containsKey(slug)) {
      return _availabilityCache[slug]!;
    }
    
    try {
      final doc = await _slugIndex.doc(slug).get();
      final isAvailable = !doc.exists;
      
      // Cache the result
      _availabilityCache[slug] = isAvailable;
      
      return isAvailable;
    } catch (e) {
      // If there's an error, assume slug is not available for safety
      return false;
    }
  }

  /// Checks slug availability with debouncing to reduce API calls.
  Future<bool> checkSlugAvailabilityDebounced(
    String slug, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    final completer = Completer<bool>();
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () async {
      final isAvailable = await isSlugAvailable(slug);
      if (!completer.isCompleted) {
        completer.complete(isAvailable);
      }
    });
    
    return completer.future;
  }

  /// Generates a unique slug based on a first name.
  Future<String> generateUniqueSlug(String firstName) async {
    String baseSlug = generateBaseSlug(firstName);
    String candidateSlug = baseSlug;
    int counter = 1;

    while (!(await isSlugAvailable(candidateSlug))) {
      candidateSlug = '$baseSlug$counter';
      counter++;
      
      // Safety check to prevent infinite loops
      if (counter > 1000) {
        throw Exception('Unable to generate unique slug for: $firstName');
      }
    }

    return candidateSlug;
  }

  /// Suggests alternative slugs if the desired one is taken.
  Future<List<String>> suggestAlternativeSlugs(String desiredSlug) async {
    final suggestions = <String>[];
    
    if (await isSlugAvailable(desiredSlug)) {
      return [desiredSlug];
    }
    
    // Generate numbered alternatives
    for (int i = 1; i <= 5; i++) {
      final alternative = '$desiredSlug$i';
      if (await isSlugAvailable(alternative)) {
        suggestions.add(alternative);
      }
    }
    
    // Generate alternatives with common suffixes
    final suffixes = ['2024', 'gift', 'resp', 'fund'];
    for (final suffix in suffixes) {
      final alternative = '$desiredSlug-$suffix';
      if (await isSlugAvailable(alternative)) {
        suggestions.add(alternative);
      }
    }
    
    return suggestions.take(5).toList();
  }

  /// Clears the availability cache.
  void clearCache() {
    _availabilityCache.clear();
  }

  /// Cancels any pending debounce timers.
  void dispose() {
    _debounceTimer?.cancel();
    clearCache();
  }
}