import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'helpers/gastos_fixos_helpers.dart';
import 'helpers/gastos_fixos_delete.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0xFFFAF3DD);
const Color corItemGasto = Color(0xFFE0D8B3); 

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

class GastosFixosScreen extends StatefulWidget {
  const GastosFixosScreen({super.key});

  @override
  State<GastosFixosScreen> createState() => _GastosFixosScreenState();
}

class _GastosFixosScreenState extends State<GastosFixosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

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
                  'Gastos Fixos',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('gastos_fixos')
                        .where('Deletado', isEqualTo: false)
                        .where('Recorrencia', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Nenhum gasto fixo cadastrado.',
                                style: estiloFonteMonospace));
                      }
                      final gastos = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index].data() as Map<String, dynamic>;
                          final id = gastos[index].id;
                          return _buildGastoItem(id, gasto);
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
                  onPressed: () {
                    showAddOrEditGastoDialog(context: context);
                  },
                  child: Text(
                    'Adicionar',
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

  Widget _buildGastoItem(String id, Map<String, dynamic> gasto) {
    final nome = gasto['Nome'] ?? 'Sem nome';
    final valor = gasto['Valor'] ?? 0.0;
    final dataCompra = (gasto['Data_Compra'] as Timestamp).toDate();

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
                  Text(nome, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    'Valor: ${formatadorMoeda.format(valor)}',
                    style: estiloFonteMonospace.copyWith(
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'Data: ${formatadorData.format(dataCompra)}',
                    style: estiloFonteMonospace.copyWith(
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () => showAddOrEditGastoDialog(
                  context: context,
                  gastoId: id,
                  nome: nome,
                  valor: valor,
                  dataCompra: dataCompra,
                  parcelas: gasto['Parcelas'] ?? 1,
                  tipoPagamentoId: gasto['ID_Tipo_Pagamento'],
                  cartaoId: gasto['ID_Cartao'],
                  categoriaId: gasto['ID_Categoria'],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () => deleteGasto(context, id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}