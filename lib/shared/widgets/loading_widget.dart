import 'package:flutter/material.dart';
import 'custom_loader.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({super.key, this.message, this.size});

  @override
  Widget build(BuildContext context) {
    return CustomLoader(message: message, size: size ?? 60);
  }
}
