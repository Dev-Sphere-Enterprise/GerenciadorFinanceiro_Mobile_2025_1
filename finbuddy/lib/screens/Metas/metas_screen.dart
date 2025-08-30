import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Aportes/aportes_screen.dart';
import 'helpers/metas_helper.dart';
import 'helpers/metas_delete_helper.dart';
import '/../../shared/constants/style_constants.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final MetasHelper _helper = MetasHelper();
  User? get currentUser => _helper.currentUser;
  late Stream<QuerySnapshot> _metasStream;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _metasStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('metas')
          .where('Deletado', isEqualTo: false)
          .orderBy('Data_limite_meta')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

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
                  'Minhas Metas',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _metasStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Erro ao carregar metas.'));
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Nenhuma meta cadastrada.', style: estiloFonteMonospace));
                      }
                      final metas = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: metas.length,
                        itemBuilder: (context, index) {
                          return _buildMetaItem(metas[index]);
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
                  onPressed: () async {
                    await _helper.addOrEditMeta(context: context);
                    if (mounted) setState(() {});
                  },
                  child: Text('Adicionar Meta', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nome = data['Nome'] ?? '';
    final valorAtual = (data['Valor_Atual'] ?? 0.0).toDouble();
    final valorObjetivo = (data['Valor_Objetivo'] ?? 0.0).toDouble();
    final dataLimite = (data['Data_limite_meta'] as Timestamp).toDate();
    
    final progresso = valorObjetivo > 0 ? (valorAtual / valorObjetivo).clamp(0.0, 1.0) : 0.0;
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: corItemMeta,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    '${formatadorMoeda.format(valorAtual)} de ${formatadorMoeda.format(valorObjetivo)}',
                    style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 10,
                      backgroundColor: Colors.black12,
                      color: finBuddyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progresso * 100).toStringAsFixed(0)}% Completo',
                        style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                      Text(
                        'Limite: ${formatadorData.format(dataLimite)}',
                        style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.attach_money, color: finBuddyDark),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TelaAportes(metaId: doc.id, valorAtual: valorAtual),
                )),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () async {
                  await _helper.addOrEditMeta(
                    context: context,
                    id: doc.id,
                    nome: nome,
                    valorObjetivo: valorObjetivo,
                    dataLimite: dataLimite,
                  );
                   if (mounted) setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar exclusão"),
                      content: const Text("Você tem certeza que deseja deletar esta meta?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), // cancela
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), // confirma
                          child: const Text(
                            "Deletar",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await deleteMeta(doc.id);
                    if (mounted) setState(() {}); // caso precise atualizar a tela
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