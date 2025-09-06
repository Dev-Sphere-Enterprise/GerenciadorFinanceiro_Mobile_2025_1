import 'package:finbuddy/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/core/db/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:finbuddy/shared/core/repositories/aportes_repository.dart';
import 'screens/GraficoDeGastos/viewmodel/graficos_viewmodel.dart';
import 'screens/Home/viewmodel/home_viewmodel.dart';
import 'screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'screens/Gastos/viewmodel/gastos_viewmodel.dart';
import 'screens/Cartoes/viewmodel/cartoes_viewmodel.dart';
import 'screens/Login/viewmodel/login_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GraficosViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => GanhosViewModel()),
        ChangeNotifierProvider(create: (_) => GastosViewModel()),
        ChangeNotifierProvider(create: (_) => CartoesViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),

        Provider<AportesRepository>(
          create: (_) => AportesRepository(),
        ),

      ],
      child: const App(),
    ),
  );
}
