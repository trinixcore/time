import 'package:cloud_firestore/cloud_firestore.dart';

class PdfAsset {
  final String id;
  final String type; // 'header', 'footer', 'logo'
  final String label;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PdfAsset({
    required this.id,
    required this.type,
    required this.label,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PdfAsset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PdfAsset(
      id: doc.id,
      type: data['type'] ?? '',
      label: data['label'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'label': label,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
