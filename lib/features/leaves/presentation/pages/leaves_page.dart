import 'package:flutter/material.dart';
import '../../../../shared/layouts/app_layout.dart';

class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Leaves',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Leave Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Leave management features will be implemented here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
