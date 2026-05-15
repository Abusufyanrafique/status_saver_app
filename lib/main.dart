import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Imports
import 'package:status_saver/l10n/app_localizations.dart';
import 'package:status_saver/services/notification/status_scanner_service.dart';
import 'package:status_saver/services/notification/notification_service.dart'; // Name split check kar lein
import 'Screens/SplashScreen.dart';
import 'Local Database/LocalDatabase.dart';
import 'Providers/BottomNavProvider.dart';
import 'bloc/splash/splash_bloc.dart';
import 'bloc/splash/splash_event.dart';
import 'bloc/status/status_bloc.dart';
import 'bloc/status/status_event.dart';
import 'bloc/language/language_bloc.dart';
import 'bloc/language/language_event.dart';
import 'bloc/language/language_state.dart';
import 'models/language_model.dart';

void main() async {
  // 1. Flutter Engine Bindings Initialize
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Local Notifications Setup & Channels Creation
  await NotificationService.init();

  // 3. Android 13+ Runtime Notification Permission Request
  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // 4. Background Workmanager Configuration
  await StatusScannerService.initialize();
  await StatusScannerService.startScanning();

  // 5. Hive Database Initialization
  await Hive.initFlutter();
  Hive.registerAdapter(SavedItemAdapter());
  await Hive.openBox<SavedItem>('saved_items');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BottomNavProvider(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SplashBloc()..add(StartSplashEvent()),
          ),
          BlocProvider(
            create: (_) => StatusBloc()..add(LoadStatusEvent()),
          ),
          BlocProvider(
            create: (_) => LanguageBloc()..add(LoadSavedLanguage()),
          ),
        ],
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            Locale locale = const Locale('en', 'US');
            if (langState is LanguageLoaded) {
              locale = langState.selectedLanguage.locale;
            }

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: LanguageModel.all
                  .map((l) => Locale(l.code, l.countryCode))
                  .toList(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashyScreen(), // Apka updated native splash screen instance
            );
          },
        ),
      ),
    );
  }
}