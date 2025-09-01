import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';

Future<void> showEditProfileDialog(BuildContext context) async {
  final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
  
  await showDialog(
    context: context,
    builder: (context) {
      final nameController = TextEditingController(text: viewModel.user?.nome ?? '');
      final dobController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(viewModel.user!.dataNascimento));
      DateTime selectedDate = viewModel.user!.dataNascimento;

      return AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Data de Nascimento'),
              onTap: () async {
                final pickedDate = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1925), lastDate: DateTime.now());
                if (pickedDate != null) {
                  selectedDate = pickedDate;
                  dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final sucesso = await viewModel.updateUserProfile(nameController.text.trim(), selectedDate);
              if (context.mounted && sucesso) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}