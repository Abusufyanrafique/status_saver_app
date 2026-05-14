import 'package:flutter/material.dart';
import 'package:status_saver/Screens/language/language.dart';
import 'package:status_saver/Screens/setting/setting_screen.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/config/apptext/app_text.dart';
import 'package:status_saver/config/images/app_images.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static final  List<_MenuItem> _menuItems = [

    _MenuItem(
      label: 'Language', 
      isHighlighted: true,
      onTap:(context){
         Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
      }
      ),
    _MenuItem(label: 'Remove Ads'),
    _MenuItem(label: 'Settings',
    onTap: (context){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
    ),
    _MenuItem(label: 'Share with other'),
    _MenuItem(label: 'Rate Us'),
    _MenuItem(label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    // 75% of screen width — same as screenshot
    final double drawerWidth = MediaQuery.of(context).size.width * 0.75;

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
              padding: const EdgeInsets.symmetric(
                horizontal: 16
                ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 18,
                    ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App icon
                    Image.asset(AppImages.logo),
                    const SizedBox(height: 12),
                     Text(
                      AppText.statusSaverApp,
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
                  children: _menuItems
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
        color: item.isHighlighted
            ? Colors.white
            : const Color(0xFFECEFF3),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.pop(context);
            // TODO: handle navigation
            if (item.onTap != null) {
              item.onTap!(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
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