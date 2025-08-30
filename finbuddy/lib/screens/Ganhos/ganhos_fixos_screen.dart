import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/constants/style_constants.dart';
import 'helpers/ganhos_fixos_dialog.dart';
import 'helpers/ganhos_fixos_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: GanhosFixosScreen()));
}

class GanhosFixosScreen extends StatefulWidget {
  const GanhosFixosScreen({super.key});

  @override
  State<GanhosFixosScreen> createState() => _GanhosFixosScreenState();
}

class _GanhosFixosScreenState extends State<GanhosFixosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot>? _ganhosStream;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _ganhosStream = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('ganhos_fixos')
          .where('Deletado', isEqualTo: false)
          .where('Recorrencia', isEqualTo: true)
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
                  'Ganhos Fixos',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _ganhosStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Nenhum ganho cadastrado.',
                                style: estiloFonteMonospace));
                      }
                      final ganhos = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: ganhos.length,
                        itemBuilder: (context, index) {
                          return _buildGanhoItem(ganhos[index]);
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await showAddOrEditGanhoDialog(
                      context: context,
                      currentUser: currentUser!,
                      firestore: _firestore,
                    );
                    if (mounted) setState(() {});
                  },
                  child: Text('Adicionar Ganho',
                      style: estiloFonteMonospace.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGanhoItem(DocumentSnapshot doc) {
    final ganho = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final nome = ganho['Nome'] ?? '';
    final valor = (ganho['Valor'] ?? 0.0).toDouble();
    final dataRecebimento = ganho['Data_Recebimento'] != null
        ? (ganho['Data_Recebimento'] as Timestamp).toDate()
        : null;

    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM');

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
                  Text(nome, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    'Valor: ${formatadorMoeda.format(valor)}',
                    style: estiloFonteMonospace.copyWith(
                        fontWeight: FontWeight.normal),
                  ),
                  if (dataRecebimento != null)
                    Text(
                      'Recebimento: Dia ${formatadorData.format(dataRecebimento)}',
                      style: estiloFonteMonospace.copyWith(
                          fontWeight: FontWeight.normal),
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
                onPressed: () async {
                  await showAddOrEditGanhoDialog(
                    context: context,
                    currentUser: currentUser!,
                    firestore: _firestore,
                    id: id,
                    nome: nome,
                    valor: valor,
                    data: dataRecebimento ?? DateTime.now(),
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
                      content: const Text("Você tem certeza que deseja deletar este ganho?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), // Cancela
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), // Confirma
                          child: const Text("Deletar", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  // Só deleta se o usuário confirmou
                  if (confirm == true) {
                    await deleteGanho(
                      id: id,
                      currentUser: currentUser!,
                      firestore: _firestore,
                    );
                    if (mounted) setState(() {});
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
