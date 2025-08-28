import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'helpers/add_edit_aporte_dialog.dart';
import 'helpers/delete_aporte.dart';
import 'helpers/atualizar_valor_meta.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0x8BFAF3DD);
const Color corItemGasto = Color(0x89B9CD67);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);


class TelaAportes extends StatefulWidget {
  final String metaId;
  final double valorAtual;

  const TelaAportes({super.key, required this.metaId, required this.valorAtual});

  @override
  State<TelaAportes> createState() => _TelaAportesState();
}

class _TelaAportesState extends State<TelaAportes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> _atualizarMeta() async {
    await atualizarValorMeta(
      firestore: _firestore,
      currentUser: currentUser!,
      metaId: widget.metaId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Usuário não autenticado')));
    }

    final aportesRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('metas')
        .doc(widget.metaId)
        .collection('aportes_meta')
        .where('Deletado', isEqualTo: false);

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
                  'Aportes da Meta',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: aportesRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Nenhum aporte cadastrado.', style: estiloFonteMonospace),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return _buildAporteItem(docs[index]);
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => showAddOrEditAporteDialog(
                    context: context,
                    firestore: _firestore,
                    currentUser: currentUser!,
                    metaId: widget.metaId,
                    atualizarValorMeta: _atualizarMeta,
                  ),
                  child: Text(
                    'Adicionar Aporte',
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

  Widget _buildAporteItem(DocumentSnapshot doc) {
    final aporte = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final valor = (aporte['Valor'] ?? 0.0).toDouble();
    final dataAporte = aporte['Data_Aporte'] != null
        ? (aporte['Data_Aporte'] as Timestamp).toDate()
        : null;

    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: corItemGasto,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor: ${formatadorMoeda.format(valor)}',
                    style: estiloFonteMonospace.copyWith(fontSize: 18),
                  ),
                  if (dataAporte != null)
                    Text(
                      'Data: ${formatadorData.format(dataAporte)}',
                      style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal),
                    ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () => showAddOrEditAporteDialog(
                  context: context,
                  firestore: _firestore,
                  currentUser: currentUser!,
                  metaId: widget.metaId,
                  atualizarValorMeta: _atualizarMeta,
                  id: id,
                  valor: valor,
                  data: dataAporte,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar exclusão"),
                      content: const Text("Você tem certeza que deseja deletar este aporte?"),
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
                    await deleteAporte(
                      firestore: _firestore,
                      currentUser: currentUser!,
                      metaId: widget.metaId,
                      aporteId: id,
                      atualizarValorMeta: _atualizarMeta,
                    );
                    if (mounted) setState(() {});
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
