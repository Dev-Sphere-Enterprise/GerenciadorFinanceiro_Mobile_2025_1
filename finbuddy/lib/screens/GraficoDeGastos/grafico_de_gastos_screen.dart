import 'package:flutter/material.dart';
import 'widgets/grafico_de_gastos_widget.dart';
import 'package:intl/intl.dart';

// Definindo as cores e estilos de fonte fora da classe para reutilização
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyLime = Color(0xFFC4E03B); // Assumindo uma cor para o cabeçalho
const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyBlue,
);

class GraficoDeGastosScreen extends StatelessWidget {
  const GraficoDeGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: null, // Remova o AppBar
      body: Column( // Use um Column para empilhar o header e o conteúdo
        children: [
          // Adicione o widget de cabeçalho no topo
          _buildHeader(context),
          Expanded( // Use Expanded para o SingleChildScrollView ocupar o resto do espaço
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GraficoDeGastosWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Adicione a implementação do seu widget de cabeçalho
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: finBuddyLime,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Agrupa o botão de voltar e o título em um Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8), // Adiciona um pequeno espaço
              Text(
                'Fin_Buddy',
                style: estiloFonteMonospace.copyWith(color: finBuddyBlue, fontSize: 22),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
