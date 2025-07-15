import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class PdfConfigService {
  static final PdfConfigService _instance = PdfConfigService._internal();
  factory PdfConfigService() => _instance;
  PdfConfigService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Logger _logger = Logger();

  /// Get default footer content from Firestore
  Future<String> getDefaultFooter() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final doc =
          await _firestore.collection('pdf_config').doc('default_footer').get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['content'] ?? _getDefaultFooterContent();
      } else {
        // Create default footer if it doesn't exist
        await setDefaultFooter(_getDefaultFooterContent());
        return _getDefaultFooterContent();
      }
    } catch (e) {
      _logger.e('Error getting default footer: $e');
      return _getDefaultFooterContent();
    }
  }

  /// Set default footer content in Firestore
  Future<void> setDefaultFooter(String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('pdf_config').doc('default_footer').set({
        'content': content,
        'updatedBy': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Default footer updated successfully');
    } catch (e) {
      _logger.e('Error setting default footer: $e');
      rethrow;
    }
  }

  /// Get default footer content as a fallback
  String _getDefaultFooterContent() {
    return '''=== Section 1:
Aswini Nagar, North 24 Parganas, 
Deshbandhunagar, 
West Bengal 700159, India
====Section 2:
Registration Number: 279803
www.mytrinix.com
trinixaiprivatelimited@gmail.com
Ph. +87–7459691858''';
  }

  /// Parse footer content into sections
  Map<String, String> parseFooterContent(String content) {
    final lines = content.split('\n');
    String section1 = '';
    String section2 = '';
    bool isSection1 = false;
    bool isSection2 = false;

    for (final line in lines) {
      if (line.trim() == '=== Section 1:') {
        isSection1 = true;
        isSection2 = false;
        continue;
      } else if (line.trim() == '====Section 2:') {
        isSection1 = false;
        isSection2 = true;
        continue;
      }

      if (isSection1 && line.trim().isNotEmpty) {
        section1 += line.trim() + '\n';
      } else if (isSection2 && line.trim().isNotEmpty) {
        section2 += line.trim() + '\n';
      }
    }

    return {'section1': section1.trim(), 'section2': section2.trim()};
  }
}
