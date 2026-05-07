import 'package:flutter/material.dart';

class StatusSaverAppSnackBar {

  static void show(
    BuildContext context, {
    String title = "Media Saved Successfully",
    String subtitle = "Saved to Download/StatusSaver",
    IconData icon = Icons.check,
  }) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE3EAF2),
                Color(0xFFC9D6FF),
                Color(0xFFA1C4FD),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            children: [

              /// ICON
              Container(
                width: 32,
                height: 32,

                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFFA1C4FD),
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF3A5080),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}