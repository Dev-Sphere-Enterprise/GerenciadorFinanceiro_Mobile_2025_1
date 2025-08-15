import 'package:flutter/material.dart';
// Importe o novo widget
import 'widgets/grafico_de_gastos_widget.dart';

class GraficoDeGastosScreen extends StatelessWidget {
  const GraficoDeGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Gastos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Use um SingleChildScrollView para permitir que o conteúdo role
      body: const SingleChildScrollView(
        child: GraficoDeGastosWidget(),
      ),
    );
  }
}