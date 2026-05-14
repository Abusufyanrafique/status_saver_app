import 'package:flutter/material.dart';

class LanguageModel {
  final String name;
  final String nativeName; // apni language mein naam
  final String code;
  final String countryCode;
  final String flag;

  const LanguageModel({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.countryCode,
    required this.flag,
  });

  Locale get locale => Locale(code, countryCode);

  static const List<LanguageModel> all = [
    LanguageModel(name: 'English',    nativeName: 'English',    code: 'en', countryCode: 'US', flag: '🇺🇸'),
    LanguageModel(name: 'Urdu',       nativeName: 'اردو',        code: 'ur', countryCode: 'PK', flag: '🇵🇰'),
    LanguageModel(name: 'Hindi',      nativeName: 'हिन्दी',        code: 'hi', countryCode: 'IN', flag: '🇮🇳'),
    LanguageModel(name: 'Arabic',     nativeName: 'العربية',     code: 'ar', countryCode: 'SA', flag: '🇸🇦'),
    LanguageModel(name: 'Spanish',    nativeName: 'Español',    code: 'es', countryCode: 'ES', flag: '🇪🇸'),
    LanguageModel(name: 'French',     nativeName: 'Français',   code: 'fr', countryCode: 'FR', flag: '🇫🇷'),
    LanguageModel(name: 'Portuguese', nativeName: 'Português',  code: 'pt', countryCode: 'BR', flag: '🇧🇷'),
    LanguageModel(name: 'Russian',    nativeName: 'Русский',    code: 'ru', countryCode: 'RU', flag: '🇷🇺'),
    LanguageModel(name: 'German',     nativeName: 'Deutsch',    code: 'de', countryCode: 'DE', flag: '🇩🇪'),
    LanguageModel(name: 'Turkish',    nativeName: 'Türkçe',     code: 'tr', countryCode: 'TR', flag: '🇹🇷'),
    LanguageModel(name: 'Chinese',    nativeName: '中文',         code: 'zh', countryCode: 'CN', flag: '🇨🇳'),
    LanguageModel(name: 'Japanese',   nativeName: '日本語',        code: 'ja', countryCode: 'JP', flag: '🇯🇵'),
    LanguageModel(name: 'Korean',     nativeName: '한국어',        code: 'ko', countryCode: 'KR', flag: '🇰🇷'),
    LanguageModel(name: 'Italian',    nativeName: 'Italiano',   code: 'it', countryCode: 'IT', flag: '🇮🇹'),
    LanguageModel(name: 'Indonesian', nativeName: 'Indonesia',  code: 'id', countryCode: 'ID', flag: '🇮🇩'),
    LanguageModel(name: 'Bengali',    nativeName: 'বাংলা',        code: 'bn', countryCode: 'BD', flag: '🇧🇩'),
    LanguageModel(name: 'Malay',      nativeName: 'Melayu',     code: 'ms', countryCode: 'MY', flag: '🇲🇾'),
    LanguageModel(name: 'Thai',       nativeName: 'ภาษาไทย',      code: 'th', countryCode: 'TH', flag: '🇹🇭'),
    LanguageModel(name: 'Vietnamese', nativeName: 'Tiếng Việt', code: 'vi', countryCode: 'VN', flag: '🇻🇳'),
    LanguageModel(name: 'Persian',    nativeName: 'فارسی',       code: 'fa', countryCode: 'IR', flag: '🇮🇷'),
  ];
}