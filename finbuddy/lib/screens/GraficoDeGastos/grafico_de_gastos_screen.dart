import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import 'viewmodel/graficos_viewmodel.dart';
import 'widgets/grafico_de_gastos_widget.dart';

class GraficoDeGastosScreen extends StatelessWidget {
  const GraficoDeGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraficosViewModel(),
      child: Scaffold(
        backgroundColor: corFundoScaffold,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: finBuddyLime,
          title: Text('Fin_Buddy', style: estiloFonteMonospace.copyWith(color: finBuddyBlue, fontSize: 22)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: GraficoDeGastosWidget(),
        ),
      ),
    );
  }
}