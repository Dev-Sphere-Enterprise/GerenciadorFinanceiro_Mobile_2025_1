import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'helpers/add_or_edit_tipo.dart';
import 'helpers/delete_tipo.dart';
import 'helpers/get_tipos_gerais.dart';
import 'helpers/get_tipos_usuario.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0x8BFAF3DD);
const Color corItem = Color(0x89B9CD67);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

class TiposPagamentosScreen extends StatefulWidget {
  const TiposPagamentosScreen({super.key});

  @override
  State<TiposPagamentosScreen> createState() => _TiposPagamentosScreenState();
}

class _TiposPagamentosScreenState extends State<TiposPagamentosScreen> {
  late Stream<List<Map<String, dynamic>>> _tiposStream;

  @override
  void initState() {
    super.initState();
    _tiposStream = StreamZip([
      getTiposGerais(),
      getTiposUsuario(),
    ]).map((lists) => [...lists[0], ...lists[1]]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoScaffold,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: finBuddyLime,
        title: Text(
          'Fin_Buddy',
          style: estiloFonteMonospace.copyWith(
            color: finBuddyBlue,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: corCardPrincipal,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tipos de Pagamento',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _tiposStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Nenhum tipo disponível.', style: estiloFonteMonospace),
                        );
                      }

                      final tipos = snapshot.data!;

                      return ListView.builder(
                        itemCount: tipos.length,
                        itemBuilder: (context, index) {
                          final tipo = tipos[index];
                          return _buildTipoItem(tipo);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finBuddyLime,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await addOrEditTipo(context: context);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Text(
                    "Adicionar",
                    style: estiloFonteMonospace.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipoItem(Map<String, dynamic> tipo) {
    final id = tipo['id'];
    final nome = tipo['Nome'] ?? 'Sem nome';
    final parcelavel = tipo['Parcelavel'] ?? false;
    final usaCartao = tipo['UsaCartao'] ?? false;
    final isGeneral = tipo['isGeneral'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: corItem,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                nome,
                textAlign: TextAlign.center,
                style: estiloFonteMonospace.copyWith(fontSize: 16),
              ),
            ),
          ),
          // Adiciona um SizedBox fixo para garantir a mesma largura para todos os itens
          SizedBox(
            width: 96, // Largura total dos botões ou do espaço vazio
            child: isGeneral
                ? const SizedBox.shrink() // Usa um espaço vazio de 0x0
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8), // Pequeno espaçamento
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                  onPressed: () async {
                    await addOrEditTipo(
                      context: context,
                      id: id,
                      nome: nome,
                      parcelavel: parcelavel,
                      usaCartao: usaCartao,
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirmar exclusão"),
                        content: const Text("Você tem certeza que deseja deletar este tipo de pagamento?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Deletar", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await deleteTipo(context, id, nome);
                      if (mounted) setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}