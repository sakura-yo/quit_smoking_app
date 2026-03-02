import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/smoking_record.dart';
import '../services/storage_service.dart';

class CalendarHistoryTab extends StatefulWidget {
  final List<SmokingRecord> records;
  final StorageService storage;
  final void Function(SmokingRecord) onDelete;

  const CalendarHistoryTab({
    super.key,
    required this.records,
    required this.storage,
    required this.onDelete,
  });

  @override
  State<CalendarHistoryTab> createState() => _CalendarHistoryTabState();
}

class _CalendarHistoryTabState extends State<CalendarHistoryTab> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  static const _cigsPerPack = 20;

  String _dateKey(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, int> _getCountPerDay() {
    final count = <String, int>{};
    for (final r in widget.records) {
      count[r.dateString] = (count[r.dateString] ?? 0) + 1;
    }
    return count;
  }

  int? _getMonthTotal(int year, int month) {
    final price = widget.storage.getPricePerPack();
    if (price == null || price <= 0) return null;
    final countPerDay = _getCountPerDay();
    final last = DateTime(year, month + 1, 0);
    int total = 0;
    for (int d = 1; d <= last.day; d++) {
      final key = _dateKey(DateTime(year, month, d));
      final n = countPerDay[key] ?? 0;
      total += ((n / _cigsPerPack) * price).round();
    }
    return total;
  }

  int _getHonme(SmokingRecord record) {
    final sameDay = widget.records
        .where((r) => r.dateString == record.dateString)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final idx = sameDay.indexWhere((r) => r.id == record.id);
    return idx == -1 ? 1 : idx + 1;
  }

  String? _getElapsed(SmokingRecord record, List<SmokingRecord> sorted) {
    final idx = sorted.indexWhere((r) => r.id == record.id);
    if (idx < 0 || idx + 1 >= sorted.length) return null;
    final prev = sorted[idx + 1].dateTime;
    final cur = record.dateTime;
    final diff = cur.difference(prev);
    final totalMinutes = diff.inMinutes;
    if (totalMinutes < 60) return '${totalMinutes}分前';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (m == 0) return '${h}時間前';
    return '${h}時間${m}分前';
  }

  @override
  Widget build(BuildContext context) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);
    final startPad = first.weekday % 7;
    final daysInMonth = last.day;
    final countPerDay = _getCountPerDay();
    final price = widget.storage.getPricePerPack();
    final selectedStr = _selectedDate != null ? _dateKey(_selectedDate!) : null;
    final monthTotal = _getMonthTotal(year, month);

    List<SmokingRecord> displayedRecords = widget.records;
    if (_selectedDate != null) {
      final key = _dateKey(_selectedDate!);
      displayedRecords =
          widget.records.where((r) => r.dateString == key).toList();
    }
    final sortedRecords = List<SmokingRecord>.from(widget.records)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(year, month - 1);
                          });
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            '$year年$month月',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFFE6EDF3),
                            ),
                          ),
                          if (monthTotal != null)
                            Text(
                              '合計 ¥${NumberFormat('#,###').format(monthTotal)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8B9CB3),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(year, month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      7,
                      (i) => Expanded(
                        child: Center(
                          child: Text(
                            ['日', '月', '火', '水', '木', '金', '土'][i],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B9CB3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.72,
                    children: [
                      ...List.generate(startPad, (_) => const SizedBox()),
                      ...List.generate(daysInMonth, (i) {
                        final d = i + 1;
                        final date = DateTime(year, month, d);
                        final key = _dateKey(date);
                        final n = countPerDay[key] ?? 0;
                        final isSelected = key == selectedStr;
                        final amountStr = (price != null && price > 0 && n > 0)
                            ? '¥${NumberFormat('#,###').format(((n / _cigsPerPack) * price).round())}'
                            : null;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate =
                                    _selectedDate != null &&
                                            _dateKey(_selectedDate!) == key
                                        ? null
                                        : date;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00C896)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$d',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF0F1419)
                                            : const Color(0xFFE6EDF3),
                                      ),
                                    ),
                                    if (n > 0) ...[
                                      const SizedBox(height: 1),
                                      Text(
                                        '${n}本',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF0F1419)
                                                  .withValues(alpha: 0.85)
                                              : const Color(0xFFE85D75),
                                        ),
                                      ),
                                      if (amountStr != null) ...[
                                        const SizedBox(height: 0),
                                        Text(
                                          amountStr,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isSelected
                                                ? const Color(0xFF0F1419)
                                                    .withValues(alpha: 0.7)
                                                : const Color(0xFF8B9CB3),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '履歴',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B9CB3),
                        ),
                      ),
                      if (_selectedDate != null)
                        Text(
                          '（${_selectedDate!.month}/${_selectedDate!.day}）',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B9CB3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (displayedRecords.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          '記録がありません',
                          style: TextStyle(color: Color(0xFF8B9CB3)),
                        ),
                      ),
                    )
                  else
                    ...displayedRecords.map((record) {
                      final honme = _getHonme(record);
                      final elapsed =
                          _getElapsed(record, sortedRecords);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF243044),
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedDate != null
                              ? Border.all(
                                  color: const Color(0xFF00C896),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        record.dateString,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFE6EDF3),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${honme}本目',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFE85D75),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        record.timeString,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8B9CB3),
                                        ),
                                      ),
                                      if (elapsed != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '前回から $elapsed',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFE8994A),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: const Color(0xFFE85D75),
                              onPressed: () => widget.onDelete(record),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
