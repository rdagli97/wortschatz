import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace.dart';
import 'word_provider.dart';

// Kullanıcının çalışma alanlarını getiren FutureProvider
final workspacesProvider = FutureProvider<List<Workspace>>((ref) async {
  return ref.watch(databaseServiceProvider).getWorkspaces();
});

class WorkspaceController {
  final Ref ref;
  const WorkspaceController(this.ref);

  Future<void> createWorkspace(String name) async {
    await ref.read(databaseServiceProvider).createWorkspace(name.trim());
    ref.invalidate(workspacesProvider);
  }

  Future<void> deleteWorkspace(int id) async {
    await ref.read(databaseServiceProvider).deleteWorkspace(id);
    ref.invalidate(workspacesProvider);
    ref.invalidate(wordsProvider);
  }
}

final workspaceControllerProvider =
    Provider<WorkspaceController>(WorkspaceController.new);
