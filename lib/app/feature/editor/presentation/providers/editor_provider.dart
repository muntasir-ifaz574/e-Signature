import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';
import '../../domain/entity/field_entity.dart';
import '../../../document/domain/entity/document_entity.dart';
import '../../../document/presentation/providers/document_providers.dart';

class EditorState {
  final List<FieldEntity> fields;
  final String? selectedFieldId;
  final bool isPublished;
  final bool isLoading;

  EditorState({
    this.fields = const [],
    this.selectedFieldId,
    this.isPublished = false,
    this.isLoading = false,
  });

  EditorState copyWith({
    List<FieldEntity>? fields,
    String? selectedFieldId,
    bool? isPublished,
    bool? isLoading,
  }) {
    return EditorState(
      fields: fields ?? this.fields,
      selectedFieldId: selectedFieldId, // Allow null
      isPublished: isPublished ?? this.isPublished,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EditorController extends StateNotifier<EditorState> {
  final DocumentEntity document;
  final Ref ref;
  final _uuid = const Uuid();

  EditorController(this.document, this.ref)
    : super(EditorState(isPublished: document.isPublished)) {
    _loadFields();
  }

  void _loadFields() {
    if (document.fieldsJson != null && document.fieldsJson!.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(document.fieldsJson!);
        final fields = list.map((e) => FieldEntity.fromJson(e)).toList();
        state = state.copyWith(fields: fields);
      } catch (e) {
        // print(e);
      }
    }
  }

  void addField(FieldType type, int pageIndex) {
    if (state.isPublished) return;

    final field = FieldEntity(
      id: _uuid.v4(),
      type: type,
      x: 50,
      y: 100,
      pageIndex: pageIndex,
      width: type == FieldType.checkbox ? 30 : 120,
      height: type == FieldType.checkbox ? 30 : 60,
    );

    state = state.copyWith(
      fields: [...state.fields, field],
      selectedFieldId: field.id,
    );
  }

  void updateField(FieldEntity field) {
    if (state.isPublished) {
      final index = state.fields.indexWhere(
        (element) => element.id == field.id,
      );
      if (index != -1) {
        final old = state.fields[index];
        final updated = old.copyWith(value: field.value);
        final newFields = [...state.fields];
        newFields[index] = updated;
        state = state.copyWith(fields: newFields);
        save(); // Auto-save values in published mode
      }
      return;
    }

    final index = state.fields.indexWhere((element) => element.id == field.id);
    if (index != -1) {
      final newFields = [...state.fields];
      newFields[index] = field;
      state = state.copyWith(fields: newFields, selectedFieldId: field.id);
    }
  }

  void deleteField(String id) {
    if (state.isPublished) return;
    state = state.copyWith(
      fields: state.fields.where((f) => f.id != id).toList(),
      selectedFieldId: state.selectedFieldId == id
          ? null
          : state.selectedFieldId,
    );
  }

  void selectField(String? id) {
    state = state.copyWith(selectedFieldId: id);
  }

  Future<void> save() async {
    state = state.copyWith(isLoading: true);
    final jsonStr = jsonEncode(state.fields.map((e) => e.toJson()).toList());

    await ref
        .read(documentRepositoryProvider)
        .updateDocumentFields(document.id, jsonStr);

    if (state.isPublished) {
      await ref.read(documentRepositoryProvider).publishDocument(document.id);
    }

    state = state.copyWith(isLoading: false);
  }

  void togglePublish() async {
    if (state.isPublished) return;
    state = state.copyWith(isPublished: true);
    await save();
  }

  bool validateSubmission() {
    for (final field in state.fields) {
      if (field.isRequired) {
        if (field.value == null || field.value!.isEmpty) {
          if (field.type == FieldType.checkbox) {
            if (field.value != 'true') return false;
          } else {
            return false;
          }
        }
      }
    }
    return true;
  }

  // JSON Export/Import
  String exportJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      "fields": state.fields.map((e) => e.toJson()).toList(),
    });
  }

  bool importJson(String jsonStr) {
    if (state.isPublished) return false;
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (data['fields'] != null) {
        final List<dynamic> list = data['fields'];
        final fields = list.map((e) => FieldEntity.fromJson(e)).toList();
        state = state.copyWith(fields: fields);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<String?> uploadSignature(Uint8List index) async {
    final result = await ref
        .read(documentRepositoryProvider)
        .uploadSignature(index, document.id);
    return result.fold((l) => null, (r) => r);
  }
}

final editorProvider = StateNotifierProvider.autoDispose
    .family<EditorController, EditorState, DocumentEntity>((ref, doc) {
      return EditorController(doc, ref);
    });
