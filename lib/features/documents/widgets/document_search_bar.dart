import 'package:flutter/material.dart';

class DocumentSearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DocumentSearchBar({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<DocumentSearchBar> createState() => _DocumentSearchBarState();
}

class _DocumentSearchBarState extends State<DocumentSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onClear();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}
