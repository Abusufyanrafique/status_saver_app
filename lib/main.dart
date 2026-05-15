import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:status_saver/l10n/app_localizations.dart';
// Screens
import 'Screens/SplashScreen.dart';

// Hive
import 'Local Database/LocalDatabase.dart';

// Providers
import 'Providers/BottomNavProvider.dart';

// Splash Bloc
import 'bloc/splash/splash_bloc.dart';
import 'bloc/splash/splash_event.dart';

// Status Bloc
import 'bloc/status/status_bloc.dart';
import 'bloc/status/status_event.dart';

// Language Bloc
import 'bloc/language/language_bloc.dart';
import 'bloc/language/language_event.dart';
import 'bloc/language/language_state.dart';

// Models
import 'models/language_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive Init
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

          // Splash Bloc
          BlocProvider(
            create: (_) => SplashBloc()
              ..add(StartSplashEvent()),
          ),

          // Status Bloc
          BlocProvider(
            create: (_) => StatusBloc()
              ..add(LoadStatusEvent()),
          ),

          // Language Bloc
          BlocProvider(
            create: (_) => LanguageBloc()
              ..add(LoadSavedLanguage()),
          ),

        ],

        // IMPORTANT
        // MaterialApp ko BlocBuilder ke andar rakho
        child: BlocBuilder<LanguageBloc, LanguageState>(

          builder: (context, langState) {

            // Default Locale
            Locale locale = const Locale('en', 'US');

            // Update Locale from Bloc State
            if (langState is LanguageLoaded) {
              locale = langState.selectedLanguage.locale;
            }

            print("Current Locale: ${locale.languageCode}");

            return MaterialApp(

              debugShowCheckedModeBanner: false,
              // Current Locale
              locale: locale,

              // Supported Languages
              supportedLocales: LanguageModel.all
                  .map((l) => Locale(l.code, l.countryCode))
                  .toList(),

              // Localization Delegates
             localizationsDelegates: const [
   AppLocalizations.delegate, 
   GlobalMaterialLocalizations.delegate,
   GlobalWidgetsLocalizations.delegate,
   GlobalCupertinoLocalizations.delegate,
],

              home: const SplashyScreen(),
            );
          },
        ),
      ),
    );
  }
}