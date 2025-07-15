import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/signature_model.dart';
import '../../../core/services/supabase_service.dart';
import '../providers/letter_providers.dart';
import '../providers/signature_providers.dart';

class MultiSignatureSelection extends ConsumerStatefulWidget {
  final String letterType;
  final List<String> selectedSignatureIds;
  final Function(List<String>) onSignaturesChanged;

  const MultiSignatureSelection({
    Key? key,
    required this.letterType,
    required this.selectedSignatureIds,
    required this.onSignaturesChanged,
  }) : super(key: key);

  @override
  ConsumerState<MultiSignatureSelection> createState() =>
      _MultiSignatureSelectionState();
}

class _MultiSignatureSelectionState
    extends ConsumerState<MultiSignatureSelection> {
  List<Signature> _availableSignatures = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSignatures();
  }

  Future<void> _loadSignatures() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final signatures = await ref.read(
        refreshedSignaturesForLetterTypeProvider(widget.letterType).future,
      );
      setState(() {
        _availableSignatures = signatures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading signatures: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSignature(String signatureId) {
    final currentSelection = List<String>.from(widget.selectedSignatureIds);

    if (currentSelection.contains(signatureId)) {
      currentSelection.remove(signatureId);
    } else {
      currentSelection.add(signatureId);
    }

    widget.onSignaturesChanged(currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Signature Authorities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select authorized signatories for this ${widget.letterType.toLowerCase()}. Their digital signatures will be embedded in the generated PDF.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading signature authorities...'),
                ],
              ),
            ),
          )
        else if (_availableSignatures.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Signature Authorities Available',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No signature authorities are configured for ${widget.letterType}. Please add signatures in the Signature Management tab.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              // Selected signatures preview
              if (widget.selectedSignatureIds.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selected Signatories (${widget.selectedSignatureIds.length})',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.selectedSignatureIds.map((signatureId) {
                        final signature = _availableSignatures.firstWhere(
                          (s) => s.id == signatureId,
                          orElse:
                              () => Signature(
                                id: signatureId,
                                ownerUid: '',
                                ownerName: 'Unknown',
                                imagePath: '',
                                requiresApproval: false,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                        );

                        return _buildSelectedSignatureChip(signature);
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Available signatures list
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Signatories',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    ..._availableSignatures.map((signature) {
                      final isSelected = widget.selectedSignatureIds.contains(
                        signature.id,
                      );
                      return _buildSignatureChip(signature, isSelected);
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSelectedSignatureChip(Signature signature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Signature image
          FutureBuilder<String>(
            future: SupabaseService().getSignedUrl(signature.imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                );
              }

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Signature details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signature.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (signature.title != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    signature.title!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
                if (signature.department != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    signature.department!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: () => _toggleSignature(signature.id),
            icon: Icon(
              Icons.remove_circle_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            tooltip: 'Remove signature',
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureChip(Signature signature, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSignature(signature.id),
        borderRadius: BorderRadius.circular(0),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 12,
                        )
                        : null,
              ),
              const SizedBox(width: 16),

              // Signature image
              FutureBuilder<String>(
                future: SupabaseService().getSignedUrl(signature.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    );
                  }

                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // Signature details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signature.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (signature.title != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        signature.title!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (signature.department != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        signature.department!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Add button
              IconButton(
                onPressed: () => _toggleSignature(signature.id),
                icon: Icon(
                  isSelected ? Icons.remove_circle : Icons.add_circle_outline,
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                tooltip: isSelected ? 'Remove signature' : 'Add signature',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
