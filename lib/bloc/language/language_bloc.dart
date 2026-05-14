import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/models/language_model.dart';
import 'language_event.dart';
import 'language_state.dart';


class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const _key = 'app_language_code';

  LanguageBloc() : super(LanguageInitial()) {
    on<LoadSavedLanguage>(_onLoad);
    on<ChangeLanguage>(_onChange);
  }

  Future<void> _onLoad(LoadSavedLanguage e, Emitter<LanguageState> emit) async {
    //  print("EVENT RECEIVED: ${e.language.code}");
    emit(LanguageLoading());
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';

    final lang = LanguageModel.all.firstWhere(
      (l) => l.code == code,
      orElse: () => LanguageModel.all.first,
    );
    emit(LanguageLoaded(lang));
  }

  Future<void> _onChange(ChangeLanguage e, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, e.language.code);
    emit(LanguageLoaded(e.language));
      print("LANGUAGE CHANGED: ${e.language.code}");
  }
}