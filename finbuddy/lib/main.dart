import 'package:finbuddy/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/core/db/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'screens/GraficoDeGastos/viewmodel/graficos_viewmodel.dart';
import 'package:finbuddy/screens/Aportes/viewmodel/aportes_viewmodel.dart';
import 'package:finbuddy/shared/core/repositories/aportes_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GraficosViewModel()),
        Provider<AportesRepository>(
          create: (_) => AportesRepository(),
        ),
      ],
      child: const App(),
    ),
  );
}
