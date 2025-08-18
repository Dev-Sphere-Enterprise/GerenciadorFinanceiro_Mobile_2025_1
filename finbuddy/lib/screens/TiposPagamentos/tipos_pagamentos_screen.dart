import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';

import 'helpers/add_or_edit_tipo.dart';
import 'helpers/delete_tipo.dart';
import 'helpers/get_tipos_gerais.dart';
import 'helpers/get_tipos_usuario.dart';

class TiposPagamentosScreen extends StatefulWidget {
  const TiposPagamentosScreen({super.key});

  @override
  State<TiposPagamentosScreen> createState() => _TiposPagamentosScreenState();
}

class _TiposPagamentosScreenState extends State<TiposPagamentosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0ED), // fundo bege claro
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFC4E03B), // verde protótipo
        elevation: 0,
        toolbarHeight: 50,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFC4E03B), // cor da status bar
          statusBarIconBrightness: Brightness.dark, // ícones pretos no Android
          statusBarBrightness: Brightness.light, // p/ iOS coerente
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff3a86e0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Fin_Buddy",
          style: TextStyle(
            color: Color(0xff3a86e0),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // Título
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tipos de Pagamento",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Divider(),

          // Lista
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: StreamZip([
                getTiposGerais(),
                getTiposUsuario(),
              ]).map((lists) => [...lists[0], ...lists[1]]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum tipo de pagamento disponível.'));
                }

                final tipos = snapshot.data!;

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: tipos.length,
                  itemBuilder: (context, index) {
                    final tipo = tipos[index];
                    final id = tipo['id'];
                    final nome = tipo['Nome'];
                    final parcelavel = tipo['Parcelavel'] ?? false;
                    final isGeneral = tipo['isGeneral'] ?? false;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE99C), // verde claro
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        title: Center(
                          child: Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        trailing: isGeneral
                            ? null
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xff3a86e0), size: 20),
                              onPressed: () => addOrEditTipo(
                                context: context,
                                id: id,
                                nome: nome,
                                parcelavel: parcelavel,
                                usaCartao: tipo['UsaCartao'] ?? false,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                                  onPressed: () => deleteTipo(context, id, nome),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Botão Adicionar
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4E03B),
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => addOrEditTipo(context: context),
              child: const Text(
                "Adicionar",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
