import 'package:flutter/material.dart';
import 'widgets/grafico_de_gastos_widget.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/style_constants.dart';

class GraficoDeGastosScreen extends StatelessWidget {
  const GraficoDeGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: null, 
      body: Column( 
        children: [
          _buildHeader(context),
          Expanded(
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: finBuddyLime,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
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
