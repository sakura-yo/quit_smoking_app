import 'package:flutter/material.dart';
import '../models/smoking_record.dart';
import '../services/storage_service.dart';
import '../widgets/smoke_button.dart';
import '../widgets/manual_input_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/calendar_history_tab.dart';
import '../widgets/goal_reached_dialog.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SmokingRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRecords() async {
    final list = widget.storage.getRecords();
    setState(() => _records = list);
  }

  Future<void> _addRecord(DateTime dt) async {
    final record = SmokingRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_records.length}',
      dateTime: dt,
    );
    _records.insert(0, record);
    _records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await widget.storage.saveRecords(_records);
    setState(() {});

    final target = widget.storage.getDailyTarget();
    final dateStr = _dateKey(dt);
    final countThatDay =
        _records.where((r) => _dateKey(r.dateTime) == dateStr).length;
    if (target != null && countThatDay >= target) {
      if (mounted) _showGoalReachedDialog(target);
    } else {
      if (mounted) _showToast('記録しました');
    }
  }

  String _dateKey(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _deleteRecord(SmokingRecord record) async {
    _records.removeWhere((r) => r.id == record.id);
    await widget.storage.saveRecords(_records);
    setState(() {});
    if (mounted) _showToast('削除しました');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2332),
      ),
    );
  }

  void _showGoalReachedDialog(int targetCount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GoalReachedDialog(
        targetCount: targetCount,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  static const double _maxContentWidth = 420;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    '禁煙記録',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6EDF3),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '喫煙した日時を記録して振り返りましょう',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B9CB3),
                ),
              ),
            ),
            SmokeButton(onPressed: () => _addRecord(DateTime.now())),
            const SizedBox(height: 12),
            Material(
              color: const Color(0xFF1A2332),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF00C896),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                dividerHeight: 0,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                labelColor: const Color(0xFF0F1419),
                unselectedLabelColor: const Color(0xFF8B9CB3),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: '喫煙記録'),
                  Tab(text: '手入力'),
                  Tab(text: '設定'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CalendarHistoryTab(
                    records: _records,
                    storage: widget.storage,
                    onDelete: _deleteRecord,
                  ),
                  ManualInputSection(
                    onRecordAdded: _addRecord,
                    storage: widget.storage,
                  ),
                  SettingsSection(storage: widget.storage),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
