import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/document_repository_impl.dart';
import '../../domain/entity/document_entity.dart';
import '../../domain/repository/document_repository.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl();
});

final userDocumentsProvider =
    FutureProvider.family<List<DocumentEntity>, String>((ref, userId) async {
      final repo = ref.watch(documentRepositoryProvider);
      final result = await repo.getDocuments(userId);
      return result.fold((l) => throw l, (r) => r);
    });

class DocumentController extends StateNotifier<AsyncValue<void>> {
  final DocumentRepository _repo;

  DocumentController(this._repo) : super(const AsyncValue.data(null));

  Future<DocumentEntity?> uploadDocument(File file, String userId) async {
    state = const AsyncValue.loading();
    final result = await _repo.uploadDocument(file, userId);
    return result.fold(
      (l) {
        state = AsyncValue.error(l.message, StackTrace.current);
        return null;
      },
      (r) {
        state = const AsyncValue.data(null);
        return r;
      },
    );
  }

  Future<void> deleteDocument(String docId) async {
    state = const AsyncValue.loading();
    final result = await _repo.deleteDocument(docId);
    result.fold(
      (l) => state = AsyncValue.error(l.message, StackTrace.current),
      (r) {
        state = const AsyncValue.data(null);
      },
    );
  }
}

final documentControllerProvider =
    StateNotifierProvider<DocumentController, AsyncValue<void>>((ref) {
      return DocumentController(ref.watch(documentRepositoryProvider));
    });
