import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/candidate_model.dart';

class CandidateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'candidates';

  /// Get all candidates
  Future<List<Candidate>> getAllCandidates() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Candidate.fromFirestore({...doc.data()!, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch candidates: $e');
    }
  }

  /// Get candidate by ID
  Future<Candidate?> getCandidateById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Candidate.fromFirestore({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch candidate: $e');
    }
  }

  /// Get candidate by candidate ID
  Future<Candidate?> getCandidateByCandidateId(String candidateId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('candidateId', isEqualTo: candidateId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Candidate.fromFirestore({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch candidate by candidate ID: $e');
    }
  }

  /// Get candidates by status
  Future<List<Candidate>> getCandidatesByStatus(String status) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: status)
              .get();

      return querySnapshot.docs
          .map((doc) => Candidate.fromFirestore({...doc.data()!, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch candidates by status: $e');
    }
  }

  /// Get candidates by stage
  Future<List<Candidate>> getCandidatesByStage(String stage) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('currentStage', isEqualTo: stage)
              .get();

      return querySnapshot.docs
          .map((doc) => Candidate.fromFirestore({...doc.data()!, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch candidates by stage: $e');
    }
  }

  /// Create new candidate with auto-generated candidate ID
  Future<Candidate> createCandidate(Candidate candidate) async {
    try {
      // Generate candidate ID if not provided
      String candidateId = candidate.candidateId;
      if (candidateId.isEmpty || candidateId == 'CND2024000001') {
        candidateId = await generateNextCandidateId();
      }

      // Create candidate with the generated ID
      final candidateWithId = candidate.copyWith(
        id: candidateId,
        candidateId: candidateId,
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(candidateWithId.toFirestore());

      return candidateWithId.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create candidate: $e');
    }
  }

  /// Update candidate
  Future<void> updateCandidate(Candidate candidate) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(candidate.id)
          .update(candidate.toFirestore());
    } catch (e) {
      throw Exception('Failed to update candidate: $e');
    }
  }

  /// Delete candidate
  Future<void> deleteCandidate(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete candidate: $e');
    }
  }

  /// Update candidate status
  Future<void> updateCandidateStatus(
    String id,
    String newStatus, {
    String? updatedBy,
  }) async {
    try {
      final updates = {
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
        'lastStageUpdate': DateTime.now().toIso8601String(),
        if (updatedBy != null) 'stageUpdatedBy': updatedBy,
      };

      await _firestore.collection(_collection).doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update candidate status: $e');
    }
  }

  /// Assign employee ID to candidate (after onboarding)
  Future<void> assignEmployeeId(
    String candidateId,
    String employeeId,
    String userId,
  ) async {
    try {
      final updates = {
        'employeeId': employeeId,
        'userId': userId,
        'status': 'onboarded',
        'currentStage': 'onboarded',
        'updatedAt': DateTime.now().toIso8601String(),
        'lastStageUpdate': DateTime.now().toIso8601String(),
      };

      await _firestore.collection(_collection).doc(candidateId).update(updates);
    } catch (e) {
      throw Exception('Failed to assign employee ID: $e');
    }
  }

  /// Generate next candidate ID with pattern CAN-YEAR-6DIGIT (e.g., CAN-2025-000001)
  Future<String> generateNextCandidateId() async {
    try {
      final currentYear = DateTime.now().year;
      final yearPrefix = 'CAN-$currentYear-';

      // Get the last candidate ID for this year
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('candidateId', isGreaterThanOrEqualTo: yearPrefix)
              .where('candidateId', isLessThan: 'CAN-${currentYear + 1}-')
              .orderBy('candidateId', descending: true)
              .limit(1)
              .get();

      int nextSequence = 1;

      if (querySnapshot.docs.isNotEmpty) {
        final lastCandidateId =
            querySnapshot.docs.first.data()['candidateId'] as String;

        // Extract the sequence number from the last candidate ID
        // Format: CAN-2025-000001 -> extract 000001 -> 1
        if (lastCandidateId.startsWith(yearPrefix)) {
          final sequencePart = lastCandidateId.substring(yearPrefix.length);
          final lastSequence = int.tryParse(sequencePart) ?? 0;
          nextSequence = lastSequence + 1;
        }
      }

      // Generate the candidate ID with 6-digit padding
      final candidateId =
          '$yearPrefix${nextSequence.toString().padLeft(6, '0')}';

      return candidateId;
    } catch (e) {
      throw Exception('Failed to generate candidate ID: $e');
    }
  }

  /// Search candidates by name or email
  Future<List<Candidate>> searchCandidates(String query) async {
    try {
      // Search by first name
      final firstNameQuery =
          await _firestore
              .collection(_collection)
              .where('firstName', isGreaterThanOrEqualTo: query)
              .where('firstName', isLessThan: query + '\uf8ff')
              .get();

      // Search by last name
      final lastNameQuery =
          await _firestore
              .collection(_collection)
              .where('lastName', isGreaterThanOrEqualTo: query)
              .where('lastName', isLessThan: query + '\uf8ff')
              .get();

      // Search by email
      final emailQuery =
          await _firestore
              .collection(_collection)
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThan: query + '\uf8ff')
              .get();

      final allDocs = <DocumentSnapshot>[];
      allDocs.addAll(firstNameQuery.docs);
      allDocs.addAll(lastNameQuery.docs);
      allDocs.addAll(emailQuery.docs);

      // Remove duplicates based on document ID
      final uniqueDocs = <String, DocumentSnapshot>{};
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      return uniqueDocs.values
          .map(
            (doc) => Candidate.fromFirestore({
              ...(doc.data() as Map<String, dynamic>),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search candidates: $e');
    }
  }

  /// Get candidates for letter generation (not onboarded yet)
  Future<List<Candidate>> getCandidatesForLetters() async {
    try {
      // NOTE: This query requires a Firestore composite index on employeeId (isNull) and status (isNotEqualTo 'onboarded')
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('employeeId', isNull: true)
              .where('status', isNotEqualTo: 'onboarded')
              .get();

      return querySnapshot.docs
          .map((doc) => Candidate.fromFirestore({...doc.data()!, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch candidates for letters: $e');
    }
  }
}
