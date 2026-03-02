import 'dart:convert';

class SmokingRecord {
  final String id;
  final DateTime dateTime;

  SmokingRecord({
    required this.id,
    required this.dateTime,
  });

  String get dateString {
    final y = dateTime.year;
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String get timeString {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'datetime': dateTime.toIso8601String(),
      };

  factory SmokingRecord.fromJson(Map<String, dynamic> json) {
    return SmokingRecord(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['datetime'] as String),
    );
  }

  static String listToJson(List<SmokingRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }

  static List<SmokingRecord> listFromJson(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SmokingRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
