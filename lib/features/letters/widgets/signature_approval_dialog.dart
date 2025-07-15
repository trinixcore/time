import 'package:flutter/material.dart';

class SignatureApprovalDialog extends StatefulWidget {
  final bool isRejection;

  const SignatureApprovalDialog({Key? key, required this.isRejection})
    : super(key: key);

  @override
  State<SignatureApprovalDialog> createState() =>
      _SignatureApprovalDialogState();
}

class _SignatureApprovalDialogState extends State<SignatureApprovalDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isRejection ? 'Reject Letter' : 'Approve Letter'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isRejection) ...[
              const Text(
                'Please provide a reason for rejection:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the reason for rejection...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a rejection reason';
                  }
                  return null;
                },
              ),
            ] else ...[
              const Text(
                'Are you sure you want to approve this letter?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action will approve your signature for this letter.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.isRejection) {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(_reasonController.text.trim());
              }
            } else {
              Navigator.of(context).pop('approved');
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: widget.isRejection ? Colors.red : Colors.green,
          ),
          child: Text(widget.isRejection ? 'Reject' : 'Approve'),
        ),
      ],
    );
  }
}
