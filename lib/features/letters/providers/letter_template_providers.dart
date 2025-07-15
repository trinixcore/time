import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_template_model.dart';
import '../services/letter_template_service.dart';

// Service provider
final letterTemplateServiceProvider = Provider<LetterTemplateService>((ref) {
  return LetterTemplateService();
});

// All templates provider
final letterTemplatesProvider = FutureProvider<List<LetterTemplate>>((
  ref,
) async {
  final service = ref.read(letterTemplateServiceProvider);
  return await service.getAllTemplates();
});

// Active templates provider
final activeTemplatesProvider = FutureProvider<List<LetterTemplate>>((
  ref,
) async {
  final service = ref.read(letterTemplateServiceProvider);
  return await service.getActiveTemplates();
});

// Templates by type provider
final templatesByTypeProvider =
    FutureProvider.family<List<LetterTemplate>, String>((ref, type) async {
      final service = ref.read(letterTemplateServiceProvider);
      return await service.getTemplatesByType(type);
    });

// Template by ID provider
final templateByIdProvider = FutureProvider.family<LetterTemplate?, String>((
  ref,
  id,
) async {
  final service = ref.read(letterTemplateServiceProvider);
  return await service.getTemplateById(id);
});

// Default templates provider
final defaultTemplatesProvider = FutureProvider<List<LetterTemplate>>((
  ref,
) async {
  final service = ref.read(letterTemplateServiceProvider);
  return await service.getDefaultTemplates();
});

// Search templates provider
final searchTemplatesProvider =
    FutureProvider.family<List<LetterTemplate>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final service = ref.read(letterTemplateServiceProvider);
      return await service.searchTemplates(query);
    });

// Templates by category provider
final templatesByCategoryProvider =
    FutureProvider.family<List<LetterTemplate>, String>((ref, category) async {
      final service = ref.read(letterTemplateServiceProvider);
      return await service.getTemplatesByCategory(category);
    });

// Template notifier for CRUD operations
class LetterTemplateNotifier
    extends StateNotifier<AsyncValue<List<LetterTemplate>>> {
  final LetterTemplateService _service;

  LetterTemplateNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    state = const AsyncValue.loading();
    try {
      final templates = await _service.getAllTemplates();
      state = AsyncValue.data(templates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTemplate(LetterTemplate template) async {
    try {
      final createdTemplate = await _service.createTemplate(template);
      state.whenData((templates) {
        state = AsyncValue.data([createdTemplate, ...templates]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTemplate(LetterTemplate template) async {
    try {
      await _service.updateTemplate(template);
      state.whenData((templates) {
        final updatedTemplates =
            templates.map((t) {
              return t.id == template.id ? template : t;
            }).toList();
        state = AsyncValue.data(updatedTemplates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _service.deleteTemplate(id);
      state.whenData((templates) {
        final filteredTemplates = templates.where((t) => t.id != id).toList();
        state = AsyncValue.data(filteredTemplates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setTemplateActive(String id, bool isActive) async {
    try {
      await _service.setTemplateActive(id, isActive);
      state.whenData((templates) {
        final updatedTemplates =
            templates.map((t) {
              if (t.id == id) {
                return t.setActive(isActive);
              }
              return t;
            }).toList();
        state = AsyncValue.data(updatedTemplates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadTemplates();
  }
}

// Template notifier provider
final letterTemplateNotifierProvider = StateNotifierProvider<
  LetterTemplateNotifier,
  AsyncValue<List<LetterTemplate>>
>((ref) {
  final service = ref.read(letterTemplateServiceProvider);
  return LetterTemplateNotifier(service);
});
