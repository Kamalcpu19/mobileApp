import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workshop_service_advisor/core/constants/app_constants.dart';
import 'package:workshop_service_advisor/core/theme/theme_provider.dart';

const _localeKey = 'app_locale';

/// Persists and exposes the active app [Locale] (English / Arabic).
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(_localeKey) ?? AppConstants.defaultLocale;
    if (!AppConstants.supportedLocales.contains(code)) {
      return const Locale(AppConstants.defaultLocale);
    }
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppConstants.supportedLocales.contains(locale.languageCode)) {
      return;
    }
    state = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(next);
  }

  bool get isRtl => state.languageCode == 'ar';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});
