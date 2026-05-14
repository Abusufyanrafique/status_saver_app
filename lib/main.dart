import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Screens/SplashScreen.dart';

// Hive
import 'Local Database/LocalDatabase.dart';

// Providers
import 'Providers/BottomNavProvider.dart';

// BLoC
import 'bloc/splash/splash_bloc.dart';
import 'bloc/splash/splash_event.dart';

import 'bloc/status/status_bloc.dart';
import 'bloc/status/status_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Hive Init
  await Hive.initFlutter();
  Hive.registerAdapter(SavedItemAdapter());
  await Hive.openBox<SavedItem>('saved_items');

  // Notifications init
  // await NotificationService.init();
  // // Background scanner init
  //   await StatusScannerService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //  Only keep providers you REALLY need
        ChangeNotifierProvider(
          create: (_) => BottomNavProvider(),
        ),
      ],

      //  All BLoCs here
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SplashBloc()..add(StartSplashEvent()),
          ),

          BlocProvider(
            create: (_) => StatusBloc()..add(LoadStatusEvent()),
          ),
        ],

        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashyScreen(),
        ),
      ),
    );
  }
}