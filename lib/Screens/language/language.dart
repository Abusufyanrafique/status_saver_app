import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/bloc/language/language_bloc.dart';
import 'package:status_saver/bloc/language/language_event.dart';
import 'package:status_saver/bloc/language/language_state.dart';
import 'package:status_saver/config/apptext/app_text.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/models/language_model.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8EEF5),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            AllIcons.backArrow,
            width: getWidth(22),
            height: getHeight(22),
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
          child: Container(
            color: const Color(0xFFDDE3EA),
            height: 1,
          ),
        ),
      ),

      // ── BlocBuilder wraps the list ──────────────────────────────────────
      body: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          // Selected language determine karo
          final selected = state is LanguageLoaded
              ? state.selectedLanguage
              : LanguageModel.all.first;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            itemCount: LanguageModel.all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final lang = LanguageModel.all[index];

              // Selected check — code + countryCode dono match hone chahiye
              final isSelected = lang.code == selected.code &&
                  lang.countryCode == selected.countryCode;

              return _LanguageTile(
                language: lang,
                isSelected: isSelected,
                onTap: () {
                  // Bloc ko ChangeLanguage event bhejna
                   print("Tapped: $lang");
                   print(lang.name);
                   print(lang.code);
                  context.read<LanguageBloc>().add(ChangeLanguage(lang));
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Tile ──────────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(56),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ── Selected hone par blue border ──
        border: isSelected
            ? Border.all(color: Colors.blue, width: 1.5)
            : null,
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
          onTap: onTap, // ← Bloc event yahan fire hoga
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // ── Circular flag container ──
                Container(
                  width: getWidth(38),
                  height: getHeight(38),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0F4F8),
                  ),
                  child: Center(
                    child: Text(
                      language.flag,
                      style: TextStyle(fontSize: getFont(20)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Language name + native name ──
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.name,
                        style: TextStyle(
                          fontSize: getFont(15),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        language.nativeName,
                        style: TextStyle(
                          fontSize: getFont(11),
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Radio icon ──
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.black26,
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