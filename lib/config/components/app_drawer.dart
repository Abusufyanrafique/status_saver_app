import 'package:flutter/material.dart';
import 'package:status_saver/Screens/language/language.dart';
import 'package:status_saver/Screens/setting/setting_screen.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final double drawerWidth = MediaQuery.of(context).size.width * 0.75;

    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: t.language,
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
    Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
  decoration: const BoxDecoration(
    color: Colors.white,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: getWidth(60),
        height: getHeight(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            AppImages.logo,
            fit: BoxFit.cover,
          ),
        ),
      ),
       SizedBox(height: getHeight(7)),
      Text(
        t.statusSaverApp,
        style:  TextStyle(
          fontSize:getFont(16),
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 16),

            // ── Menu Items ──
            Expanded(
              child: Column(
                children: List.generate(menuItems.length, (index) {
                  return _DrawerTile(
                    item: menuItems[index],
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                      if (menuItems[index].onTap != null) {
                        menuItems[index].onTap!(context);
                      }
                    },
                  );
                }),
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
  final Function(BuildContext)? onTap;

  const _MenuItem({
    required this.label,
    this.onTap,
  });
}

// ─── Drawer Tile ───────────────────────────────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final _MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 16),
      child: Material(
        color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        shadowColor: Colors.black.withOpacity(0.25),
        elevation: 0.5,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Text(
                  item.label,
                  style: AppColor1().customTextStyleRegular10(
                    color: isSelected ? Colors.black : const Color(0xFFF7C7777),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ).copyWith(
                    fontSize: getFont(15),
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