import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/pdf_asset_model.dart';
import '../../../core/services/pdf_asset_service.dart';
import '../../../core/services/pdf_config_service.dart';
import '../../../core/services/supabase_service.dart';

// Custom widget to handle fresh signed URLs for PDF assets
class PdfAssetImage extends StatefulWidget {
  final PdfAsset asset;
  final double height;
  final BoxFit fit;

  const PdfAssetImage({
    Key? key,
    required this.asset,
    this.height = 60,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<PdfAssetImage> createState() => _PdfAssetImageState();
}

class _PdfAssetImageState extends State<PdfAssetImage> {
  String? _signedUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateSignedUrl();
  }

  Future<void> _generateSignedUrl() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Extract storage path from the asset's imageUrl
      String storagePath;
      if (widget.asset.imageUrl.startsWith('http')) {
        // Extract the storage path from the signed URL
        final uri = Uri.parse(widget.asset.imageUrl);
        final pathSegments = uri.pathSegments;
        // Find the path after 'object/sign/documents/'
        final documentsIndex = pathSegments.indexOf('documents');
        if (documentsIndex != -1 && documentsIndex + 1 < pathSegments.length) {
          storagePath = pathSegments.sublist(documentsIndex + 1).join('/');
        } else {
          throw Exception('Could not extract storage path from URL');
        }
      } else {
        storagePath = widget.asset.imageUrl;
      }

      // Generate fresh signed URL
      final signedUrl = await SupabaseService().getSignedUrl(storagePath);

      if (!mounted) return;

      setState(() {
        _signedUrl = signedUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red),
              Text(
                'Failed to load image',
                style: TextStyle(fontSize: 10, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (_signedUrl == null) {
      return Container(
        height: widget.height,
        child: Center(child: Text('No image')),
      );
    }

    return Image.network(
      _signedUrl!,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: widget.height,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image, color: Colors.grey),
                Text(
                  'Image unavailable',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PdfConfigTab extends StatefulWidget {
  @override
  State<PdfConfigTab> createState() => _PdfConfigTabState();
}

class _PdfConfigTabState extends State<PdfConfigTab> {
  // For upload dialog
  String? _selectedType;
  String? _label;
  Uint8List? _imageBytes;
  String? _fileName;
  bool _isUploading = false;

  // Default footer config
  final _defaultFooterController = TextEditingController();
  bool _isSavingFooter = false;
  bool _isLoadingFooter = false;
  String? _footerSaveStatus;

  @override
  void initState() {
    super.initState();
    _loadDefaultFooter();
  }

  Future<void> _loadDefaultFooter() async {
    setState(() {
      _isLoadingFooter = true;
    });
    try {
      final content = await PdfConfigService().getDefaultFooter();
      if (!mounted) return;
      _defaultFooterController.text = content;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading footer: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingFooter = false;
      });
    }
  }

  Future<void> _saveDefaultFooter() async {
    setState(() {
      _isSavingFooter = true;
      _footerSaveStatus = null;
    });
    try {
      await PdfConfigService().setDefaultFooter(_defaultFooterController.text);
      if (!mounted) return;
      setState(() {
        _footerSaveStatus = 'Saved successfully!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Default footer saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _footerSaveStatus = 'Error: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving footer: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSavingFooter = false;
      });
    }
  }

  @override
  void dispose() {
    _defaultFooterController.dispose();
    super.dispose();
  }

  void _openUploadDialog() {
    String? selectedType;
    String? label;
    Uint8List? imageBytes;
    String? fileName;
    bool isUploading = false;
    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: Text('Upload PDF Asset'),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          items: [
                            DropdownMenuItem(
                              value: 'header',
                              child: Text('Header'),
                            ),
                            DropdownMenuItem(
                              value: 'footer',
                              child: Text('Footer'),
                            ),
                            DropdownMenuItem(
                              value: 'logo',
                              child: Text('Logo'),
                            ),
                          ],
                          onChanged: (v) => setState(() => selectedType = v),
                          decoration: InputDecoration(labelText: 'Type'),
                        ),
                        TextFormField(
                          initialValue: label,
                          onChanged: (v) => setState(() => label = v),
                          decoration: InputDecoration(labelText: 'Label'),
                        ),
                        const SizedBox(height: 12),
                        imageBytes != null
                            ? Image.memory(imageBytes!, height: 80)
                            : TextButton.icon(
                              icon: Icon(Icons.upload_file),
                              label: Text('Pick Image'),
                              onPressed: () async {
                                print('[DEBUG] Pick Image button pressed');
                                print(
                                  '[DEBUG] kIsWeb:  [32m [1m [4m [7m${kIsWeb} [0m',
                                );
                                final media = await ImagePickerWeb.getImageInfo;
                                print('[DEBUG] Picker result: $media');
                                if (media != null && media.data != null) {
                                  setState(() {
                                    imageBytes = media.data;
                                    fileName =
                                        media.fileName ?? 'picked_image.png';
                                  });
                                  print(
                                    '[DEBUG] State updated: imageBytes set, fileName=$fileName',
                                  );
                                } else {
                                  print(
                                    '[DEBUG] Picker returned null or no data',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No image selected.'),
                                    ),
                                  );
                                }
                              },
                            ),
                        if (fileName != null) Text('File: $fileName'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isUploading ||
                                  selectedType == null ||
                                  label == null ||
                                  imageBytes == null ||
                                  fileName == null
                              ? null
                              : () async {
                                setState(() => isUploading = true);
                                try {
                                  if (imageBytes == null || fileName == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please select an image.',
                                        ),
                                      ),
                                    );
                                    setState(() => isUploading = false);
                                    return;
                                  }
                                  await PdfAssetService.uploadAsset(
                                    type: selectedType!,
                                    label: label!,
                                    bytes: imageBytes!,
                                    fileName: fileName!,
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Upload failed: $e'),
                                    ),
                                  );
                                } finally {
                                  setState(() => isUploading = false);
                                }
                              },
                      child:
                          isUploading
                              ? CircularProgressIndicator()
                              : Text('Upload'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _openEditDialog(PdfAsset asset) {
    String label = asset.label;
    Uint8List? newBytes;
    String? newFileName;
    bool isSaving = false;
    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: Text(
                    'Edit ${asset.type[0].toUpperCase()}${asset.type.substring(1)}',
                  ),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: label,
                          onChanged: (v) => setState(() => label = v),
                          decoration: InputDecoration(labelText: 'Label'),
                        ),
                        const SizedBox(height: 12),
                        newBytes != null
                            ? Image.memory(newBytes!, height: 80)
                            : PdfAssetImage(asset: asset, height: 80),
                        TextButton.icon(
                          icon: Icon(Icons.upload_file),
                          label: Text('Replace Image'),
                          onPressed: () async {
                            print('[DEBUG] Replace Image button pressed');
                            print(
                              '[DEBUG] kIsWeb:  [32m [1m [4m [7m${kIsWeb} [0m',
                            );
                            final media = await ImagePickerWeb.getImageInfo;
                            print('[DEBUG] Picker result: $media');
                            if (media != null && media.data != null) {
                              setState(() {
                                newBytes = media.data;
                                newFileName =
                                    media.fileName ?? 'picked_image.png';
                              });
                              print(
                                '[DEBUG] State updated: newBytes set, newFileName=$newFileName',
                              );
                            } else {
                              print('[DEBUG] Picker returned null or no data');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('No image selected.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isSaving
                              ? null
                              : () async {
                                setState(() => isSaving = true);
                                try {
                                  await PdfAssetService.updateAsset(
                                    asset: asset,
                                    newLabel:
                                        label != asset.label ? label : null,
                                    newBytes: newBytes,
                                    newFileName: newFileName,
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Update failed: $e'),
                                    ),
                                  );
                                } finally {
                                  setState(() => isSaving = false);
                                }
                              },
                      child:
                          isSaving ? CircularProgressIndicator() : Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteAsset(PdfAsset asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'Delete ${asset.type[0].toUpperCase()}${asset.type.substring(1)}',
            ),
            content: Text(
              'Are you sure you want to delete "${asset.label}"? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        await PdfAssetService.deleteAsset(asset);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Default Footer Editor
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Default Footer (used for visually styled PDF footer)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_isLoadingFooter)
                            Center(child: CircularProgressIndicator())
                          else
                            SizedBox(
                              height: 180,
                              child: TextFormField(
                                controller: _defaultFooterController,
                                minLines: 4,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter default footer content...',
                                  helperText:
                                      'Use "=== Section 1:" and "====Section 2:" to separate sections. Section 1 will appear on the left, Section 2 on the right (both in blue).',
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    _isSavingFooter || _isLoadingFooter
                                        ? null
                                        : _saveDefaultFooter,
                                icon: Icon(
                                  _isSavingFooter
                                      ? Icons.hourglass_empty
                                      : Icons.save,
                                ),
                                label: Text(
                                  _isSavingFooter ? 'Saving...' : 'Save',
                                ),
                              ),
                              if (_footerSaveStatus != null) ...[
                                const SizedBox(width: 12),
                                Text(
                                  _footerSaveStatus!,
                                  style: TextStyle(
                                    color:
                                        _footerSaveStatus!.startsWith('Error')
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Asset List
                  Text(
                    'PDF Header/Footer/Logo Configuration',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openUploadDialog,
                        icon: Icon(Icons.add),
                        label: Text('Add New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 400, // Fixed height for asset list
                    child: StreamBuilder<List<PdfAsset>>(
                      stream: PdfAssetService.getAssets(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final assets = snapshot.data ?? [];
                        final grouped = {
                          'header':
                              assets.where((a) => a.type == 'header').toList(),
                          'footer':
                              assets.where((a) => a.type == 'footer').toList(),
                          'logo':
                              assets.where((a) => a.type == 'logo').toList(),
                        };
                        return ListView(
                          children: [
                            for (final type in ['header', 'footer', 'logo'])
                              if (grouped[type]!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type[0].toUpperCase() +
                                          type.substring(1) +
                                          's',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        for (final asset in grouped[type]!)
                                          Card(
                                            child: Container(
                                              width: 220,
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  PdfAssetImage(asset: asset),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    asset.label,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'ID: ${asset.id}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Updated: ${asset.updatedAt.toLocal()}'
                                                        .split('.')[0],
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit),
                                                        onPressed:
                                                            () =>
                                                                _openEditDialog(
                                                                  asset,
                                                                ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                        ),
                                                        onPressed:
                                                            () => _deleteAsset(
                                                              asset,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
