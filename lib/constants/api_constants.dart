class ApiConstants {
  // Base URL
  static const String baseUrl = "http://62.72.12.225:8005";

  // Auth Endpoints
  static const String login = "$baseUrl/login/";
  static const String createBusiness = "$baseUrl/create_business";

  // Endpoint for viewing all businesses
  static const String viewBusiness = "$baseUrl/businesses";

  // Endpoint for viewing a business by ID
  static String getBusinessById(int businessId) => "$baseUrl/business/$businessId";

  // Endpoint for deleting a business
  static String deleteBusiness(int businessId) => "$baseUrl/business/$businessId";

  static const String viewMachines = "$baseUrl/machines";
  static const String createMachines = '$baseUrl/create_machines/';
  static const String updateMachine = "$baseUrl/machines";

  // Endpoint for deleting a machine
  static String deleteMachine(int machineId) => "$baseUrl/machines/$machineId";
}
