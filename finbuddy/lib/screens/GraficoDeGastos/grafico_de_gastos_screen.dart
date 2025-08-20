import 'package:flutter/material.dart';
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
      body: const SingleChildScrollView(
        child: GraficoDeGastosWidget(),
      ),
    );
  }
}