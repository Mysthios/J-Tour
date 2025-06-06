import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final CollectionReference wisataRef =
      FirebaseFirestore.instance.collection('wisata');

  Future<void> updateWisata(String id, Map<String, dynamic> data) async {
    await wisataRef.doc(id).update(data);
  }

  Future<void> deleteWisata(String id) async {
    await wisataRef.doc(id).delete();
  }

  Future<String> uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
