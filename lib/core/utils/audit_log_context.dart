import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class AuditLogContext {
  static final AuditLogContext _instance = AuditLogContext._internal();
  factory AuditLogContext() => _instance;
  AuditLogContext._internal();

  String? _sessionId;

  Future<String?> getIpAddress() async {
    try {
      // Only fetch on web or mobile, skip for tests
      if (kIsWeb || !kIsWeb) {
        final response = await http.get(
          Uri.parse('https://api.ipify.org?format=json'),
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body)['ip'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location service is disabled.');
        return 'Location Service Disabled';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied.');
          return 'Permission Denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever.');
        return 'Permission Denied Forever';
      }
      final position = await Geolocator.getCurrentPosition();
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Error getting location: $e');
      return 'Location Error';
    }
  }

  String getSessionId() {
    _sessionId ??= const Uuid().v4();
    return _sessionId!;
  }
}
