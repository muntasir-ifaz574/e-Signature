import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/document_entity.dart';
import '../../domain/repository/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument(
    File file,
    String userId,
  ) async {
    try {
      final String docId = _uuid.v4();
      final String fileName = file.path.split('/').last;

      // Upload file to Storage
      final ref = _storage.ref().child(
        'users/$userId/documents/$docId/$fileName',
      );
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Create Entity
      final document = DocumentEntity(
        id: docId,
        userId: userId,
        name: fileName,
        fileUrl: downloadUrl,
        createdAt: DateTime.now(),
        isPublished: false,
      );

      // Save to Firestore
      await _firestore.collection('documents').doc(docId).set(document.toMap());

      return Right(document);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final docs = querySnapshot.docs
          .map((doc) => DocumentEntity.fromMap(doc.data()))
          .toList();
      return Right(docs);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDocumentFields(
    String docId,
    String fieldsJson,
  ) async {
    try {
      await _firestore.collection('documents').doc(docId).update({
        'fieldsJson': fieldsJson,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> publishDocument(String docId) async {
    try {
      await _firestore.collection('documents').doc(docId).update({
        'isPublished': true,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String docId) async {
    try {
      await _firestore.collection('documents').doc(docId).delete();
      // Note: Should also delete from storage, but for now we skip that for simplicity
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadSignature(
    Uint8List signature,
    String documentId,
  ) async {
    try {
      final String signatureId = _uuid.v4();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final ref = _storage.ref().child(
        'users/${user.uid}/documents/$documentId/signatures/$signatureId.png',
      );

      final uploadTask = ref.putData(
        signature,
        SettableMetadata(contentType: 'image/png'),
      );
      final snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
