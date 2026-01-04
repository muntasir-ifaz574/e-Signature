import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:esignature/app/feature/document/domain/entity/document_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/riverpod/auth_provider.dart';
import '../../../document/presentation/providers/document_providers.dart';
import '../../../document/domain/entity/document_entity.dart';
import '../../../editor/presentation/view/editor_screen.dart';
import '../../../../route/app_route.gr.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _pickAndUpload(String userId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final file = File(result.files.single.path!);
      final doc = await ref
          .read(documentControllerProvider.notifier)
          .uploadDocument(file, userId);
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (doc != null && mounted) {
        ref.refresh(userDocumentsProvider(userId));
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => EditorScreen(document: doc)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.router.replace(const SignInRoute());
            },
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          return _DocumentList(userId: user.id);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: authState.value != null
          ? FloatingActionButton(
              onPressed: () => _pickAndUpload(authState.value!.id),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _DocumentList extends ConsumerStatefulWidget {
  final String userId;
  const _DocumentList({required this.userId});

  @override
  ConsumerState<_DocumentList> createState() => _DocumentListState();
}

class _DocumentListState extends ConsumerState<_DocumentList> {
  List<DocumentEntity> _items = [];
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<DocumentEntity>>>(
      userDocumentsProvider(widget.userId),
      (previous, next) {
        next.whenOrNull(
          data: (data) {
            setState(() {
              _items = List.of(data);
              _isLoading = false;
            });
          },
        );
      },
    );

    final asyncValue = ref.watch(userDocumentsProvider(widget.userId));
    if (_isLoading && asyncValue.hasValue) {
      _items = List.of(asyncValue.value!);
      _isLoading = false;
    }

    if (_isLoading && asyncValue.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (asyncValue.hasError) {
      return Center(child: Text('Error: ${asyncValue.error}'));
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No documents found. Upload one!'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(userDocumentsProvider(widget.userId).future);
      },
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final doc = _items[index];
          return Dismissible(
            key: Key(doc.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                      "Are you sure you want to delete this document?",
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) async {
              setState(() {
                _items.removeAt(index);
              });

              await ref
                  .read(documentControllerProvider.notifier)
                  .deleteDocument(doc.id);

              ref.refresh(userDocumentsProvider(widget.userId));

              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('${doc.name} deleted')));
              }
            },
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(doc.name),
              subtitle: Text(doc.createdAt.toString().split(' ')[0]),
              trailing: doc.isPublished
                  ? const Chip(label: Text('Signed'))
                  : const Icon(Icons.edit),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditorScreen(document: doc),
                  ),
                );
                ref.refresh(userDocumentsProvider(widget.userId));
              },
            ),
          );
        },
      ),
    );
  }
}
