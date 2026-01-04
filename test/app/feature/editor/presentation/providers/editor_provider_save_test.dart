import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:esignature/app/feature/document/domain/entity/document_entity.dart';
import 'package:esignature/app/feature/document/domain/repository/document_repository.dart';
import 'package:esignature/app/feature/editor/domain/entity/field_entity.dart';
import 'package:esignature/app/feature/editor/presentation/providers/editor_provider.dart';
import 'package:esignature/app/feature/document/presentation/providers/document_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late MockDocumentRepository mockRepo;
  late DocumentEntity publishedDoc;

  setUp(() {
    mockRepo = MockDocumentRepository();
    publishedDoc = DocumentEntity(
      id: '123',
      userId: 'user1',
      name: 'Test Doc',
      fileUrl: 'url',
      createdAt: DateTime.now(),
      isPublished: true,
      fieldsJson: '',
    );
  });

  test(
    'validateSubmission returns true when all required fields are filled',
    () {
      // Setup doc with filled required field
      final field = FieldEntity(
        id: '1',
        type: FieldType.text,
        pageIndex: 0,
        x: 0,
        y: 0,
        width: 100,
        height: 50,
        isRequired: true,
        value: 'Filled',
      );
      final docWithFields = publishedDoc.copyWith(
        fieldsJson: jsonEncode([field.toJson()]),
      );

      final container = ProviderContainer(
        overrides: [documentRepositoryProvider.overrideWithValue(mockRepo)],
      );
      final controller = container.read(editorProvider(docWithFields).notifier);

      expect(controller.validateSubmission(), true);
    },
  );

  test('validateSubmission returns false when required field is empty', () {
    // Setup doc with empty required field
    final field = FieldEntity(
      id: '1',
      type: FieldType.text,
      pageIndex: 0,
      x: 0,
      y: 0,
      width: 100,
      height: 50,
      isRequired: true,
      value: null,
    );
    final docWithFields = publishedDoc.copyWith(
      fieldsJson: jsonEncode([field.toJson()]),
    );

    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(mockRepo)],
    );
    final controller = container.read(editorProvider(docWithFields).notifier);

    expect(controller.validateSubmission(), false);
  });

  test('save() calls repository update and publish', () async {
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(mockRepo)],
    );
    final controller = container.read(editorProvider(publishedDoc).notifier);

    // Mock repo responses
    when(
      () => mockRepo.updateDocumentFields(any(), any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockRepo.publishDocument(any()),
    ).thenAnswer((_) async => const Right(null));

    await controller.save();

    verify(() => mockRepo.updateDocumentFields('123', any())).called(1);
    verify(() => mockRepo.publishDocument('123')).called(1);
  });
}
