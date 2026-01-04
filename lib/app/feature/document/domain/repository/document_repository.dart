import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entity/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, DocumentEntity>> uploadDocument(
    File file,
    String userId,
  );
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String userId);
  Future<Either<Failure, void>> updateDocumentFields(
    String docId,
    String fieldsJson,
  );
  Future<Either<Failure, void>> publishDocument(String docId);
  Future<Either<Failure, void>> deleteDocument(String docId);
  Future<Either<Failure, String>> uploadSignature(
    Uint8List signature,
    String documentId,
  );
}
