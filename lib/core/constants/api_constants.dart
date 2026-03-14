/// API base URL and endpoints for Near Radio backend
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://nearadio.prokximatech.com';
  static const String stationsEndpoint = '/api/stations';
  static const String stationsByCountryPath = '/api/stations/country';
  static const String stationsByCategoryPath = '/api/stations/category';
  static const String stationsByLanguagePath = '/api/stations/language';
  static const String stationsTopByLocationPath = '/api/stations/top-by-location';
  static const String countriesEndpoint = '/api/countries';
  static const String categoriesEndpoint = '/api/categories';
  static const String languagesEndpoint = '/api/languages';

  /// Web pages (same domain)
  static const String termsConditionsUrl = 'https://nearadio.prokximatech.com/terms-conditions';
  static const String privacyPolicyUrl = 'https://nearadio.prokximatech.com/privacy-policy';
  static const String aboutUrl = 'https://nearadio.prokximatech.com/about';
}
