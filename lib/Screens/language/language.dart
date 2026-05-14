import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/config/apptext/app_text.dart';
import 'package:status_saver/config/images/app_images.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const List<_LanguageItem> _languages = [
    _LanguageItem(name: 'English', flagEmoji: '🇬🇧', isSelected: true),
    _LanguageItem(name: 'Mexican', flagEmoji: '🇲🇽'),
    _LanguageItem(name: 'Portuguese', flagEmoji: '🇷🇺'),
    _LanguageItem(name: 'Spanish', flagEmoji: '🇪🇸'),
    _LanguageItem(name: 'English', flagEmoji: '🇬🇧'),
    _LanguageItem(name: 'Mexican', flagEmoji: '🇲🇽'),
    _LanguageItem(name: 'Portuguese', flagEmoji: '🇷🇺'),
    _LanguageItem(name: 'Spanish', flagEmoji: '🇪🇸'),
    _LanguageItem(name: 'English', flagEmoji: '🇬🇧'),
    _LanguageItem(name: 'Mexican', flagEmoji: '🇲🇽'),
    _LanguageItem(name: 'Portuguese', flagEmoji: '🇷🇺'),
    _LanguageItem(name: 'Spanish', flagEmoji: '🇪🇸'),
    _LanguageItem(name: 'English', flagEmoji: '🇬🇧'),
    _LanguageItem(name: 'Mexican', flagEmoji: '🇲🇽'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8EEF5),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            AllIcons.backArrow,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              Colors.black87,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          AppText.language,
          style: AppColor1().customTextStyle12().copyWith(fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFDDE3EA), height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _LanguageTile(item: _languages[index]);
        },
      ),
    );
  }
}

// ─── Model ─────────────────────────────────────────────────────────────────
class _LanguageItem {
  final String name;
  final String flagEmoji;
  final bool isSelected;

  const _LanguageItem({
    required this.name,
    required this.flagEmoji,
    this.isSelected = false,
  });
}

// ─── Tile ──────────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final _LanguageItem item;

  const _LanguageTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: handle selection
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // ── Circular flag container ──
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0F4F8),
                  ),
                  child: Center(
                    child: Text(
                      item.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  item.isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: item.isSelected ? Colors.black87 : Colors.black26,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}