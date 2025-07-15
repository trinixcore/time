import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
// Conditional import for platformViewRegistry
// ignore: uri_does_not_exist
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';
import '../../../core/models/letter_model.dart'; // Ensure this is the correct import for the Letter model with headerId/footerId/logoId fields
import '../../../core/models/signature_model.dart';
import '../../../core/services/letter_service.dart';
import '../providers/letter_providers.dart';
import '../tabs/pending_approvals_tab.dart';
import '../../../core/services/pdf_asset_service.dart';
import '../../../core/models/pdf_asset_model.dart';
import '../../../core/services/supabase_service.dart';

class LetterPreviewEditModal extends ConsumerStatefulWidget {
  final Letter letter;
  final WidgetRef ref;
  const LetterPreviewEditModal({
    Key? key,
    required this.letter,
    required this.ref,
  }) : super(key: key);

  @override
  ConsumerState<LetterPreviewEditModal> createState() =>
      _LetterPreviewEditModalState();
}

class _LetterPreviewEditModalState
    extends ConsumerState<LetterPreviewEditModal> {
  late TextEditingController _contentController;
  bool _isSaving = false;
  Uint8List? _pdfBytes;
  bool _isLoadingPdf = false;
  List<Signature> _signatures = [];
  List<PdfAsset> _headers = [];
  List<PdfAsset> _footers = [];
  List<PdfAsset> _logos = [];
  String? _selectedHeaderId;
  String? _selectedFooterId;
  String? _selectedLogoId;
  bool _dropdownOpen = false; // Track if dropdown is open

  @override
  void initState() {
    super.initState();
    print('[MODAL] initState: Letter status: ${widget.letter.letterStatus}');
    _contentController = TextEditingController(text: widget.letter.content);
    _selectedHeaderId = widget.letter.headerId;
    _selectedFooterId = widget.letter.footerId;
    _selectedLogoId = widget.letter.logoId;
    print('[DEBUG] Initial _selectedFooterId: $_selectedFooterId');
    _loadPdfAssets();
    _loadPdfForStatus();
  }

  Future<void> _loadPdfAssets() async {
    final assets = await PdfAssetService.getAssets().first;
    setState(() {
      _headers = assets.where((a) => a.type == 'header').toList();
      _footers = assets.where((a) => a.type == 'footer').toList();
      _logos = assets.where((a) => a.type == 'logo').toList();
      print('[DEBUG] Loaded footers: ${_footers.map((f) => f.id).toList()}');
    });
  }

  Future<void> _loadPdfForStatus() async {
    final letter = widget.letter;
    print(
      '[MODAL] _loadPdfForStatus: isDraft=${letter.isDraft}, isPendingApproval=${letter.isPendingApproval}, signedPdfPath=${letter.signedPdfPath}',
    );
    setState(() => _isLoadingPdf = true);

    if (letter.isDraft) {
      print('[MODAL] Draft mode: Regenerating PDF');
      await _fetchSignaturesAndGeneratePdf();
      return;
    }

    // For pending approval and later, fetch the saved PDF from Supabase
    if (letter.signedPdfPath != null && letter.signedPdfPath!.isNotEmpty) {
      try {
        print('[MODAL] Viewing saved PDF: path=${letter.signedPdfPath}');

        // Use the new dedicated method for fetching saved PDFs
        final pdfBytes = await LetterService().fetchSavedPdfBytes(
          letter.signedPdfPath!,
        );

        if (pdfBytes != null) {
          setState(() {
            _pdfBytes = pdfBytes;
            _isLoadingPdf = false;
          });
          print(
            '[MODAL] Successfully loaded saved PDF: size=${pdfBytes.length}',
          );
        } else {
          print('[MODAL] ERROR: Could not fetch saved PDF bytes');
          setState(() {
            _pdfBytes = null;
            _isLoadingPdf = false;
          });
        }
      } catch (e) {
        print('[MODAL] ERROR loading saved PDF: $e');
        setState(() {
          _pdfBytes = null;
          _isLoadingPdf = false;
        });
      }
    } else {
      print('[MODAL] No signedPdfPath available, cannot load PDF');
      setState(() {
        _pdfBytes = null;
        _isLoadingPdf = false;
      });
    }
  }

  Future<void> _fetchSignaturesAndGeneratePdf() async {
    setState(() => _isLoadingPdf = true);
    final updatedLetter = widget.letter.copyWith(
      content: _contentController.text,
      headerId: _selectedHeaderId,
      footerId: _selectedFooterId,
      logoId: _selectedLogoId,
    );
    print(
      '[MODAL] [GEN] Regenerating PDF for draft. Content length: ${updatedLetter.content.length}',
    );

    // Debug content
    print('[MODAL] Original letter content: "${widget.letter.content}"');
    print('[MODAL] Controller text: "${_contentController.text}"');
    print('[MODAL] Updated letter content: "${updatedLetter.content}"');
    print('[MODAL] Content length: ${updatedLetter.content.length}');

    // Debug header/footer/logo IDs
    print('[MODAL] Header ID: $_selectedHeaderId');
    print('[MODAL] Footer ID: $_selectedFooterId');
    print('[MODAL] Logo ID: $_selectedLogoId');

    // Fetch signatures
    print(
      '[MODAL] signatureAuthorityUids: \'${updatedLetter.signatureAuthorityUids}\'',
    );
    final signatureObjs = <Signature>[];
    for (final id in updatedLetter.signatureAuthorityUids) {
      final sig = await LetterService().getSignature(id);
      if (sig != null) signatureObjs.add(sig);
    }
    print(
      '[MODAL] Fetched signatures: count=${signatureObjs.length}, ids=${signatureObjs.map((s) => s.id).toList()}',
    );
    _signatures = signatureObjs;
    // Generate PDF with signatures
    Uint8List pdfBytes;
    if (kIsWeb) {
      // Prepare the signatures list for JS interop
      final jsSignatures =
          _signatures
              .map(
                (sig) => {
                  'imageUrl': sig.imagePath, // Should be a public or signed URL
                  'name': sig.ownerName,
                  'title': sig.title,
                  'department': sig.department,
                },
              )
              .toList();
      print(
        '[MODAL] Calling generatePdfWithSignatureJS with content length: ${updatedLetter.content.length}',
      );
      pdfBytes = await LetterService().generatePdfWithSignatureJS(
        content: updatedLetter.content,
        signatures: jsSignatures,
        headerId: _selectedHeaderId,
        footerId: _selectedFooterId,
        logoId: _selectedLogoId,
      );
    } else {
      pdfBytes = await LetterService().generatePdfWithSignatures(
        updatedLetter,
        _signatures,
      );
    }
    setState(() {
      _pdfBytes = pdfBytes;
      _isLoadingPdf = false;
    });
  }

  void _previewPdfWeb() {
    if (_pdfBytes == null) return;
    final blob = html.Blob([_pdfBytes!], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  void _downloadPdfWeb() {
    if (_pdfBytes == null) return;
    final blob = html.Blob([_pdfBytes!], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..download = 'letter_preview.pdf'
          ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Widget _buildWebPdfPreview(
    Uint8List pdfBytes, {
    double width = 900,
    double height = 1273,
  }) {
    final viewId = 'pdf-preview-${pdfBytes.hashCode}';
    final blob = html.Blob([pdfBytes], 'application/pdf');
    // Add PDF.js toolbar hiding params
    final url =
        html.Url.createObjectUrlFromBlob(blob) +
        '#toolbar=0&navpanes=0&statusbar=0';
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int _) {
        final iframe =
            html.IFrameElement()
              ..src = url
              ..style.border = 'none'
              ..width = '${width.toInt()}'
              ..height = '${height.toInt()}';
        return iframe;
      });
    }
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letter = widget.letter;
    final isDraft = letter.isDraft;
    final isPendingApproval = letter.isPendingApproval;
    return AlertDialog(
      title: const Text('Preview & Edit Letter'),
      content: Container(
        width: 1150,
        height: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdowns row at the top
            if (isDraft)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    // Header dropdown
                    Expanded(
                      child: FocusScope(
                        child: DropdownButtonFormField<String>(
                          value: _selectedHeaderId,
                          items:
                              _headers
                                  .map(
                                    (h) => DropdownMenuItem(
                                      value: h.id,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  h.imageUrl,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: 60,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.image,
                                                        size: 12,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                h.label,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onTap: () {
                            setState(() {
                              _dropdownOpen = true;
                            });
                          },
                          onChanged: (v) {
                            setState(() {
                              _selectedHeaderId = v;
                              _dropdownOpen = false;
                              _fetchSignaturesAndGeneratePdf();
                            });
                          },
                          onSaved: (_) {
                            setState(() {
                              _dropdownOpen = false;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Header',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Footer dropdown
                    Expanded(
                      child: FocusScope(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFooterId,
                          items: [
                            DropdownMenuItem(
                              value: 'default',
                              child: Row(
                                children: [
                                  Icon(Icons.text_fields, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Default Footer (Styled)',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._footers.map(
                              (f) => DropdownMenuItem(
                                value: f.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 20,
                                      child: Image.network(
                                        f.imageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 12,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f.label,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onTap: () {
                            setState(() {
                              _dropdownOpen = true;
                            });
                          },
                          onChanged: (v) {
                            print('[DEBUG] Footer selected: $v');
                            setState(() {
                              _selectedFooterId = v;
                              _dropdownOpen = false;
                              _fetchSignaturesAndGeneratePdf();
                            });
                          },
                          onSaved: (_) {
                            setState(() {
                              _dropdownOpen = false;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Footer',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Logo dropdown
                    Expanded(
                      child: FocusScope(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLogoId,
                          items:
                              _logos
                                  .map(
                                    (l) => DropdownMenuItem(
                                      value: l.id,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  l.imageUrl,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: 60,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.image,
                                                        size: 12,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                l.label,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onTap: () {
                            setState(() {
                              _dropdownOpen = true;
                            });
                          },
                          onChanged: (v) {
                            setState(() {
                              _selectedLogoId = v;
                              _dropdownOpen = false;
                              _fetchSignaturesAndGeneratePdf();
                            });
                          },
                          onSaved: (_) {
                            setState(() {
                              _dropdownOpen = false;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Logo',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Main content: side-by-side editor and preview
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Editing controls
                  Flexible(
                    flex: 0,
                    child: Container(
                      width: 230, // Max width for editor
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Letter Content TextField
                            if (isDraft)
                              TextField(
                                controller: _contentController,
                                maxLines: null,
                                minLines: 20,
                                decoration: const InputDecoration(
                                  labelText: 'Letter Content',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                onChanged:
                                    (_) => _fetchSignaturesAndGeneratePdf(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right: PDF Preview
                  Container(
                    width: 900,
                    height: 1273,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child:
                        _dropdownOpen
                            ? const Text(
                              'PDF preview hidden while selecting from dropdown.\nPlease finish your selection.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                            : (_isLoadingPdf
                                ? const CircularProgressIndicator()
                                : (_pdfBytes != null
                                    ? (kIsWeb
                                        ? _buildWebPdfPreview(
                                          _pdfBytes!,
                                          width: 900,
                                          height: 1273,
                                        )
                                        : SfPdfViewer.memory(_pdfBytes!))
                                    : const Text('PDF Preview unavailable'))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isDraft)
          ElevatedButton(
            onPressed:
                _isSaving
                    ? null
                    : () async {
                      setState(() => _isSaving = true);
                      try {
                        print(
                          '[MODAL] Save button pressed - updating letter and PDF',
                        );

                        // RUNTIME IMMUTABILITY CHECK: Ensure letter is still in draft
                        if (!widget.letter.isDraft) {
                          throw Exception(
                            'Cannot save changes. Letter is no longer in draft status.',
                          );
                        }

                        final updatedLetter = widget.letter.copyWith(
                          content: _contentController.text,
                          headerId: _selectedHeaderId,
                          footerId: _selectedFooterId,
                          logoId: _selectedLogoId,
                        );
                        await LetterService().updateLetter(updatedLetter);
                        print('[MODAL] Letter content updated in Firestore');
                        if (_pdfBytes != null) {
                          print(
                            '[MODAL] Uploading current PDF preview to Supabase',
                          );
                          final pdfPath = await LetterService().uploadSignedPdf(
                            widget.letter.id,
                            _pdfBytes!,
                          );
                          final letterWithPdf = updatedLetter.copyWith(
                            signedPdfPath: pdfPath,
                          );
                          await LetterService().updateLetter(letterWithPdf);
                          print(
                            '[MODAL] PDF uploaded and letter updated with path: $pdfPath',
                          );
                        } else {
                          print(
                            '[MODAL] WARNING: No PDF bytes available to upload',
                          );
                        }
                        widget.ref.invalidate(pendingApprovalLettersProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Letter content and PDF preview saved successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        print('[MODAL] ERROR saving letter: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save letter: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      setState(() => _isSaving = false);
                      if (context.mounted) Navigator.of(context).pop();
                    },
            child:
                _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
