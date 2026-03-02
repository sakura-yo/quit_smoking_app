import 'package:shared_preferences/shared_preferences.dart';
import '../models/smoking_record.dart';

class StorageService {
  static const _keyRecords = 'smoking_records';
  static const _keyPricePerPack = 'smoking_price_per_pack';
  static const _keyTargetPerDay = 'smoking_target_per_day';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  List<SmokingRecord> getRecords() {
    final raw = _prefs.getString(_keyRecords);
    final list = SmokingRecord.listFromJson(raw);
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  Future<void> saveRecords(List<SmokingRecord> records) async {
    await _prefs.setString(_keyRecords, SmokingRecord.listToJson(records));
  }

  int? getPricePerPack() {
    final v = _prefs.getString(_keyPricePerPack);
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v);
    return (n != null && n >= 0) ? n : null;
  }

  Future<void> savePricePerPack(int? value) async {
    if (value == null || value < 0) {
      await _prefs.remove(_keyPricePerPack);
    } else {
      await _prefs.setString(_keyPricePerPack, value.toString());
    }
  }

  int? getDailyTarget() {
    final v = _prefs.getString(_keyTargetPerDay);
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v);
    return (n != null && n >= 1) ? n : null;
  }

  Future<void> saveDailyTarget(int? value) async {
    if (value == null || value < 1) {
      await _prefs.remove(_keyTargetPerDay);
    } else {
      await _prefs.setString(_keyTargetPerDay, value.toString());
    }
  }
}
