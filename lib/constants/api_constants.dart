class ApiConstants {
  // Base URL
  static const String baseUrl = "http://62.72.12.225:8005";
  //static const String baseUrl = "http://192.168.1.106:8000";

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

  // Forgot Password Endpoint
  static const String forgotPassword = "$baseUrl/users/forgot-password";

  // Add the verify OTP endpoint
  static const String verifyOtpEndpoint = '$baseUrl/users/verify-otp';

  // reset-password endpoint
  static const String resetPassword = "$baseUrl/users/reset-password";

  // Endpoint for "Get My Business"
  static const String myBusiness = "$baseUrl/my-business";
}
