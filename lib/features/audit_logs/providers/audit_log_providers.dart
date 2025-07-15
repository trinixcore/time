import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audit_log_view_service.dart';
import '../../../core/models/audit_log_model.dart';
import '../models/audit_log_filters.dart';

// Service provider
final auditLogViewServiceProvider = Provider<AuditLogViewService>((ref) {
  return AuditLogViewService();
});

// Audit logs provider with filters
final auditLogsProvider =
    FutureProvider.family<List<AuditLogModel>, AuditLogFilters>((
      ref,
      filters,
    ) async {
      final service = ref.watch(auditLogViewServiceProvider);
      return await service.getAuditLogs(
        action: filters.action,
        targetType: filters.targetType,
        status: filters.status,
        userId: filters.userId,
        startDate: filters.startDate,
        endDate: filters.endDate,
      );
    });

// Audit log statistics provider
final auditLogStatsProvider =
    FutureProvider.family<Map<String, dynamic>, AuditLogFilters>((
      ref,
      filters,
    ) async {
      final service = ref.watch(auditLogViewServiceProvider);
      return await service.getAuditLogStats(
        startDate: filters.startDate,
        endDate: filters.endDate,
      );
    });

// Filter options provider
final auditLogFilterOptionsProvider = FutureProvider<Map<String, List<String>>>(
  (ref) async {
    final service = ref.watch(auditLogViewServiceProvider);
    return await service.getFilterOptions();
  },
);

// Export audit logs provider
final auditLogExportProvider = StateNotifierProvider<
  AuditLogExportNotifier,
  AsyncValue<List<Map<String, dynamic>>>
>((ref) {
  final service = ref.watch(auditLogViewServiceProvider);
  return AuditLogExportNotifier(service);
});

class AuditLogExportNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final AuditLogViewService _service;

  AuditLogExportNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> exportLogs({
    String? action,
    String? targetType,
    String? status,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();

    try {
      final logs = await _service.exportAuditLogs(
        action: action,
        targetType: targetType,
        status: status,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      state = AsyncValue.data(logs);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
