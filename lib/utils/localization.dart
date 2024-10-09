import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ko', ''),
  ];

  static late AppLocalizations _current;
  static AppLocalizations get current => _current;

  static Future<void> loadCurrentLocale(Locale locale) async {
    _current = await load(locale);
  }

  String get score {
    switch (locale.languageCode) {
      case 'ko':
        return '점수';
      default:
        return 'Score';
    }
  }

  String get gameOver {
    switch (locale.languageCode) {
      case 'ko':
        return '게임 오버';
      default:
        return 'Game Over';
    }
  }

  String get restart {
    switch (locale.languageCode) {
      case 'ko':
        return '다시 시작';
      default:
        return 'Restart';
    }
  }

  // 추가적인 번역이 필요한 문자열들을 여기에 추가할 수 있습니다.
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
