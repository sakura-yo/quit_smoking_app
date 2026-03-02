import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class SettingsSection extends StatefulWidget {
  final StorageService storage;

  const SettingsSection({super.key, required this.storage});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  late TextEditingController _priceController;
  late TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.storage.getPricePerPack()?.toString() ?? '',
    );
    _targetController = TextEditingController(
      text: widget.storage.getDailyTarget()?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '設定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B9CB3),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(
                    width: 140,
                    child: Text(
                      '一日の目標本数',
                      style: TextStyle(color: Color(0xFFE6EDF3)),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Color(0xFFE6EDF3)),
                      decoration: InputDecoration(
                        hintText: '10',
                        filled: true,
                        fillColor: const Color(0xFF243044),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2D3A4D)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 1) {
                          widget.storage.saveDailyTarget(n);
                        } else if (v.isEmpty) {
                          widget.storage.saveDailyTarget(null);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 140,
                    child: Text(
                      'ひと箱の値段（円）',
                      style: TextStyle(color: Color(0xFFE6EDF3)),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Color(0xFFE6EDF3)),
                      decoration: InputDecoration(
                        hintText: '500',
                        filled: true,
                        fillColor: const Color(0xFF243044),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2D3A4D)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          widget.storage.savePricePerPack(n);
                        } else if (v.isEmpty) {
                          widget.storage.savePricePerPack(null);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '1箱＝20本として、カレンダーにその日の金額を表示します。目標本数に到達するとメッセージを表示します。',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B9CB3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
