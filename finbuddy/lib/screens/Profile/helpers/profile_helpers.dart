import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Login/login_screen.dart';

Future<void> loadUserData({
  required FirebaseAuth auth,
  required FirebaseFirestore firestore,
  required Function(bool) setLoading,
  required Function(String?, String?) setData,
}) async {
  final user = auth.currentUser;
  if (user == null) return;

  setLoading(true);

  try {
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final dobTimestamp = data['dob'];

      String formattedDob = '';
      if (dobTimestamp is Timestamp) {
        final date = dobTimestamp.toDate();
        formattedDob = DateFormat('dd/MM/yyyy').format(date);
      } else if (dobTimestamp is String) {
        formattedDob = dobTimestamp;
      }

      setData(data['name'] ?? '', formattedDob);
    }
  } finally {
    setLoading(false);
  }
}

Future<void> editNameAndDob({
  required BuildContext context,
  required FirebaseFirestore firestore,
  required FirebaseAuth auth,
  required String? currentName,
  required String? currentDob,
  required Function(String, String) onUpdated,
}) async {
  final nameController = TextEditingController(text: currentName ?? '');
  final dobController = TextEditingController(text: currentDob ?? '');

  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar Perfil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: dobController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Data de Nascimento'),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1925),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'name': nameController.text.trim(),
            'dob': dobController.text.trim(),
          }),
          child: const Text('Salvar'),
        ),
      ],
    ),
  );

  if (result != null) {
    try {
      final parts = result['dob']!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final dobTimestamp = Timestamp.fromDate(DateTime(year, month, day));

      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'name': result['name'] ?? '',
        'dob': dobTimestamp,
      });

      onUpdated(result['name'] ?? '', result['dob'] ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }
}

Future<void> logoutUser(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}
