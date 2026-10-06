import 'package:flutter/services.dart';
import 'package:project_x/features/auth/domain/models/country.dart';

class PhoneFormatter extends TextInputFormatter {
  final Country country;

  PhoneFormatter({required this.country});

  /// Formats raw digits into visual phone number representation
  static String formatRawNumber(String text, Country country) {
    // Strip non-digit characters
    String digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Handle pasted dial code if user pasted full number like +919876543210
    final rawDialDigits = country.dialCode.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith(rawDialDigits) && digitsOnly.length > country.phoneLength) {
      digitsOnly = digitsOnly.substring(rawDialDigits.length);
    }

    // Truncate to country max length
    if (digitsOnly.length > country.phoneLength) {
      digitsOnly = digitsOnly.substring(0, country.phoneLength);
    }

    if (country.code == 'IN') {
      // Format India: 5 digits + space + 5 digits (e.g. 98765 43210)
      if (digitsOnly.length <= 5) {
        return digitsOnly;
      } else {
        return '${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
      }
    } else if (country.code == 'US' || country.code == 'CA') {
      // Format US/CA: (3) 3-4 (e.g. 202 555 0123)
      if (digitsOnly.length <= 3) {
        return digitsOnly;
      } else if (digitsOnly.length <= 6) {
        return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
      } else {
        return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
      }
    } else {
      // General format: group into 4s or 5s
      if (digitsOnly.length <= 4) {
        return digitsOnly;
      } else if (digitsOnly.length <= 8) {
        return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
      } else {
        return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 8)} ${digitsOnly.substring(8)}';
      }
    }
  }

  /// Extracts digits only from formatted string
  static String getUnformattedDigits(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatRawNumber(newValue.text, country);

    // Calculate cursor position dynamically
    int cursorPosition = formatted.length;
    if (newValue.selection.baseOffset <= newValue.text.length) {
      final digitsBeforeCursor = getUnformattedDigits(
        newValue.text.substring(0, newValue.selection.baseOffset),
      ).length;

      int count = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (RegExp(r'\d').hasMatch(formatted[i])) {
          count++;
        }
        if (count == digitsBeforeCursor) {
          cursorPosition = i + 1;
          break;
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
