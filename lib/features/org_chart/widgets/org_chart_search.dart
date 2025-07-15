import 'package:flutter/material.dart';

class OrgChartSearch extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String? initialQuery;

  const OrgChartSearch({
    super.key,
    required this.onSearchChanged,
    this.initialQuery,
  });

  @override
  State<OrgChartSearch> createState() => _OrgChartSearchState();
}

class _OrgChartSearchState extends State<OrgChartSearch> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search employees by name, email, or ID...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon:
              _controller.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onSearchChanged('');
                    },
                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
