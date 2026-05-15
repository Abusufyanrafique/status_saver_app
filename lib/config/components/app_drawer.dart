import 'package:flutter/material.dart';
import 'package:status_saver/Screens/language/language.dart';
import 'package:status_saver/Screens/setting/setting_screen.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final double drawerWidth = MediaQuery.of(context).size.width * 0.75;

    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: t.language,
        isHighlighted: true,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LanguageScreen()),
          );
        },
      ),
      _MenuItem(label: t.removeAds),
      _MenuItem(
        label: t.settings,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      _MenuItem(label: t.shareWithOther),
      _MenuItem(label: t.rateUs),
      _MenuItem(label: t.about),
    ];

    return Drawer(
      width: drawerWidth,
      backgroundColor: const Color(0xFFDDE3EA),
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Icon + Name ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppImages.logo),
                    const SizedBox(height: 12),
                    Text(
                      t.statusSaverApp,
                      style: AppColor1().customTextStyle12().copyWith(
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Menu Items ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: menuItems
                      .map((item) => _DrawerTile(item: item))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Item Model ───────────────────────────────────────────────────────
class _MenuItem {
  final String label;
  final bool isHighlighted;
  final Function(BuildContext)? onTap;

  const _MenuItem({
    required this.label,
    this.isHighlighted = false,
    this.onTap,
  });
}

// ─── Drawer Tile ───────────────────────────────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final _MenuItem item;

  const _DrawerTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: item.isHighlighted ? Colors.white : const Color(0xFFECEFF3),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.pop(context);
            if (item.onTap != null) {
              item.onTap!(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: item.isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: Colors.black87,
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