// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: 'Day',
      args: [],
    );
  }

  /// `Week`
  String get week {
    return Intl.message(
      'Week',
      name: 'week',
      desc: 'Week',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: 'Month',
      args: [],
    );
  }

  /// `Term 1`
  String get term1 {
    return Intl.message(
      'Term 1',
      name: 'term1',
      desc: 'Term 1',
      args: [],
    );
  }

  /// `Term 2`
  String get term2 {
    return Intl.message(
      'Term 2',
      name: 'term2',
      desc: 'Term 2',
      args: [],
    );
  }

  /// `Term 3`
  String get term3 {
    return Intl.message(
      'Term 3',
      name: 'term3',
      desc: 'Term 3',
      args: [],
    );
  }

  /// `Term 4`
  String get term4 {
    return Intl.message(
      'Term 4',
      name: 'term4',
      desc: 'Term 4',
      args: [],
    );
  }

  /// `Records`
  String get records {
    return Intl.message(
      'Records',
      name: 'records',
      desc: 'Records',
      args: [],
    );
  }

  /// `Todos`
  String get todos {
    return Intl.message(
      'Todos',
      name: 'todos',
      desc: 'Todos',
      args: [],
    );
  }

  /// `Drive`
  String get drive {
    return Intl.message(
      'Drive',
      name: 'drive',
      desc: 'Drive',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
