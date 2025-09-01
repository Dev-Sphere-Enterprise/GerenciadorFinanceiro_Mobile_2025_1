import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/categoria_model.dart';
import '../viewmodel/categorias_viewmodel.dart';

Future<void> showCategoriaDialog(BuildContext context, {CategoriaModel? categoria}) async {
  final viewModel = Provider.of<CategoriasViewModel>(context, listen: false);

  await showDialog(
    context: context,
    builder: (dialogContext) => _CategoriaDialogContent(
      viewModel: viewModel,
      categoria: categoria,
    ),
  );
}

class _CategoriaDialogContent extends StatefulWidget {
  final CategoriasViewModel viewModel;
  final CategoriaModel? categoria;
  const _CategoriaDialogContent({required this.viewModel, this.categoria});

  @override
  _CategoriaDialogContentState createState() => _CategoriaDialogContentState();
}

class _CategoriaDialogContentState extends State<_CategoriaDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.categoria?.nome ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final model = CategoriaModel(
      id: widget.categoria?.id,
      nome: _nomeController.text.trim(),
      dataCriacao: widget.categoria?.dataCriacao ?? DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );

    final sucesso = await widget.viewModel.salvarCategoria(model);

    if (mounted) {
      if (sucesso) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar categoria'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.categoria != null;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: finBuddyBlue, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Categoria' : 'Nova Categoria',
                textAlign: TextAlign.center,
                style: estiloFonteMonospace.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Nome:', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome é obrigatório.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: finBuddyLime,
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isLoading ? null : _salvar,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text('Salvar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}