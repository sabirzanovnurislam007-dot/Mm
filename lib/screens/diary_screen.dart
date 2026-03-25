import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryEntry {
  final String id;
  final DateTime date;
  final String did;
  final String didNot;
  final String why;

  _DiaryEntry({
    required this.id,
    required this.date,
    required this.did,
    required this.didNot,
    required this.why,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'did': did,
        'didNot': didNot,
        'why': why,
      };

  factory _DiaryEntry.fromJson(Map<String, dynamic> json) => _DiaryEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        did: json['did'] as String,
        didNot: json['didNot'] as String,
        why: json['why'] as String,
      );
}

class _DiaryScreenState extends State<DiaryScreen> {
  static const _storageKey = 'diary_entries';
  List<_DiaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _entries = list
          .map((e) => _DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  void _openNewEntry(String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiaryEntrySheet(
        lang: lang,
        onSave: (entry) async {
          setState(() {
            _entries.insert(0, entry);
          });
          await _saveEntries();
        },
      ),
    );
  }

  void _deleteEntry(String id) async {
    setState(() {
      _entries.removeWhere((e) => e.id == id);
    });
    await _saveEntries();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('diary_title', lang),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          AppStrings.get('diary_entries', lang),
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _NewEntryButton(
                    lang: lang,
                    onTap: () => _openNewEntry(lang),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.accentGreen, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.get('diary_subtitle', lang),
                        style: TextStyle(
                            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Entries list or empty state
          if (_entries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book_outlined,
                        size: 72,
                        color: isDark
                            ? AppTheme.textMuted
                            : AppTheme.textMutedLight),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.get('diary_empty', lang),
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondaryLight,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _openNewEntry(lang),
                      icon: const Icon(Icons.add),
                      label: Text(AppStrings.get('diary_new', lang)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = _entries[index];
                    return _EntryCard(
                      entry: entry,
                      isDark: isDark,
                      lang: lang,
                      onDelete: () => _deleteEntry(entry.id),
                    );
                  },
                  childCount: _entries.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      ),  // SafeArea
    );
  }
}

// ── New Entry Button ─────────────────────────────────────────────────────────
class _NewEntryButton extends StatelessWidget {
  final String lang;
  final VoidCallback onTap;
  const _NewEntryButton({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              AppStrings.get('diary_new', lang),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry Card ───────────────────────────────────────────────────────────────
class _EntryCard extends StatelessWidget {
  final _DiaryEntry entry;
  final bool isDark;
  final String lang;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.isDark,
    required this.lang,
    required this.onDelete,
  });

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.bgCard : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDate(entry.date),
                  style: const TextStyle(
                      color: AppTheme.accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.textMuted),
              ),
            ],
          ),
          if (entry.did.isNotEmpty) ...[
            const SizedBox(height: 12),
            _EntryRow(
              icon: Icons.check_circle_outline,
              color: AppTheme.accentGreen,
              label: AppStrings.get('diary_did', lang),
              value: entry.did,
              isDark: isDark,
            ),
          ],
          if (entry.didNot.isNotEmpty) ...[
            const SizedBox(height: 10),
            _EntryRow(
              icon: Icons.cancel_outlined,
              color: AppTheme.accentOrange,
              label: AppStrings.get('diary_didnot', lang),
              value: entry.didNot,
              isDark: isDark,
            ),
          ],
          if (entry.why.isNotEmpty) ...[
            const SizedBox(height: 10),
            _EntryRow(
              icon: Icons.lightbulb_outline,
              color: AppTheme.accentCyan,
              label: AppStrings.get('diary_why', lang),
              value: entry.why,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool isDark;

  const _EntryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── New Entry Bottom Sheet ───────────────────────────────────────────────────
class _DiaryEntrySheet extends StatefulWidget {
  final String lang;
  final Future<void> Function(_DiaryEntry) onSave;

  const _DiaryEntrySheet({required this.lang, required this.onSave});

  @override
  State<_DiaryEntrySheet> createState() => _DiaryEntrySheetState();
}

class _DiaryEntrySheetState extends State<_DiaryEntrySheet> {
  final _didController = TextEditingController();
  final _didNotController = TextEditingController();
  final _whyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _didController.dispose();
    _didNotController.dispose();
    _whyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_didController.text.trim().isEmpty &&
        _didNotController.text.trim().isEmpty &&
        _whyController.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    final entry = _DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      did: _didController.text.trim(),
      didNot: _didNotController.text.trim(),
      why: _whyController.text.trim(),
    );
    await widget.onSave(entry);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('diary_saved', widget.lang)),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = widget.lang;
    final sheetBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('diary_new', lang),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            _SheetField(
              controller: _didController,
              title: AppStrings.get('diary_did', lang),
              hint: AppStrings.get('diary_did_hint', lang),
              icon: Icons.check_circle_outline,
              color: AppTheme.accentGreen,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _SheetField(
              controller: _didNotController,
              title: AppStrings.get('diary_didnot', lang),
              hint: AppStrings.get('diary_didnot_hint', lang),
              icon: Icons.cancel_outlined,
              color: AppTheme.accentOrange,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _SheetField(
              controller: _whyController,
              title: AppStrings.get('diary_why', lang),
              hint: AppStrings.get('diary_why_hint', lang),
              icon: Icons.lightbulb_outline,
              color: AppTheme.accentGreen,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        AppStrings.get('diary_save', lang),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String hint;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SheetField({
    required this.controller,
    required this.title,
    required this.hint,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          minLines: 2,
          style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            filled: true,
            fillColor: isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}
