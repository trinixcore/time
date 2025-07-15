import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/letter_template_model.dart';

class LetterTemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'letter_templates';

  /// Get all letter templates
  Future<List<LetterTemplate>> getAllTemplates() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch letter templates: $e');
    }
  }

  /// Get active templates only
  Future<List<LetterTemplate>> getActiveTemplates() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active templates: $e');
    }
  }

  /// Get templates by type
  Future<List<LetterTemplate>> getTemplatesByType(String type) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('type', isEqualTo: type)
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch templates by type: $e');
    }
  }

  /// Get template by ID
  Future<LetterTemplate?> getTemplateById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;

      return LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch template: $e');
    }
  }

  /// Create new template
  Future<LetterTemplate> createTemplate(LetterTemplate template) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(template.toFirestore());

      return template.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create template: $e');
    }
  }

  /// Update template
  Future<void> updateTemplate(LetterTemplate template) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(template.id)
          .update(template.toFirestore());
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  /// Activate/deactivate template
  Future<void> setTemplateActive(String id, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update template status: $e');
    }
  }

  /// Get default templates for common letter types
  Future<List<LetterTemplate>> getDefaultTemplates() async {
    try {
      final defaultTypes = [
        'Offer Letter',
        'Appointment Letter',
        'Experience Certificate',
        'Relieving Letter',
        'Promotion Letter',
      ];

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('type', whereIn: defaultTypes)
              .where('isActive', isEqualTo: true)
              .orderBy('type')
              .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch default templates: $e');
    }
  }

  /// Search templates by name or type
  Future<List<LetterTemplate>> searchTemplates(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple prefix search on name field
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .get();

      final allTemplates =
          querySnapshot.docs
              .map(
                (doc) =>
                    LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()}),
              )
              .toList();

      return allTemplates.where((template) {
        final searchLower = query.toLowerCase();
        return template.name.toLowerCase().contains(searchLower) ||
            template.type.toLowerCase().contains(searchLower) ||
            template.description?.toLowerCase().contains(searchLower) == true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search templates: $e');
    }
  }

  /// Get templates by category
  Future<List<LetterTemplate>> getTemplatesByCategory(String category) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('category', isEqualTo: category)
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                LetterTemplate.fromFirestore({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch templates by category: $e');
    }
  }
}
