import 'package:equatable/equatable.dart';
import 'package:status_saver/models/language_model.dart';


abstract class LanguageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSavedLanguage extends LanguageEvent {}

class ChangeLanguage extends LanguageEvent {
  final LanguageModel language;
  ChangeLanguage(this.language);

  @override
  List<Object?> get props => [language];
}