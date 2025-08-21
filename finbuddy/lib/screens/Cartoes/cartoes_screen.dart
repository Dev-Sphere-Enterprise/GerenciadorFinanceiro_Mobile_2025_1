import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'helpers/add_edit_cartao_dialog.dart';
import 'helpers/delete_cartao.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0xFFFAF3DD);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

class CartoesScreen extends StatefulWidget {
  const CartoesScreen({super.key});

  @override
  State<CartoesScreen> createState() => _CartoesScreenState();
}

class _CartoesScreenState extends State<CartoesScreen> {
  late Stream<QuerySnapshot> _cartoesStream;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _cartoesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('cartoes')
          .where('Deletado', isEqualTo: false)
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
                  'Meus Cartões',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _cartoesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Nenhum cartão cadastrado.',
                                style: estiloFonteMonospace));
                      }
                      final cartoes = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: cartoes.length,
                        itemBuilder: (context, index) {
                          return _buildCartaoItem(cartoes[index]);
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
                    await showAddEditCartaoDialog(context: context);
                    if (mounted) setState(() {});
                  },
                  child: Text('Adicionar Cartão',
                      style: estiloFonteMonospace.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartaoItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final nome = data['Nome'] ?? '';
    final valorFatura = (data['Valor_Fatura_Atual'] ?? 0.0).toDouble();
    final limite = (data['Limite_Credito'] ?? 0.0).toDouble();
    final dataFechamento = (data['Data_Fechamento'] as Timestamp?)?.toDate();
    final dataVencimento = (data['Data_Vencimento'] as Timestamp?)?.toDate();

    final progresso = limite > 0 ? (valorFatura / limite).clamp(0.0, 1.0) : 0.0;
    final formatadorMoeda =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey.shade300,
                    Colors.blueGrey.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      style: estiloFonteMonospace.copyWith(
                          fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text('Fatura: ${formatadorMoeda.format(valorFatura)}',
                      style: estiloFonteMonospace.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 8,
                      backgroundColor: Colors.black26,
                      color: finBuddyLime,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        'Limite: ${formatadorMoeda.format(limite)}',
                        style: estiloFonteMonospace.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.white70)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fechamento: ${dataFechamento != null ? formatadorData.format(dataFechamento) : '--'}',
                        style: estiloFonteMonospace.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.white70),
                      ),
                      Text(
                        'Vencimento: ${dataVencimento != null ? formatadorData.format(dataVencimento) : '--'}',
                        style: estiloFonteMonospace.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.white70),
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
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () async {
                  await showAddEditCartaoDialog(
                    context: context,
                    id: id,
                    nome: nome,
                    valorFatura: valorFatura,
                    limiteCredito: limite,
                    dataFechamento: dataFechamento,
                    dataVencimento: dataVencimento,
                  );
                  if (mounted) setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () => deleteCartao(context, id, nome),
              ),
            ],
          ),
        ],
      ),
    );
  }
}