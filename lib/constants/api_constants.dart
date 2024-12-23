class ApiConstants {
  // Base URL
  static const String baseUrl = "http://62.72.12.225:8005";
  //static const String baseUrl = "http://192.168.1.104:8000";

  // Auth Endpoints
  static const String login = "$baseUrl/login/";
  static const String createBusiness = "$baseUrl/create_business";

  // Endpoint for viewing all businesses
  static const String viewBusiness = "$baseUrl/businesses";
}
