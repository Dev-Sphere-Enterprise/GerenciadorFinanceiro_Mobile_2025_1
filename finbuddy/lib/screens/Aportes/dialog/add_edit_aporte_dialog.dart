import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/style_constants.dart';
import 'package:provider/provider.dart';
import '../viewmodel/aportes_viewmodel.dart';
import '../../../shared/core/models/aporte_meta_model.dart';

Future<void> showAddOrEditAporteDialog({
  required BuildContext context,
  AporteMetaModel? aporte,
}) async {
  final viewModel = Provider.of<AportesViewModel>(context, listen: false);

  final isEditing = aporte != null;
  final valorController = TextEditingController(
    text: isEditing ? aporte.valor.toString().replaceAll('.', ',') : '',
  );
  DateTime selectedDate = isEditing ? aporte.dataAporte : DateTime.now();
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          bool isLoading = false;

          valorController.addListener(() {
            setModalState(() {
            });
          });

          const inputDecoration = InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(),
            isDense: true,
          );

          Widget buildDialogRow(String label, Widget child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '$label:',
                    style: estiloFonteMonospace.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: child),
              ],
            );
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: finBuddyBlue, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text(
                        isEditing ? 'Editar Aporte' : 'Adicionar Aporte',
                        textAlign: TextAlign.center,
                        style: estiloFonteMonospace.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 24),

                      buildDialogRow(
                        'Valor',
                        TextFormField(
                          controller: valorController,
                          decoration: inputDecoration,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                          v!.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      buildDialogRow(
                        'Data',
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: estiloFonteMonospace.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ElevatedButton(
                      // ignore: dead_code
                      onPressed: isLoading ? null : () async {
                        if (formKey.currentState!.validate()) {
                          setModalState(() => isLoading = true);

                          final valorFinal = double.tryParse(
                            valorController.text.trim().replaceAll(',', '.'),
                          ) ?? 0.0;

                          final sucesso = await viewModel.salvarAporte(
                            id: isEditing ? aporte.id : null,
                            valor: valorFinal,
                            data: selectedDate,
                          );

                          setModalState(() => isLoading = false);
                          
                          if (sucesso && context.mounted) {
                            Navigator.pop(context);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Erro ao salvar o aporte"), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: isLoading ? const CircularProgressIndicator() : const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}