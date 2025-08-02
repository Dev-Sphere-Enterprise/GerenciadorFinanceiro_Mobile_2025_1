import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> deleteAporte({
  required FirebaseFirestore firestore,
  required User currentUser,
  required String metaId,
  required String aporteId,
  required Future<void> Function() atualizarValorMeta,

}) async {
  final aporteRef = firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('metas')
      .doc(metaId)
      .collection('aportes_meta')
      .doc(aporteId);

  await aporteRef.update({
    'Deletado': true,
    'Data_Atualizacao': Timestamp.now(),
  });

  await atualizarValorMeta();
}
