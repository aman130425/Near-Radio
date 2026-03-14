/// Country name to ISO 3166-1 alpha-2 code and flag image URL (flagcdn.com)

const Map<String, String> _countryNameToCode = {
  'United States': 'US',
  'United States of America': 'US',
  'USA': 'US',
  'India': 'IN',
  'United Kingdom': 'GB',
  'UK': 'GB',
  'Germany': 'DE',
  'France': 'FR',
  'Canada': 'CA',
  'Australia': 'AU',
  'Japan': 'JP',
  'Brazil': 'BR',
  'Russia': 'RU',
  'Italy': 'IT',
  'Spain': 'ES',
  'Mexico': 'MX',
  'Netherlands': 'NL',
  'Poland': 'PL',
  'Indonesia': 'ID',
  'Turkey': 'TR',
  'South Korea': 'KR',
  'Korea': 'KR',
  'China': 'CN',
  'Argentina': 'AR',
  'South Africa': 'ZA',
  'Egypt': 'EG',
  'Pakistan': 'PK',
  'Bangladesh': 'BD',
  'Nigeria': 'NG',
  'Philippines': 'PH',
  'Vietnam': 'VN',
  'Thailand': 'TH',
  'Malaysia': 'MY',
  'Singapore': 'SG',
  'Portugal': 'PT',
  'Greece': 'GR',
  'Czech Republic': 'CZ',
  'Romania': 'RO',
  'Hungary': 'HU',
  'Sweden': 'SE',
  'Norway': 'NO',
  'Denmark': 'DK',
  'Finland': 'FI',
  'Ireland': 'IE',
  'Belgium': 'BE',
  'Austria': 'AT',
  'Switzerland': 'CH',
  'Israel': 'IL',
  'Saudi Arabia': 'SA',
  'UAE': 'AE',
  'United Arab Emirates': 'AE',
  'New Zealand': 'NZ',
  'Colombia': 'CO',
  'Chile': 'CL',
  'Peru': 'PE',
  'Ukraine': 'UA',
};

String? countryNameToIsoCode(String name) {
  final key = name.trim();
  if (_countryNameToCode.containsKey(key)) return _countryNameToCode[key];
  if (key.length == 2) return key.toUpperCase();
  return null;
}

/// Flag image URL from flagcdn.com (80px width). Returns null if code invalid.
String? getCountryFlagImageUrl(String? iso2Code) {
  if (iso2Code == null || iso2Code.length != 2) return null;
  return 'https://flagcdn.com/w80/${iso2Code.toLowerCase()}.png';
}

/// Flag image URL from country name. Returns null if name not mapped.
String? getCountryFlagImageUrlFromName(String countryName) {
  final code = countryNameToIsoCode(countryName);
  return getCountryFlagImageUrl(code);
}

/// Flag emoji from country name (for fallback when image fails). Returns null if code unknown.
String? countryNameToFlagEmoji(String countryName) {
  final code = countryNameToIsoCode(countryName);
  if (code == null || code.length != 2) return null;
  final upper = code.toUpperCase();
  final first = 0x1F1E6 + (upper.codeUnitAt(0) - 0x41);
  final second = 0x1F1E6 + (upper.codeUnitAt(1) - 0x41);
  return String.fromCharCodes([first, second]);
}
