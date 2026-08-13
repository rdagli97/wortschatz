import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_key_service.dart';

final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  return ApiKeyService();
});

// Kayıtlı Gemini API anahtarı (yoksa null)
final apiKeyProvider = FutureProvider<String?>((ref) async {
  return ref.watch(apiKeyServiceProvider).getApiKey();
});

class ApiKeyState {
  final bool isSaving;
  final String? errorMessage;
  final String? infoMessage;

  const ApiKeyState({this.isSaving = false, this.errorMessage, this.infoMessage});

  ApiKeyState copyWith({
    bool? isSaving,
    String? errorMessage,
    String? infoMessage,
  }) {
    return ApiKeyState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }
}

class ApiKeyController extends Notifier<ApiKeyState> {
  @override
  ApiKeyState build() => const ApiKeyState();

  Future<void> save(String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(isSaving: true, errorMessage: null, infoMessage: null);
    await ref.read(apiKeyServiceProvider).saveApiKey(trimmed);
    ref.invalidate(apiKeyProvider);
    state = state.copyWith(isSaving: false, infoMessage: 'saved');
  }

  Future<void> clear() async {
    await ref.read(apiKeyServiceProvider).clearApiKey();
    ref.invalidate(apiKeyProvider);
    state = state.copyWith(infoMessage: 'cleared');
  }
}

final apiKeyControllerProvider =
    NotifierProvider<ApiKeyController, ApiKeyState>(ApiKeyController.new);
