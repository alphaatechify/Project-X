import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String name;
  final String code;
  final String dialCode;
  final String flagEmoji;
  final int phoneLength;
  final String exampleNumber;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagEmoji,
    this.phoneLength = 10,
    this.exampleNumber = '98765 43210',
  });

  static const Country india = Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flagEmoji: '🇮🇳',
    phoneLength: 10,
    exampleNumber: '98765 43210',
  );

  static const List<Country> defaultCountries = [
    india,
    Country(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flagEmoji: '🇺🇸',
      phoneLength: 10,
      exampleNumber: '202 555 0123',
    ),
    Country(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flagEmoji: '🇬🇧',
      phoneLength: 10,
      exampleNumber: '7911 123456',
    ),
    Country(
      name: 'United Arab Emirates',
      code: 'AE',
      dialCode: '+971',
      flagEmoji: '🇦🇪',
      phoneLength: 9,
      exampleNumber: '50 123 4567',
    ),
    Country(
      name: 'Canada',
      code: 'CA',
      dialCode: '+1',
      flagEmoji: '🇨🇦',
      phoneLength: 10,
      exampleNumber: '416 555 0123',
    ),
    Country(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flagEmoji: '🇦🇺',
      phoneLength: 9,
      exampleNumber: '412 345 678',
    ),
    Country(
      name: 'Singapore',
      code: 'SG',
      dialCode: '+65',
      flagEmoji: '🇸🇬',
      phoneLength: 8,
      exampleNumber: '8123 4567',
    ),
    Country(
      name: 'Germany',
      code: 'DE',
      dialCode: '+49',
      flagEmoji: '🇩🇪',
      phoneLength: 11,
      exampleNumber: '151 23456789',
    ),
    Country(
      name: 'France',
      code: 'FR',
      dialCode: '+33',
      flagEmoji: '🇫🇷',
      phoneLength: 9,
      exampleNumber: '6 12 34 56 78',
    ),
    Country(
      name: 'Japan',
      code: 'JP',
      dialCode: '+81',
      flagEmoji: '🇯🇵',
      phoneLength: 10,
      exampleNumber: '90 1234 5678',
    ),
  ];

  @override
  List<Object?> get props => [name, code, dialCode, flagEmoji, phoneLength];
}
