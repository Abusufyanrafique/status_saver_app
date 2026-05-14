import 'package:equatable/equatable.dart';
import 'package:status_saver/models/language_model.dart';

abstract class LanguageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final LanguageModel selectedLanguage;
  LanguageLoaded(this.selectedLanguage);

  @override
  List<Object?> get props => [selectedLanguage];
}