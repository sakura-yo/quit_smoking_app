import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/smoking_record.dart';
import '../services/storage_service.dart';
import '../widgets/smoke_button.dart';
import '../widgets/manual_input_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/calendar_history_tab.dart';
import '../widgets/goal_reached_dialog.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  final void Function(Locale locale) onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SmokingRecord> _records = [];
  OverlayEntry? _topToastEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _topToastEntry?.remove();
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
      if (mounted) _showToast(AppStrings.get(context, 'toastRecorded'));
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
    if (mounted) _showToast(AppStrings.get(context, 'toastDeleted'));
  }

  void _showToast(String message) {
    _topToastEntry?.remove();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _topToastEntry = entry;
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
      if (_topToastEntry == entry) _topToastEntry = null;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                AppStrings.get(context, 'appTitle'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6EDF3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                AppStrings.get(context, 'subtitle'),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B9CB3),
                ),
              ),
            ),
            SmokeButton(
              label: AppStrings.get(context, 'smoking'),
              onPressed: () => _addRecord(DateTime.now()),
            ),
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
                tabs: [
                  Tab(text: AppStrings.get(context, 'tabRecords')),
                  Tab(text: AppStrings.get(context, 'tabManual')),
                  Tab(text: AppStrings.get(context, 'tabSettings')),
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
                  SettingsSection(
                    storage: widget.storage,
                    onLocaleChanged: widget.onLocaleChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
