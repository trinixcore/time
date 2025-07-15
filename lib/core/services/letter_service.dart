import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/letter_model.dart';
import '../models/signature_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/pdf_asset_model.dart';
import 'pdf_asset_service.dart';
import 'pdf_config_service.dart';
import '../utils/initialize_config.dart'; // Add this import

class LetterService {
  static final LetterService _instance = LetterService._internal();
  factory LetterService() => _instance;
  LetterService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  static final Logger _logger = Logger();
  static const Uuid _uuid = Uuid();

  FirebaseFirestore get _firestore => _firebaseService.firestore;
  FirebaseAuth get _auth => _firebaseService.auth;

  // PDF IMMUTABILITY RULES:
  // 1. PDFs can only be uploaded/updated in DRAFT status
  // 2. Once submitted for approval, the PDF path is locked and cannot be changed
  // 3. The final approved PDF is generated only when all signatures are approved
  // 4. After approval, the PDF is completely immutable
  // 5. All PDF operations are logged for audit purposes

  // OpenAI API configuration
  static const String _openAiBaseUrl = 'https://api.openai.com/v1';

  Future<String> _getOpenAIApiKey() async {
    final key = await ConfigInitializer.getOpenAIApiKey();
    if (key == null || key.isEmpty) {
      throw Exception('OpenAI API key is not configured.');
    }
    return key;
  }

  /// Generate letter content using OpenAI GPT
  Future<String> generateLetterContent({
    required String letterType,
    required String employeeName,
    required String employeeEmail,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      _logger.i('Generating letter content for $letterType');

      final prompt = _buildLetterPrompt(
        letterType: letterType,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        additionalContext: additionalContext,
      );

      final apiKey = await _getOpenAIApiKey();

      final response = await http.post(
        Uri.parse('$_openAiBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional HR assistant. Generate formal, professional letter content.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        _logger.i('Letter content generated successfully');
        return content;
      } else {
        _logger.e(
          'OpenAI API error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to generate letter content');
      }
    } catch (e) {
      _logger.e('Error generating letter content: $e');
      // Return a fallback template
      return _getFallbackLetterTemplate(letterType, employeeName);
    }
  }

  /// Generate enhanced letter content using OpenAI with better structure for PDF
  Future<String> generateEnhancedLetterContent({
    required String letterType,
    required String employeeName,
    required String employeeEmail,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      _logger.i('Generating enhanced letter content for $letterType');

      final prompt = _buildEnhancedLetterPrompt(
        letterType: letterType,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        additionalContext: additionalContext,
      );

      final apiKey = await _getOpenAIApiKey();

      final response = await http.post(
        Uri.parse('$_openAiBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a professional HR assistant. Generate formal, professional letter content that will be converted to PDF with embedded signatures.

IMPORTANT FORMATTING RULES:
1. Use clear paragraph breaks with double line spacing
2. Keep paragraphs concise (2-3 sentences max)
3. Use professional, formal language
4. Include all necessary legal and professional details
5. Structure content for easy PDF layout
6. Avoid complex formatting that might break in PDF conversion''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 1500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        _logger.i('Enhanced letter content generated successfully');
        return _formatContentForPdf(content);
      } else {
        _logger.e(
          'OpenAI API error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to generate enhanced letter content');
      }
    } catch (e) {
      _logger.e('Error generating enhanced letter content: $e');
      // Return a fallback template
      return _getEnhancedFallbackTemplate(letterType, employeeName);
    }
  }

  /// Build prompt for OpenAI
  String _buildLetterPrompt({
    required String letterType,
    required String employeeName,
    required String employeeEmail,
    Map<String, dynamic>? additionalContext,
  }) {
    final context = additionalContext ?? {};
    final currentDate = context['currentDate'] ?? '[Current Date]';
    final address = context['address'] ?? '[Address]';
    final cityStateZip = context['cityStateZip'] ?? '[City, State, Zip Code]';
    final companyName = context['companyName'] ?? '[Company Name]';
    final hrContact = context['hrContact'] ?? '[HR Contact Information]';
    final signatoryName = context['signatoryName'] ?? '[Authorized Signatory]';
    final signatoryTitle = context['signatoryTitle'] ?? '[Title]';
    final department = context['department'] ?? '[Department]';
    final position = context['position'] ?? '[Designation]';

    final variableInstruction = '''
You must use all the following variables exactly as provided in the letter:
- employeeName: $employeeName
- employeeEmail: $employeeEmail
- department: $department
- designation: $position
- companyName: $companyName
- address: $address
- cityStateZip: $cityStateZip
- hrContact: $hrContact
- signatoryName: $signatoryName
- signatoryTitle: $signatoryTitle
- currentDate: $currentDate

IMPORTANT: Do NOT use the phrase "Authorized Signatory" or any generic signatory title. Only use the actual signatory’s name and title as provided.
''';

    String header =
        '''Date: $currentDate\n\nTo,\n$employeeName\n$address\n$cityStateZip\n''';
    String footer =
        '''\n\nFor any queries, please contact HR at $hrContact.\n\nBest regards,\n$signatoryName\n$signatoryTitle''';

    switch (letterType.toLowerCase()) {
      case 'offer letter':
        return '''$variableInstruction\n$header
Subject: Offer Letter

Dear $employeeName,

Generate a professional and comprehensive offer letter for $employeeName ($employeeEmail) for the position of $position in $department at $companyName.

Requirements:
- Use the above header and footer.
- Include start date, salary, benefits, and terms.
- Make it formal, professional, and legally appropriate.
- At the end of the letter, include a placeholder for the candidate's signature as follows: "Candidate Signature: ____________________"
$footer''';
      case 'appointment letter':
        return '''$variableInstruction\n$header
Subject: Appointment Letter

Dear $employeeName,

Generate a formal appointment letter for $employeeName ($employeeEmail) for the position of $position in $department at $companyName.

Requirements:
- Use the above header and footer.
- Include appointment details, effective date, reporting structure, and terms.
- Make it formal and comprehensive.
$footer''';
      case 'experience certificate':
        return '''$variableInstruction\n$header
Subject: Experience Certificate

Dear $employeeName,

Generate a professional experience certificate for $employeeName ($employeeEmail) for the position of $position in $department at $companyName.

Requirements:
- Use the above header and footer.
- Include employment period, responsibilities, and achievements.
- Make it suitable for future employment.
$footer''';
      case 'relieving letter':
        return '''$variableInstruction\n$header
Subject: Relieving Letter

Dear $employeeName,

Generate a formal relieving letter for $employeeName ($employeeEmail) for the position of $position in $department at $companyName.

Requirements:
- Use the above header and footer.
- Include employment period, relieving date, and clearance confirmation.
- Make it positive and professional.
$footer''';
      case 'termination letter':
        return '''$variableInstruction\n$header
Subject: Termination Letter

Dear $employeeName,

Generate a formal termination letter for $employeeName ($employeeEmail) for the position of $position in $department at $companyName.

Requirements:
- Use the above header and footer.
- Include employment period, termination date, reason, and final settlement details.
- Make it formal and legally appropriate.
$footer''';
      default:
        return '''$variableInstruction\n$header
Subject: $letterType

Dear $employeeName,

Generate a professional $letterType for $employeeName ($employeeEmail) for the position of $position in $department at $companyName.

Requirements:
- Use the above header and footer.
- Include all relevant details based on letter type.
- Make it formal and comprehensive.
$footer''';
    }
  }

  /// Build enhanced prompt for OpenAI with better structure
  String _buildEnhancedLetterPrompt({
    required String letterType,
    required String employeeName,
    required String employeeEmail,
    Map<String, dynamic>? additionalContext,
  }) {
    final context = additionalContext ?? {};
    final currentDate =
        context['currentDate'] ?? DateTime.now().toString().split(' ')[0];
    final address = context['address'] ?? '[Company Address]';
    final cityStateZip = context['cityStateZip'] ?? '[City, State, Zip Code]';
    final companyName = context['companyName'] ?? '[Company Name]';
    final hrContact = context['hrContact'] ?? '[HR Contact Information]';
    final position = context['position'] ?? '[Designation]';
    final department = context['department'] ?? '[Department]';

    final variableInstruction = '''
You must use all the following variables exactly as provided in the letter:
- employeeName: $employeeName
- employeeEmail: $employeeEmail
- department: $department
- designation: $position
- companyName: $companyName
- address: $address
- cityStateZip: $cityStateZip
- hrContact: $hrContact
- currentDate: $currentDate

IMPORTANT: Do NOT use the phrase "Authorized Signatory" or any generic signatory title. Only use the actual signatory’s name and title as provided.
''';

    String header = '''Date: $currentDate

To:
$employeeName
$address
$cityStateZip

Subject: $letterType

Dear $employeeName,''';

    String footer = '''

For any queries, please contact HR at $hrContact.

Best regards,

[Authorized Signatory Name]
[Position]''';

    switch (letterType.toLowerCase()) {
      case 'offer letter':
        return '''$variableInstruction\n$header

We are pleased to offer you the position of $position in the $department at $companyName.

This offer is contingent upon the successful completion of all pre-employment requirements including background verification and reference checks.

Key Terms of Employment:
• Position: $position
• Department: $department
• Start Date: [To be determined]
• Employment Type: [Full-time/Part-time/Contract]
• Reporting Structure: [Direct Supervisor]

Compensation and Benefits:
• Base Salary: [To be discussed]
• Benefits Package: [Health, Dental, Vision, etc.]
• Leave Policy: [As per company policy]
• Working Hours: [Standard business hours]

Please review this offer carefully. If you accept this offer, please sign and return a copy of this letter within [X] days.

At the end of the letter, include a placeholder for the candidate's signature as follows: "Candidate Signature: ____________________"

$footer''';

      case 'appointment letter':
        return '''$variableInstruction\n$header

We are pleased to confirm your appointment to the position of $position in the $department at $companyName.

Appointment Details:
• Position: $position
• Department: $department
• Effective Date: [Date of appointment]
• Employment Type: [Full-time/Part-time/Contract]
• Reporting To: [Direct Supervisor]

Your responsibilities will include:
• [Key responsibility 1]
• [Key responsibility 2]
• [Key responsibility 3]

We look forward to your valuable contribution to our organization.

$footer''';

      case 'experience certificate':
        return '''$variableInstruction\n$header

This is to certify that $employeeName has been employed with $companyName in the capacity of $position in the $department.

Employment Details:
• Position: $position
• Department: $department
• Employment Period: [Start Date] to [End Date]
• Employment Type: [Full-time/Part-time/Contract]

During their tenure, $employeeName has demonstrated:
• Professional competence and dedication
• Strong work ethics and team collaboration
• Consistent performance and reliability

This certificate is issued for official purposes and can be used for future employment opportunities.

$footer''';

      case 'relieving letter':
        return '''$variableInstruction\n$header

This letter confirms that $employeeName has been relieved from their duties as $position in the $department at $companyName.

Relieving Details:
• Position: $position
• Department: $department
• Employment Period: [Start Date] to [End Date]
• Relieving Date: [Date of relieving]
• Clearance Status: All company property has been returned and accounts have been settled

We thank $employeeName for their valuable contribution to our organization and wish them success in their future endeavors.

$footer''';

      case 'termination letter':
        return '''$variableInstruction\n$header

This letter serves as formal notice of termination of your employment with $companyName.

Termination Details:
• Position: $position
• Department: $department
• Employment Period: [Start Date] to [End Date]
• Termination Date: [Date of termination]
• Reason for Termination: [As per company policy]

Final Settlement:
• All pending dues will be processed as per company policy
• Please complete the exit formalities and return company property
• Final settlement will be processed within [X] working days

$footer''';

      default:
        return '''$variableInstruction\n$header

This letter serves as a formal $letterType from $companyName.

Letter Details:
• Employee: $employeeName
• Position: $position
• Department: $department
• Date: $currentDate

[Letter content will be generated based on the specific type and requirements]

$footer''';
    }
  }

  /// Format content for better PDF layout
  String _formatContentForPdf(String content) {
    // Ensure proper spacing for PDF layout
    return content
        .replaceAll('\n\n', '\n\n') // Ensure double line breaks
        .replaceAll('•', '• ') // Add space after bullet points
        .trim();
  }

  /// Get fallback template if GPT fails
  String _getFallbackLetterTemplate(String letterType, String employeeName) {
    final date = DateTime.now().toString().split(' ')[0];

    return '''
Date: $date

To,
$employeeName

Subject: $letterType

Dear $employeeName,

This letter serves as a formal $letterType from our organization.

[Letter content will be generated here based on the specific type and requirements]

We appreciate your understanding and cooperation in this matter.

Best regards,

[Authorized Signatory Name]
[Position]
[Company Name]
[Contact Information]
''';
  }

  /// Get enhanced fallback template
  String _getEnhancedFallbackTemplate(String letterType, String employeeName) {
    final date = DateTime.now().toString().split(' ')[0];

    return '''Date: $date

To:
$employeeName

Subject: $letterType

Dear $employeeName,

This letter serves as a formal $letterType from our organization.

[Letter content will be generated based on the specific type and requirements]

We appreciate your understanding and cooperation in this matter.

Best regards,

[Authorized Signatory Name]
[Position]
[Company Name]
[Contact Information]''';
  }

  /// Create a new letter
  Future<Letter> createLetter({
    required String type,
    required String employeeName,
    required String employeeEmail,
    required List<String> signatureAuthorityUids,
    String? content,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final letterId = _uuid.v4();
      final now = DateTime.now();

      // Generate enhanced content if not provided
      final letterContent =
          content ??
          await generateEnhancedLetterContent(
            letterType: type,
            employeeName: employeeName,
            employeeEmail: employeeEmail,
            additionalContext: additionalContext,
          );

      final letter = Letter(
        id: letterId,
        type: type,
        content: letterContent,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        createdBy: user.uid,
        signatureAuthorityUids: signatureAuthorityUids,
        letterStatus: const LetterStatus.draft(),
        signatureStatus: const SignatureStatus.pending(),
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('letters').doc(letterId).set(letter.toJson());

      _logger.i('Letter created successfully: $letterId');
      return letter;
    } catch (e) {
      _logger.e('Error creating letter: $e');
      rethrow;
    }
  }

  /// Get all letters for current user
  Future<List<Letter>> getLetters({String? status}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      Query query = _firestore.collection('letters');

      // Filter by status if provided
      if (status != null) {
        query = query.where('letterStatus', isEqualTo: status);
      }

      final snapshot = await query.get();
      final letters =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Letter.fromJson(data);
          }).toList();

      return letters;
    } catch (e) {
      _logger.e('Error fetching letters: $e');
      rethrow;
    }
  }

  /// Get letter by ID
  Future<Letter?> getLetter(String letterId) async {
    try {
      final doc = await _firestore.collection('letters').doc(letterId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return Letter.fromJson(data);
    } catch (e) {
      _logger.e('Error fetching letter: $e');
      rethrow;
    }
  }

  /// Update letter
  Future<void> updateLetter(Letter letter) async {
    try {
      // IMMUTABILITY CHECK: Prevent changing signedPdfPath for non-draft letters
      final existingLetter = await getLetter(letter.id);
      if (existingLetter != null &&
          !existingLetter.isDraft &&
          letter.signedPdfPath != existingLetter.signedPdfPath) {
        // SPECIAL CASE: Allow PDF path update when transitioning from pending to approved (final approval)
        final isFinalApproval =
            existingLetter.isPendingApproval &&
            letter.isApproved &&
            letter.signedPdfPath != null &&
            letter.signedPdfPath!.isNotEmpty;

        if (!isFinalApproval) {
          _logger.w(
            'Attempted to change signedPdfPath for non-draft letter ${letter.id}. Blocked for immutability.',
          );
          throw Exception(
            'Cannot modify PDF path for non-draft letters. PDF is immutable after submission.',
          );
        } else {
          _logger.i(
            'Allowing PDF path update for final approval of letter ${letter.id}',
          );
        }
      }

      // Convert signature approvals to JSON for Firestore
      final signatureApprovalsJson =
          letter.signatureApprovals
              .map((approval) => approval.toJson())
              .toList();

      await _firestore.collection('letters').doc(letter.id).update({
        ...letter.toJson(),
        'signatureApprovals': signatureApprovalsJson,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.i('Letter updated successfully: ${letter.id}');
    } catch (e) {
      _logger.e('Error updating letter: $e');
      rethrow;
    }
  }

  /// Update letter with final approval (bypasses immutability check for final PDF)
  Future<void> updateLetterWithFinalApproval(Letter letter) async {
    try {
      _logger.i('Updating letter with final approval: ${letter.id}');

      // Convert signature approvals to JSON for Firestore
      final signatureApprovalsJson =
          letter.signatureApprovals
              .map((approval) => approval.toJson())
              .toList();

      await _firestore.collection('letters').doc(letter.id).update({
        ...letter.toJson(),
        'signatureApprovals': signatureApprovalsJson,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.i(
        'Letter updated with final approval successfully: ${letter.id}',
      );
    } catch (e) {
      _logger.e('Error updating letter with final approval: $e');
      rethrow;
    }
  }

  /// Submit letter for approval
  Future<void> submitForApproval(String letterId) async {
    try {
      //print('[SUBMIT] submitForApproval called for letterId=$letterId');
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');
      //print(
      // '[SUBMIT] Letter loaded: id=${letter.id}, status=${letter.letterStatus}, signedPdfPath=${letter.signedPdfPath}',
      //);

      // Initialize signature approvals for each signature authority
      final signatureApprovals = <SignatureApproval>[];
      final now = DateTime.now();

      for (final signatureId in letter.signatureAuthorityUids) {
        final signature = await getSignature(signatureId);
        if (signature != null) {
          final approval = SignatureApproval(
            signatureId: signatureId,
            signatureOwnerUid: signature.ownerUid,
            signatureOwnerName: signature.ownerName,
            signatureTitle: signature.title ?? 'Unknown',
            status: const SignatureStatus.pending(),
            createdAt: now,
            updatedAt: now,
          );
          signatureApprovals.add(approval);
        }
      }

      String pdfPath;
      // Lock the PDF file path: if it exists, never overwrite or change it after submission
      if (letter.signedPdfPath != null && letter.signedPdfPath!.isNotEmpty) {
        //print(
        //  '[SUBMIT] Using locked PDF from draft save: ${letter.signedPdfPath}',
        //);
        pdfPath = letter.signedPdfPath!;
      } else {
        //print(
        //  '[SUBMIT] No existing PDF found, generating new PDF for submission...',
        //);
        final pdfBytes = await _generateSignedPdf(letter);
        //print('[SUBMIT] PDF generated: size=${pdfBytes.length}');
        pdfPath = await uploadFinalApprovedPdf(letter.id, pdfBytes);
        //print('[SUBMIT] PDF uploaded: path=$pdfPath');
      }

      final updatedLetter = letter.copyWith(
        letterStatus: const LetterStatus.pendingApproval(),
        submittedForApprovalAt: DateTime.now(),
        updatedAt: DateTime.now(),
        signatureApprovals: signatureApprovals,
        signedPdfPath: pdfPath, // Never change after submission
      );

      //print(
      //  '[SUBMIT] Updating letter in Firestore with locked signedPdfPath=$pdfPath',
      //);
      await updateLetter(updatedLetter);
      _logger.i('Letter submitted for approval: $letterId');
      print('[SUBMIT] submitForApproval complete for letterId=$letterId');
    } catch (e) {
      _logger.e('Error submitting letter for approval: $e');
      print('[SUBMIT] ERROR: $e');
      rethrow;
    }
  }

  /// Approve individual signature for a letter
  Future<void> approveIndividualSignature(
    String letterId,
    String signatureId,
    String approvedBy,
    String approvedByName,
  ) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      _logApprovalState(letter, 'Before approval');

      // Find the signature approval to update
      final approvalIndex = letter.signatureApprovals.indexWhere(
        (approval) => approval.signatureId == signatureId,
      );

      if (approvalIndex == -1) {
        throw Exception(
          'Signature approval not found for signature: $signatureId',
        );
      }

      // Update the specific signature approval
      final updatedApproval = letter.signatureApprovals[approvalIndex].copyWith(
        status: const SignatureStatus.approved(),
        approvedAt: DateTime.now(),
        approvedBy: approvedBy,
        approvedByName: approvedByName,
        updatedAt: DateTime.now(),
      );

      final updatedApprovals = List<SignatureApproval>.from(
        letter.signatureApprovals,
      );
      updatedApprovals[approvalIndex] = updatedApproval;

      // Check if all signatures are now approved
      final allApproved = updatedApprovals.every(
        (approval) =>
            approval.status.toString() == 'SignatureStatus.approved()',
      );

      // Check if any signature is rejected
      final anyRejected = updatedApprovals.any(
        (approval) =>
            approval.status.toString() == 'SignatureStatus.rejected()',
      );

      // Check if there are still pending signatures
      final hasPendingSignatures = updatedApprovals.any(
        (approval) => approval.status.toString() == 'SignatureStatus.pending()',
      );

      LetterStatus newLetterStatus = letter.letterStatus;
      SignatureStatus newSignatureStatus = letter.signatureStatus;
      DateTime? approvedAt = letter.approvedAt;
      DateTime? rejectedAt = letter.rejectedAt;

      if (allApproved) {
        // All signatures approved - mark letter as approved
        newLetterStatus = const LetterStatus.approved();
        newSignatureStatus = const SignatureStatus.approved();
        approvedAt = DateTime.now();

        //print(
        //  '🔍 [APPROVAL DEBUG] All signatures approved, checking for existing PDF...',
        //);

        String pdfPath = letter.signedPdfPath ?? '';
        if (pdfPath.isEmpty) {
          // Only generate and upload if no PDF exists
          //print(
          //  '🔍 [APPROVAL DEBUG] No existing PDF found, generating final PDF...',
          //);
          final pdfBytes = await _generateSignedPdf(letter);
          //print(
          //  '🔍 [APPROVAL DEBUG] Final PDF generated, size: ${pdfBytes.length} bytes',
          //);
          pdfPath = await uploadFinalApprovedPdf(letterId, pdfBytes);
          //print('🔍 [APPROVAL DEBUG] Final PDF uploaded to path: $pdfPath');
        } else {
          print('🔍 [APPROVAL DEBUG] Using existing locked PDF: $pdfPath');
        }

        final updatedLetter = letter.copyWith(
          letterStatus: newLetterStatus,
          signatureStatus: newSignatureStatus,
          signatureApprovals: updatedApprovals,
          signedPdfPath: pdfPath,
          storedIn: 'supabase.process',
          approvedAt: approvedAt,
          updatedAt: DateTime.now(),
        );

        // Use the special method for final approval to bypass immutability check
        await updateLetterWithFinalApproval(updatedLetter);
        //print(
        //  '🔍 [APPROVAL DEBUG] Letter updated with final PDF path: $pdfPath',
        //);
        _logger.i('All signatures approved for letter: $letterId');
      } else if (anyRejected) {
        // Any signature rejected - mark letter as rejected
        newLetterStatus = const LetterStatus.rejected();
        newSignatureStatus = const SignatureStatus.rejected();
        rejectedAt = DateTime.now();

        final updatedLetter = letter.copyWith(
          letterStatus: newLetterStatus,
          signatureStatus: newSignatureStatus,
          signatureApprovals: updatedApprovals,
          rejectedAt: rejectedAt,
          updatedAt: DateTime.now(),
        );

        await updateLetter(updatedLetter);
        _logger.i('Letter rejected due to signature rejection: $letterId');
      } else if (hasPendingSignatures) {
        // Still have pending signatures - keep letter in pending status
        // This is the key change: maintain pending status until ALL signatures are approved
        newLetterStatus = const LetterStatus.pendingApproval();
        newSignatureStatus = const SignatureStatus.pending();

        // Don't change approvedAt or rejectedAt - keep them null until final decision

        final updatedLetter = letter.copyWith(
          letterStatus: newLetterStatus,
          signatureStatus: newSignatureStatus,
          signatureApprovals: updatedApprovals,
          updatedAt: DateTime.now(),
        );

        await updateLetter(updatedLetter);
        _logger.i(
          'Individual signature approved for letter: $letterId - still pending other approvals',
        );
      } else {
        // This should not happen, but handle it gracefully
        _logger.w('Unexpected approval state for letter: $letterId');

        final updatedLetter = letter.copyWith(
          signatureApprovals: updatedApprovals,
          updatedAt: DateTime.now(),
        );

        await updateLetter(updatedLetter);
        _logger.i('Individual signature approved for letter: $letterId');
      }

      // Log the final state after approval
      final finalLetter = await getLetter(letterId);
      if (finalLetter != null) {
        _logApprovalState(finalLetter, 'After approval');
      }
    } catch (e) {
      _logger.e('Error approving individual signature: $e');
      rethrow;
    }
  }

  /// Reject individual signature for a letter
  Future<void> rejectIndividualSignature(
    String letterId,
    String signatureId,
    String rejectedBy,
    String rejectedByName,
    String reason,
  ) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      // Find the signature approval to update
      final approvalIndex = letter.signatureApprovals.indexWhere(
        (approval) => approval.signatureId == signatureId,
      );

      if (approvalIndex == -1) {
        throw Exception(
          'Signature approval not found for signature: $signatureId',
        );
      }

      // Update the specific signature approval
      final updatedApproval = letter.signatureApprovals[approvalIndex].copyWith(
        status: const SignatureStatus.rejected(),
        rejectedAt: DateTime.now(),
        rejectionReason: reason,
        updatedAt: DateTime.now(),
      );

      final updatedApprovals = List<SignatureApproval>.from(
        letter.signatureApprovals,
      );
      updatedApprovals[approvalIndex] = updatedApproval;

      // Mark letter as rejected since any rejection means the letter is rejected
      final updatedLetter = letter.copyWith(
        letterStatus: const LetterStatus.rejected(),
        signatureStatus: const SignatureStatus.rejected(),
        signatureApprovals: updatedApprovals,
        rejectionReason: reason,
        rejectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await updateLetter(updatedLetter);
      _logger.i('Individual signature rejected for letter: $letterId');
    } catch (e) {
      _logger.e('Error rejecting individual signature: $e');
      rethrow;
    }
  }

  /// Get letters pending approval for a specific user
  Future<List<Letter>> getLettersPendingUserApproval(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot =
          await _firestore
              .collection('letters')
              .where('letterStatus', isEqualTo: 'pending_approval')
              .get();

      final letters =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Letter.fromJson(data);
          }).toList();

      // Filter letters where the current user can approve
      return letters.where((letter) => letter.canUserApprove(userId)).toList();
    } catch (e) {
      _logger.e('Error fetching letters pending user approval: $e');
      rethrow;
    }
  }

  /// Get approval status for a specific user on a letter
  Future<SignatureApproval?> getUserApprovalStatus(
    String letterId,
    String userId,
  ) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) return null;

      return letter.signatureApprovals.firstWhere(
        (approval) => approval.signatureOwnerUid == userId,
        orElse: () => throw Exception('No approval found for user: $userId'),
      );
    } catch (e) {
      _logger.e('Error getting user approval status: $e');
      return null;
    }
  }

  /// Mark letter as sent
  Future<void> markAsSent(
    String letterId, {
    String? sentVia,
    String? sentTo,
  }) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      final updatedLetter = letter.copyWith(
        letterStatus: const LetterStatus.sent(),
        sentVia: sentVia ?? 'email',
        sentTo: sentTo,
        sentAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await updateLetter(updatedLetter);
      _logger.i('Letter marked as sent: $letterId');
    } catch (e) {
      _logger.e('Error marking letter as sent: $e');
      rethrow;
    }
  }

  /// Mark letter as accepted
  Future<void> markAsAccepted(String letterId) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      final updatedLetter = letter.copyWith(
        letterStatus: const LetterStatus.accepted(),
        acceptedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await updateLetter(updatedLetter);
      _logger.i('Letter marked as accepted: $letterId');
    } catch (e) {
      _logger.e('Error marking letter as accepted: $e');
      rethrow;
    }
  }

  /// Move rejected letter back to draft status
  Future<void> moveToDraft(String letterId) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      // Only allow moving rejected letters to draft
      if (!letter.isRejected) {
        throw Exception('Only rejected letters can be moved to draft');
      }

      final updatedLetter = letter.copyWith(
        letterStatus: const LetterStatus.draft(),
        signatureStatus: const SignatureStatus.pending(),
        rejectedAt: null, // Clear rejection timestamp
        rejectionReason: null, // Clear rejection reason
        updatedAt: DateTime.now(),
      );

      await updateLetter(updatedLetter);
      _logger.i('Letter moved to draft: $letterId');
    } catch (e) {
      _logger.e('Error moving letter to draft: $e');
      rethrow;
    }
  }

  /// Generate signed PDF with multiple signatures
  Future<Uint8List> _generateSignedPdf(Letter letter) async {
    print('[PDFGEN] _generateSignedPdf called for letterId=${letter.id}');
    try {
      // Get all signatures for this letter
      final signatures = <Signature>[];
      for (final signatureId in letter.signatureAuthorityUids) {
        final signature = await getSignature(signatureId);
        if (signature != null) {
          signatures.add(signature);
        }
      }

      if (signatures.isEmpty) {
        _logger.w('No signatures found for letter ${letter.id}');
        // Return a basic PDF without signatures
        return await generateBasicPdf(letter);
      }

      // Generate PDF with embedded signatures
      return await _generatePdfWithSignatures(letter, signatures);
    } catch (e) {
      _logger.e('Error generating signed PDF: $e');
      // Fallback to basic PDF
      return await generateBasicPdf(letter);
    }
  }

  /// Generate basic PDF without signatures
  Future<Uint8List> generateBasicPdf(Letter letter) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              pw.Paragraph(
                text: letter.content,
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
      ),
    );
    return pdf.save();
  }

  /// Generate PDF with embedded signatures
  Future<Uint8List> _generatePdfWithSignatures(
    Letter letter,
    List<Signature> signatures,
  ) async {
    final pdf = pw.Document();
    final supabaseService = SupabaseService();
    //print('[PDF] Letter content: \'${letter.content}\'');
    //print('[PDF] Adding letter content to PDF...');
    // Fetch all signature images and build widgets
    final signatureWidgets = await Future.wait(
      signatures.map((sig) async {
        pw.Widget? imageWidget;
        //  print('[PDF] Embedding signature for: \'${sig.displayName}\'');
        try {
          //  print('[PDF] Fetching signature image: \'${sig.imagePath}\'');
          final imageBytes = await supabaseService
              .downloadFileWithServiceRoleSignedUrl(
                sig.imagePath,
                securityLevel: 'preview',
              );
          //  print(
          //    '[PDF] Image bytes for ${sig.imagePath}: \'${imageBytes.length}\' bytes',
          //  );
          if (imageBytes.isEmpty) {
            //  print('[PDF] WARNING: Image bytes are empty for ${sig.imagePath}');
            imageWidget = pw.Text('[Signature image unavailable]');
          } else {
            try {
              final decoded = img.decodeImage(imageBytes);
              if (decoded == null) {
                //    print(
                //    '[PDF] ERROR: Could not decode image for ${sig.imagePath}',
                //  );
                imageWidget = pw.Text('[Signature image unavailable]');
              } else {
                final pngBytes = img.encodePng(decoded);
                imageWidget = pw.Image(
                  pw.MemoryImage(Uint8List.fromList(pngBytes)),
                  height: 48,
                );
                //print('[PDF] Signature for ${sig.displayName} embedded.');
              }
            } catch (e) {
              //print(
              //'[PDF] ERROR in image decode/encode for ${sig.imagePath}: $e',
              //);
              imageWidget = pw.Text('[Signature image unavailable]');
            }
          }
        } catch (e) {
          //print('[PDF] ERROR fetching image for ${sig.imagePath}: $e');
          imageWidget = pw.Text('[Signature image unavailable]');
        }
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (imageWidget != null) imageWidget,
            pw.Text(sig.displayName),
            if (sig.title != null) pw.Text(sig.title!),
            if (sig.department != null) pw.Text(sig.department!),
            pw.SizedBox(height: 16),
          ],
        );
      }),
    );
    //print(
    //'[PDF] Letter content and all signatures prepared. Adding page to PDF...',
    //);
    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            final widgets = <pw.Widget>[];

            // Add the main content as a paragraph that can span pages
            if (letter.content.isNotEmpty) {
              widgets.add(
                pw.Paragraph(
                  text: letter.content,
                  style: pw.TextStyle(fontSize: 12),
                  margin: const pw.EdgeInsets.only(bottom: 24),
                ),
              );
            }

            // Add signatures in a way that can span pages if needed
            if (signatureWidgets.isNotEmpty) {
              // Add a title for signatures
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Text(
                    'Signatories:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );

              // Add signatures in a wrap layout that can break across pages
              widgets.add(
                pw.Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      signatureWidgets
                          .map(
                            (widget) => pw.Container(
                              width: 200, // Fixed width for consistent layout
                              child: widget,
                            ),
                          )
                          .toList(),
                ),
              );
            }

            return widgets;
          },
        ),
      );
      //print('[PDF] MultiPage added to PDF.');
    } catch (e) {
      //print('[PDF] ERROR in PDF page build: $e');
      pdf.addPage(
        pw.Page(
          build:
              (pw.Context context) =>
                  pw.Center(child: pw.Text('Error generating PDF: $e')),
        ),
      );
    }
    //print('[PDF] Saving PDF...');
    final pdfBytes = await pdf.save();
    //print('[PDF] PDF saved.');
    return pdfBytes;
  }

  /// Fetch PDF bytes from a saved path for viewing
  Future<Uint8List?> fetchSavedPdfBytes(String pdfPath) async {
    try {
      //print('[FETCH] Fetching saved PDF from path: $pdfPath');

      // Get a signed URL for the PDF
      final signedUrl = await _supabaseService.getSignedUrlWithSecurityLevel(
        pdfPath,
        securityLevel: 'download',
      );
      // print('[FETCH] Got signed URL: $signedUrl');

      // Fetch the PDF bytes using http
      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        //print('[FETCH] Successfully loaded PDF bytes: size=${pdfBytes.length}');
        return pdfBytes;
      } else {
        //print('[FETCH] ERROR: HTTP ${response.statusCode} when fetching PDF');
        return null;
      }
    } catch (e) {
      //print('[FETCH] ERROR fetching saved PDF: $e');
      return null;
    }
  }

  /// Upload signed PDF to Supabase using service role client
  Future<String> uploadSignedPdf(String letterId, Uint8List pdfBytes) async {
    try {
      // IMMUTABILITY CHECK: Only allow PDF upload for draft letters
      final letter = await getLetter(letterId);
      if (letter != null && !letter.isDraft) {
        _logger.w(
          'Attempted to upload PDF for non-draft letter $letterId. Blocked for immutability.',
        );
        throw Exception(
          'Cannot upload PDF for non-draft letters. PDF is immutable after submission.',
        );
      }

      final fileName = '${letterId}_signed.pdf';
      final path = 'letters/$letterId';

      //print('[UPLOAD] Uploading PDF for letter: $letterId');
      //print('[UPLOAD] File name: $fileName');
      //print('[UPLOAD] Path: $path');
      //print('[UPLOAD] PDF size: ${pdfBytes.length} bytes');

      // Use service role upload to bypass RLS
      final uploadedPath = await _supabaseService.uploadBytesWithServiceRole(
        filePath: path,
        bytes: pdfBytes,
        fileName: fileName,
        contentType: 'application/pdf',
      );

      //print('[UPLOAD] PDF uploaded successfully to: $uploadedPath');
      return uploadedPath;
    } catch (e) {
      _logger.e('Error uploading signed PDF: $e');
      //print('[UPLOAD] ERROR: $e');
      rethrow;
    }
  }

  /// Upload final approved PDF (bypasses draft check for approval workflow)
  Future<String> uploadFinalApprovedPdf(
    String letterId,
    Uint8List pdfBytes,
  ) async {
    try {
      final fileName = '${letterId}_approved.pdf';
      final path = 'letters/$letterId';

      //print(
      //'[UPLOAD FINAL] Uploading final approved PDF for letter: $letterId',
      //);
      //print('[UPLOAD FINAL] File name: $fileName');
      //print('[UPLOAD FINAL] Path: $path');
      //print('[UPLOAD FINAL] PDF size: ${pdfBytes.length} bytes');

      // Use service role upload to bypass RLS
      final uploadedPath = await _supabaseService.uploadBytesWithServiceRole(
        filePath: path,
        bytes: pdfBytes,
        fileName: fileName,
        contentType: 'application/pdf',
      );

      //print(
      //'[UPLOAD FINAL] Final approved PDF uploaded successfully to: $uploadedPath',
      //);
      return uploadedPath;
    } catch (e) {
      _logger.e('Error uploading final approved PDF: $e');
      //print('[UPLOAD FINAL] ERROR: $e');
      rethrow;
    }
  }

  /// Get signatures for letter type
  Future<List<Signature>> getSignaturesForLetterType(String letterType) async {
    try {
      final snapshot =
          await _firestore
              .collection('signatures')
              .where('allowedLetterTypes', arrayContains: letterType)
              .where('isActive', isEqualTo: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Signature.fromJson(data);
      }).toList();
    } catch (e) {
      _logger.e('Error fetching signatures: $e');
      rethrow;
    }
  }

  /// Get signature by ID
  Future<Signature?> getSignature(String signatureId) async {
    try {
      final doc =
          await _firestore.collection('signatures').doc(signatureId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return Signature.fromJson(data);
    } catch (e) {
      _logger.e('Error fetching signature: $e');
      rethrow;
    }
  }

  /// Generate PDF with signature using pure Dart (works on all platforms)
  Future<Uint8List> generatePdfWithSignatureJS({
    required String content,
    required List<Map<String, String?>> signatures,
    String? headerId,
    String? footerId,
    String? logoId,
  }) async {
    try {
      //print('[DART] Generating PDF with signatures and header/footer/logo');
      //print('[DART] Header ID: $headerId');
      //print('[DART] Footer ID: $footerId');
      //print('[DART] Logo ID: $logoId');

      // Fetch header/footer/logo assets if IDs are provided
      PdfAsset? headerAsset;
      PdfAsset? footerAsset;
      PdfAsset? logoAsset;
      if (headerId != null) {
        //print('[DART] Fetching header asset with ID: $headerId');
        headerAsset = await PdfAssetService.getAssetById(headerId);
        //print('[DART] Header asset found: ${headerAsset != null}');
      }
      if (footerId != null) {
        //print('[DART] Fetching footer asset with ID: $footerId');
        footerAsset = await PdfAssetService.getAssetById(footerId);
        //print('[DART] Footer asset found: ${footerAsset != null}');
      }
      if (logoId != null) {
        //print('[DART] Fetching logo asset with ID: $logoId');
        logoAsset = await PdfAssetService.getAssetById(logoId);
        //print('[DART] Logo asset found: ${logoAsset != null}');
      }
      // Download and decode images
      pw.Widget? headerWidget;
      pw.Widget? footerWidget;
      pw.Widget? logoWidget;
      if (headerAsset != null) {
        //print('[DART] Processing header image: ${headerAsset.imageUrl}');
        String url;
        // Check if the imageUrl is already a signed URL
        if (headerAsset.imageUrl.startsWith('http')) {
          // Extract the storage path from the signed URL
          final uri = Uri.parse(headerAsset.imageUrl);
          final pathSegments = uri.pathSegments;
          // Find the path after 'object/sign/documents/'
          final documentsIndex = pathSegments.indexOf('documents');
          if (documentsIndex != -1 &&
              documentsIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments
                .sublist(documentsIndex + 1)
                .join('/');
            //print(
            //'[DART] Extracted storage path from header URL: $storagePath',
            //);
            url = await SupabaseService().getSignedUrl(storagePath);
            // print('[DART] Generated fresh signed URL for header: $url');
          } else {
            //print(
            //'[DART] Could not extract storage path from header URL, using original',
            //);
            url = headerAsset.imageUrl;
          }
        } else {
          url = await SupabaseService().getSignedUrl(headerAsset.imageUrl);
          // print('[DART] Header signed URL: $url');
        }
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          final imgBytes = resp.bodyBytes;
          //print('[DART] Header image bytes: ${imgBytes.length}');
          final decoded = img.decodeImage(imgBytes);
          if (decoded != null) {
            final pngBytes = img.encodePng(decoded);
            headerWidget = pw.Image(
              pw.MemoryImage(Uint8List.fromList(pngBytes)),
              height: 60,
              fit: pw.BoxFit.contain,
            );
            //print('[DART] Header widget created successfully');
          } else {
            print('[DART] Failed to decode header image');
          }
        } else {
          print(
            '[DART] Failed to download header image: HTTP ${resp.statusCode}',
          );
        }
      }
      if (footerAsset != null) {
        //print('[DART] Processing footer image: ${footerAsset.imageUrl}');
        String url;
        // Check if the imageUrl is already a signed URL
        if (footerAsset.imageUrl.startsWith('http')) {
          // Extract the storage path from the signed URL
          final uri = Uri.parse(footerAsset.imageUrl);
          final pathSegments = uri.pathSegments;
          // Find the path after 'object/sign/documents/'
          final documentsIndex = pathSegments.indexOf('documents');
          if (documentsIndex != -1 &&
              documentsIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments
                .sublist(documentsIndex + 1)
                .join('/');
            //print(
            //'[DART] Extracted storage path from footer URL: $storagePath',
            //);
            url = await SupabaseService().getSignedUrl(storagePath);
            // print('[DART] Generated fresh signed URL for footer: $url');
          } else {
            //print(
            //'[DART] Could not extract storage path from footer URL, using original',
            //);
            url = footerAsset.imageUrl;
          }
        } else {
          url = await SupabaseService().getSignedUrl(footerAsset.imageUrl);
          // print('[DART] Footer signed URL: $url');
        }
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          final imgBytes = resp.bodyBytes;
          print('[DART] Footer image bytes: ${imgBytes.length}');
          final decoded = img.decodeImage(imgBytes);
          if (decoded != null) {
            final pngBytes = img.encodePng(decoded);
            footerWidget = pw.Image(
              pw.MemoryImage(Uint8List.fromList(pngBytes)),
              height: 40,
              width: double.infinity,
              fit: pw.BoxFit.contain,
            );
            //print('[DART] Footer widget created successfully');
          } else {
            print('[DART] Failed to decode footer image');
          }
        } else {
          print(
            '[DART] Failed to download footer image: HTTP ${resp.statusCode}',
          );
        }
      }
      if (logoAsset != null) {
        //print('[DART] Processing logo image: ${logoAsset.imageUrl}');
        String url;
        // Check if the imageUrl is already a signed URL
        if (logoAsset.imageUrl.startsWith('http')) {
          // Extract the storage path from the signed URL
          final uri = Uri.parse(logoAsset.imageUrl);
          final pathSegments = uri.pathSegments;
          // Find the path after 'object/sign/documents/'
          final documentsIndex = pathSegments.indexOf('documents');
          if (documentsIndex != -1 &&
              documentsIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments
                .sublist(documentsIndex + 1)
                .join('/');
            //print('[DART] Extracted storage path from logo URL: $storagePath');
            url = await SupabaseService().getSignedUrl(storagePath);
            // print('[DART] Generated fresh signed URL for logo: $url');
          } else {
            //print(
            //'[DART] Could not extract storage path from logo URL, using original',
            //);
            url = logoAsset.imageUrl;
          }
        } else {
          url = await SupabaseService().getSignedUrl(logoAsset.imageUrl);
          // print('[DART] Logo signed URL: $url');
        }
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          final imgBytes = resp.bodyBytes;
          //print('[DART] Logo image bytes: ${imgBytes.length}');
          final decoded = img.decodeImage(imgBytes);
          if (decoded != null) {
            final pngBytes = img.encodePng(decoded);
            logoWidget = pw.Image(
              pw.MemoryImage(Uint8List.fromList(pngBytes)),
              height: 40,
              width: 40,
              fit: pw.BoxFit.contain,
            );
            print('[DART] Logo widget created successfully');
          } else {
            print('[DART] Failed to decode logo image');
          }
        } else {
          print(
            '[DART] Failed to download logo image: HTTP ${resp.statusCode}',
          );
        }
      }

      // Process signatures and create signature widgets
      final signatureWidgets = <pw.Widget>[];

      for (final sig in signatures) {
        final url = sig['imageUrl'];
        final name = sig['name'] ?? '';
        final title = sig['title'] ?? '';
        final department = sig['department'] ?? '';
        //print(
        //'[DART] Processing signature: name=$name, title=$title, department=$department',
        //);
        pw.Widget imageWidget;
        if (url != null && url.isNotEmpty) {
          try {
            // Get signed URL for the image path
            // print('[DART] Getting signed URL for image: $url');
            final signedUrl = await SupabaseService().getSignedUrl(url);
            // print('[DART] Got signed URL: $signedUrl');
            // Download the image using the signed URL
            final response = await http.get(Uri.parse(signedUrl));
            if (response.statusCode == 200) {
              final imageBytes = response.bodyBytes;
              //print('[DART] Downloaded image: ${imageBytes.length} bytes');
              final decoded = img.decodeImage(imageBytes);
              if (decoded != null) {
                final pngBytes = img.encodePng(decoded);
                imageWidget = pw.Image(
                  pw.MemoryImage(Uint8List.fromList(pngBytes)),
                  height: 60,
                  width: 120,
                  fit: pw.BoxFit.contain,
                );
              } else {
                imageWidget = pw.Container(
                  width: 120,
                  height: 60,
                  color: PdfColors.grey200,
                  child: pw.Center(child: pw.Text('No Image')),
                );
              }
            } else {
              imageWidget = pw.Container(
                width: 120,
                height: 60,
                color: PdfColors.grey200,
                child: pw.Center(child: pw.Text('No Image')),
              );
            }
          } catch (e) {
            imageWidget = pw.Container(
              width: 120,
              height: 60,
              color: PdfColors.grey200,
              child: pw.Center(child: pw.Text('No Image')),
            );
          }
        } else {
          imageWidget = pw.Container(
            width: 120,
            height: 60,
            color: PdfColors.grey200,
            child: pw.Center(child: pw.Text('No Image')),
          );
        }
        signatureWidgets.add(
          pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              imageWidget,
              pw.SizedBox(height: 4),
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (title.isNotEmpty)
                pw.Text(title, style: pw.TextStyle(fontSize: 10)),
              if (department.isNotEmpty)
                pw.Text(department, style: pw.TextStyle(fontSize: 10)),
            ],
          ),
        );
      }

      // Build the PDF page using MultiPage for robust layout
      final pdf = pw.Document();
      pw.Font font;
      pw.Font fontBold;
      bool usedTimes = false;
      try {
        final notoFontData = await rootBundle.load(
          'assets/fonts/NotoSans-Regular.ttf',
        );
        final notoBoldFontData = await rootBundle.load(
          'assets/fonts/NotoSans-Bold.ttf',
        );
        font = pw.Font.ttf(notoFontData);
        fontBold = pw.Font.ttf(notoBoldFontData);
        print('[PDF] Successfully loaded Noto Sans fonts');
      } catch (e) {
        //print(
        //'[PDF] Could not load Noto Sans, falling back to Times. Error: $e',
        //);
        font = pw.Font.times();
        fontBold = pw.Font.timesBold();
        usedTimes = true;
      }
      // Warn if Times is used and content contains non-ASCII
      if (usedTimes && content.runes.any((r) => r > 127)) {
        print(
          '[PDF][WARNING] Times font does not support Unicode. Some characters may not render.',
        );
      }
      // --- Default footer content (can be loaded from config/db) ---
      final defaultFooterContent = await PdfConfigService().getDefaultFooter();
      final defaultFooterSections = PdfConfigService().parseFooterContent(
        defaultFooterContent,
      );
      final defaultFooterSection1 = defaultFooterSections['section1'] ?? '';
      final defaultFooterSection2 = defaultFooterSections['section2'] ?? '';
      // If the user selected the default footer (e.g., footerId == 'default'), use the widget
      if (footerId == 'default') {
        footerWidget = buildDefaultFooter(
          font: font,
          section1: defaultFooterSection1,
          section2: defaultFooterSection2,
        );
      }
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          header: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                if (headerWidget != null) ...[
                  pw.Container(
                    alignment: pw.Alignment.center,
                    child: headerWidget,
                    margin: const pw.EdgeInsets.only(bottom: 8),
                  ),
                ],
                if (logoWidget != null) ...[
                  pw.Container(
                    alignment: pw.Alignment.centerLeft,
                    child: logoWidget,
                    margin: const pw.EdgeInsets.only(bottom: 8),
                  ),
                ],
              ],
            );
          },
          footer: (context) {
            if (footerWidget != null) {
              return pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 8),
                child: footerWidget,
              );
            }
            return pw.SizedBox();
          },
          build: (context) {
            // Create a list of widgets that can span across pages
            final widgets = <pw.Widget>[];

            // Add the main content as a paragraph that can span pages
            if (content.isNotEmpty) {
              widgets.add(
                pw.Paragraph(
                  text: content,
                  style: pw.TextStyle(font: font, fontSize: 12),
                  margin: const pw.EdgeInsets.only(bottom: 24),
                ),
              );
            }

            // Add signatures in a way that can span pages if needed
            if (signatureWidgets.isNotEmpty) {
              // Add a title for signatures
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Text(
                    'Signatories:',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );

              // Add signatures in a wrap layout that can break across pages
              widgets.add(
                pw.Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      signatureWidgets
                          .map(
                            (widget) => pw.Container(
                              width: 200, // Fixed width for consistent layout
                              child: widget,
                            ),
                          )
                          .toList(),
                ),
              );
            }

            return widgets;
          },
        ),
      );
      //print('[PDF] MultiPage PDF generated successfully.');
      return pdf.save();
    } catch (e) {
      print('[DART] Error in generatePdfWithSignatureJS: $e');
      rethrow;
    }
  }

  /// Create a text-only signature widget
  pw.Widget _createTextOnlySignature(Map<String, String?> sig) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 80,
          height: 40,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          child: pw.Center(
            child: pw.Text(
              '[Signature]',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (sig['name'] != null)
                pw.Text(
                  sig['name']!,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              if (sig['title'] != null) pw.Text(sig['title']!),
              if (sig['department'] != null) pw.Text(sig['department']!),
            ],
          ),
        ),
      ],
    );
  }

  /// Generate a basic PDF fallback
  Future<Uint8List> _generateBasicPdfFallback(String content) async {
    print('[DART] Generating basic PDF fallback');
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              pw.Paragraph(text: content, style: pw.TextStyle(fontSize: 12)),
            ],
      ),
    );
    return await pdf.save();
  }

  /// Build a visually appealing default footer for the PDF
  pw.Widget buildDefaultFooter({
    required pw.Font font,
    required String section1,
    required String section2,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Divider(thickness: 0.8, color: PdfColors.grey600),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left section (Section 1)
            pw.Expanded(
              child: pw.Text(
                section1,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 8,
                  color: PdfColors.blue,
                ),
                textAlign: pw.TextAlign.left,
              ),
            ),
            // Right section (Section 2)
            pw.Expanded(
              child: pw.Text(
                section2,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 8,
                  color: PdfColors.blue,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 0.8, color: PdfColors.grey600),
      ],
    );
  }

  Future<Uint8List> generatePdfWithSignatures(
    Letter letter,
    List<Signature> signatures,
  ) async {
    return _generatePdfWithSignatures(letter, signatures);
  }

  /// Check if a letter's PDF is immutable (cannot be modified)
  bool isPdfImmutable(Letter letter) {
    return !letter.isDraft;
  }

  /// Get the immutable PDF path for a letter (throws if not immutable)
  String getImmutablePdfPath(Letter letter) {
    if (letter.signedPdfPath == null || letter.signedPdfPath!.isEmpty) {
      throw Exception('No PDF path available for letter ${letter.id}');
    }
    if (!isPdfImmutable(letter)) {
      throw Exception(
        'PDF for letter ${letter.id} is not yet immutable (still in draft)',
      );
    }
    return letter.signedPdfPath!;
  }

  /// Test multi-approval workflow for debugging
  Future<void> testMultiApprovalWorkflow(String letterId) async {
    try {
      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      //print('🔍 [TEST] Multi-approval workflow test for letter: $letterId');
      //print('🔍 [TEST] Current status: ${letter.letterStatus}');
      //print('🔍 [TEST] Approval stage: ${letter.approvalStage}');
      //print('🔍 [TEST] Detailed status: ${letter.detailedApprovalStatus}');
      //print('🔍 [TEST] Should remain pending: ${letter.shouldRemainPending}');
      //print('🔍 [TEST] Is partially approved: ${letter.isPartiallyApproved}');
      // print('🔍 [TEST] Approval percentage: ${letter.approvalPercentage}%');
      //print('🔍 [TEST] Total signatures: ${letter.signatureApprovals.length}');
      //print(
      //'🔍 [TEST] Approved signatures: ${letter.approvedSignatures.length}',
      //);
      //print('🔍 [TEST] Pending signatures: ${letter.pendingApprovals.length}');
      //print(
      //'🔍 [TEST] Rejected signatures: ${letter.rejectedSignatures.length}',
      //);

      if (letter.nextRequiredApprover != null) {
        print(
          '🔍 [TEST] Next required approver: ${letter.nextRequiredApprover}',
        );
      }

      //print('🔍 [TEST] Pending approvers: ${letter.pendingApprovers}');
      //print('🔍 [TEST] Approved signers: ${letter.approvedSigners}');

      if (letter.rejectedSignersWithReasons.isNotEmpty) {
        //print('🔍 [TEST] Rejected signers with reasons:');
        for (final rejection in letter.rejectedSignersWithReasons) {
          print('  - ${rejection['name']}: ${rejection['reason']}');
        }
      }

      //print('🔍 [TEST] Can still be modified: ${letter.canStillBeModified}');
      //print('🔍 [TEST] Is in final state: ${letter.isInFinalState}');
    } catch (e) {
      _logger.e('Error in multi-approval workflow test: $e');
    }
  }

  /// Log detailed approval state for debugging
  void _logApprovalState(Letter letter, String context) {
    print('🔍 [APPROVAL DEBUG] $context for letter: ${letter.id}');
    print('  - Letter status: ${letter.letterStatus}');
    print('  - Approval stage: ${letter.approvalStage}');
    print('  - Should remain pending: ${letter.shouldRemainPending}');
    print('  - Total signatures: ${letter.signatureApprovals.length}');
    print('  - Approved: ${letter.approvedSignatures.length}');
    print('  - Pending: ${letter.pendingApprovals.length}');
    print('  - Rejected: ${letter.rejectedSignatures.length}');
    print('  - Percentage: ${letter.approvalPercentage}%');
  }

  /// Delete letter (only for draft letters)
  Future<void> deleteLetter(String letterId) async {
    try {
      _logger.i('Deleting letter: $letterId');

      final letter = await getLetter(letterId);
      if (letter == null) throw Exception('Letter not found');

      // Only allow deletion of draft letters
      if (!letter.isDraft) {
        throw Exception('Only draft letters can be deleted');
      }

      // Delete PDF file from Supabase if it exists
      if (letter.signedPdfPath != null && letter.signedPdfPath!.isNotEmpty) {
        try {
          await _supabaseService.deleteFile(letter.signedPdfPath!);
          _logger.i('PDF file deleted from Supabase: ${letter.signedPdfPath}');
        } catch (e) {
          _logger.w('Failed to delete PDF file from Supabase: $e');
          // Continue with letter deletion even if PDF deletion fails
        }
      }

      // Delete letter from Firestore
      await _firestore.collection('letters').doc(letterId).delete();

      _logger.i('Letter deleted successfully: $letterId');
    } catch (e) {
      _logger.e('Error deleting letter: $e');
      rethrow;
    }
  }
}
