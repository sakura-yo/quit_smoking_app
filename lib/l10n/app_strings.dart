import 'package:flutter/material.dart';

/// アプリ内の表示文字列（日本語 / English）
class AppStrings {
  AppStrings._();

  static const _ja = {
    'appTitle': '禁煙記録',
    'subtitle': '喫煙した日時を記録して振り返りましょう',
    'smoking': '喫煙',
    'tabRecords': '喫煙記録',
    'tabManual': '手入力',
    'tabSettings': '設定',
    'toastRecorded': '記録しました',
    'toastDeleted': '削除しました',
    'settings': '設定',
    'dailyTarget': '一日の目標本数',
    'pricePerPack': 'ひと箱の値段（円）',
    'settingsNote': '1箱＝20本として、カレンダーにその日の金額を表示します。目標本数に到達するとメッセージを表示します。',
    'manualRecord': '手動で記録',
    'date': '日付',
    'time': '時刻',
    'addRecord': '記録を追加',
    'history': '履歴',
    'noRecords': '記録がありません',
    'goalReached': '記録しました。本日の目標本数（%s本）に到達しました！',
    'minutesAgo': '%s分前',
    'hoursAgo': '%s時間前',
    'hoursMinutesAgo': '%s時間%s分前',
    'sinceLast': '前回から %s',
    'nthCig': '%s本目',
    'nCigs': '%s本',
    'total': '合計',
    'weekdaySun': '日',
    'weekdayMon': '月',
    'weekdayTue': '火',
    'weekdayWed': '水',
    'weekdayThu': '木',
    'weekdayFri': '金',
    'weekdaySat': '土',
    'language': '言語',
    'languageJa': '日本語',
    'languageEn': 'English',
  };

  static const _en = {
    'appTitle': 'Quit Smoking Record',
    'subtitle': 'Record when you smoked and look back',
    'smoking': 'Smoking',
    'tabRecords': 'Records',
    'tabManual': 'Manual',
    'tabSettings': 'Settings',
    'toastRecorded': 'Recorded',
    'toastDeleted': 'Deleted',
    'settings': 'Settings',
    'dailyTarget': 'Daily target (cigarettes)',
    'pricePerPack': 'Price per pack (¥)',
    'settingsNote': 'Assuming 20 cigarettes per pack. The calendar shows daily cost. A message is shown when you reach your daily target.',
    'manualRecord': 'Manual entry',
    'date': 'Date',
    'time': 'Time',
    'addRecord': 'Add record',
    'history': 'History',
    'noRecords': 'No records',
    'goalReached': 'Recorded. You reached your daily target (%s cigarettes)!',
    'minutesAgo': '%s min ago',
    'hoursAgo': '%s hr ago',
    'hoursMinutesAgo': '%s hr %s min ago',
    'sinceLast': '%s since last',
    'nthCig': '#%s',
    'nCigs': '%s',
    'total': 'Total',
    'weekdaySun': 'Sun',
    'weekdayMon': 'Mon',
    'weekdayTue': 'Tue',
    'weekdayWed': 'Wed',
    'weekdayThu': 'Thu',
    'weekdayFri': 'Fri',
    'weekdaySat': 'Sat',
    'language': 'Language',
    'languageJa': '日本語',
    'languageEn': 'English',
  };

  static String get(BuildContext context, String key, [List<Object>? args]) {
    final locale = Localizations.localeOf(context);
    final map = locale.languageCode == 'en' ? _en : _ja;
    String s = map[key] ?? _ja[key] ?? key;
    if (args != null && args.isNotEmpty) {
      for (var i = 0; i < args.length; i++) {
        s = s.replaceFirst('%s', args[i].toString());
      }
    }
    return s;
  }
}
