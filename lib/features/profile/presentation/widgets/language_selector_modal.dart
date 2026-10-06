import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';

class LanguageItem {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class LanguageSelectorModal extends StatefulWidget {
  final String selectedCode;
  final Function(LanguageItem) onSelect;

  const LanguageSelectorModal({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  static const List<LanguageItem> languages = [
    LanguageItem(code: 'en', name: 'English', nativeName: 'English (IN)', flag: '🇬🇧'),
    LanguageItem(code: 'hi', name: 'Hindi', nativeName: 'हिंदी', flag: '🇮🇳'),
    LanguageItem(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    LanguageItem(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    LanguageItem(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    LanguageItem(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
  ];

  @override
  State<LanguageSelectorModal> createState() => _LanguageSelectorModalState();
}

class _LanguageSelectorModalState extends State<LanguageSelectorModal> {
  late String _currentCode;

  @override
  void initState() {
    super.initState();
    _currentCode = widget.selectedCode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFFEF08A), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.language_rounded, color: AppColors.textDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language Preference',
                      style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      'Select your preferred app display language',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: LanguageSelectorModal.languages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final lang = LanguageSelectorModal.languages[index];
              final isSelected = lang.code == _currentCode;

              return InkWell(
                onTap: () {
                  setState(() {
                    _currentCode = lang.code;
                  });
                  widget.onSelect(lang);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFEF08A).withValues(alpha: 0.3) : AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFEAB308) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.name, style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            Text(lang.nativeName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(color: AppColors.primaryYellow, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, size: 16, color: AppColors.textDark),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
