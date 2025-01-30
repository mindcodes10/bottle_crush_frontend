class ApiConstants {
  // Base URL
  static const String baseUrl = "http://62.72.12.225:8010";      // Test URL
  //static const String baseUrl = "http://62.72.12.225:8005"; // production URL
  //static const String baseUrl = "http://192.168.1.104:8000";

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

  // get machines by business
  static const String myMachines = "$baseUrl/my-machines";

  // update company details
  static const String updateBusiness = '$baseUrl/businesses/{business_id}';

  // get all the bottle count and bottle weight by business
  static const String myBottleStats = '$baseUrl/my-bottle-stats';

  // get total business count
  static const String businessCount = "$baseUrl/business-count";
  // get total machine count
  static const String machinesCount = "$baseUrl/machines-count";
  // get total bottle count and bottle weight
  static const String bottleStats = "$baseUrl/bottle-stats";

  // send email
  static const String sendEmailEndpoint = '$baseUrl/send-email';

  // export to excel for admin
  static const String dayWiseBottleStats = "$baseUrl/daywise-bottle-stats";

  // export to excel for company
  static const String dayWiseBottleStatsCompany = '$baseUrl/my-daywise-bottle-stats';

  static const String machineDetails = "$baseUrl/machine"; // Endpoint for machine details

  static const String businessStats = '$baseUrl/business-stats/{business_id}';

  // Endpoint for logout
  static const String logoutEndpoint = "$baseUrl/logout";

  static const String UPDATE_BUSINESS = "$baseUrl/update_business/{business_id}";

}
