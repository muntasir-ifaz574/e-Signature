import 'package:esignature/app/feature/document/domain/entity/document_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentEntity', () {
    final tDate = DateTime(2025, 1, 1, 12, 0, 0);
    final tDocument = DocumentEntity(
      id: '1',
      userId: 'user1',
      name: 'Test Doc',
      fileUrl: 'http://example.com/doc.pdf',
      createdAt: tDate,
      isPublished: true,
      fieldsJson: '{"field": "value"}',
    );

    test('props should contain all properties for equality', () {
      final tDocument2 = DocumentEntity(
        id: '1',
        userId: 'user1',
        name: 'Test Doc',
        fileUrl: 'http://example.com/doc.pdf',
        createdAt: tDate,
        isPublished: true,
        fieldsJson: '{"field": "value"}',
      );

      expect(tDocument, equals(tDocument2));
    });

    test('toMap should return a valid map', () {
      final result = tDocument.toMap();

      expect(result['id'], '1');
      expect(result['userId'], 'user1');
      expect(result['name'], 'Test Doc');
      expect(result['fileUrl'], 'http://example.com/doc.pdf');
      expect(result['createdAt'], tDate.toIso8601String());
      expect(result['isPublished'], true);
      expect(result['fieldsJson'], '{"field": "value"}');
    });

    test('fromMap should return a valid model from JSON', () {
      final map = {
        'id': '1',
        'userId': 'user1',
        'name': 'Test Doc',
        'fileUrl': 'http://example.com/doc.pdf',
        'createdAt': tDate.toIso8601String(),
        'isPublished': true,
        'fieldsJson': '{"field": "value"}',
      };

      final result = DocumentEntity.fromMap(map);

      expect(result, equals(tDocument));
      expect(result.createdAt, equals(tDate));
    });
  });
}
