import 'package:project_x/features/auth/domain/models/country.dart';
import 'phone_formatter.dart';

class PhoneValidators {
  PhoneValidators._();

  static String? validatePhone(String? value, Country country) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    final digits = PhoneFormatter.getUnformattedDigits(value);

    if (digits.length < country.phoneLength) {
      return 'Enter a valid ${country.phoneLength}-digit phone number';
    }

    if (digits.length > country.phoneLength) {
      return 'Phone number cannot exceed ${country.phoneLength} digits';
    }

    return null;
  }
}
