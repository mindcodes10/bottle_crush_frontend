import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bottle_crush/constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Function to perform login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.login); // Endpoint URL

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        // Successful login, parse the response body
        final responseData = jsonDecode(response.body);
        debugPrint("Login Successful: $responseData");

        // Store the token in Flutter Secure Storage
        if (responseData.containsKey('token')) {
          await secureStorage.write(key: 'access_token', value: responseData['token']);
        }
        return responseData;
      } else {
        // Handle errors
        debugPrint("Login Failed: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error during login: $e");
      return null;
    }
  }

  // Function to create new company
  Future<Map<String, dynamic>> createBusiness({
    required String token,
    required String name,
    required String mobile,
    required String email,
    required String password,
    File? logoImage, // Optional logo image
  }) async {
    final uri = Uri.parse(ApiConstants.createBusiness);

    // Create a MultipartRequest
    var request = http.MultipartRequest('POST', uri);

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add business_data and user_data as fields
    request.fields['business_data'] = jsonEncode({
      "name": name,
      "mobile": mobile,
    });

    request.fields['user_data'] = jsonEncode({
      "email": email,
      "password": password,
    });

    // Add logo image as a file if provided
    if (logoImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'logo_image', // The key for the file in the request
        logoImage.path,
      ));
    }

    try {
      // Send the request
      var response = await request.send();

      // Parse the response
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Response body: $responseBody');
        return jsonDecode(responseBody);
      } else {
        debugPrint('Failed to create company: ${response.statusCode}');
        throw Exception('Failed to create company: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      throw Exception('Error occurred: $e');
    }
  }

  // Function to fetch company details
  Future<List<dynamic>> fetchBusinessDetails(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.viewBusiness),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Include the Bearer token
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        debugPrint("API Response: $jsonResponse"); // Log the response for debugging
        return jsonResponse['businesses']; // Adjust this based on your API response structure
      } else {
        throw Exception('Failed to load company details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching company details: $e');
      throw Exception('Error fetching company details: $e');
    }
  }

  // Method to fetch machine details
  Future<List<dynamic>> fetchMachineDetails(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.viewMachines),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Include the bearer token in headers
        },
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        List<dynamic> machines = json.decode(response.body);
        return machines;
      } else {
        throw Exception('Failed to load machine details');
      }
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  // Function to create new Machine
  Future<bool> createMachine({
    required String token,
    required String name,
    required String number,
    required String street,
    required String city,
    required String state,
    required String pinCode,
    required int businessId,
  }) async {
    final url = Uri.parse('http://62.72.12.225:8005/create_machines/');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Ensure Content-Type is JSON
    };
    final body = jsonEncode({
      'name': name,
      'number': number,
      'street': street,
      'city': city,
      'state': state,
      'pin_code': pinCode,
      'business_id': businessId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        throw Exception('Failed to create machine: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      rethrow;
    }
  }

  // Function to update machine details
  Future<http.Response> updateMachine({
    required int machineId,
    required String name,
    required String number,
    required String street,
    required String city,
    required String state,
    required String pinCode,
    required int businessId,
  }) async {
    String? token = await secureStorage.read(key: "access_token");
    if (token == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    final String url = "${ApiConstants.updateMachine}/$machineId";
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json", // Ensure Content-Type is set to JSON
    };

    // Prepare the request body as a Map
    Map<String, dynamic> body = {
      "name": name,
      "number": number,
      "street": street,
      "city": city,
      "state": state,
      "pin_code": pinCode,
      "business_id": businessId,
    };

    // Send the PUT request
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body), // Ensure this is a JSON string
    );

    debugPrint('Update Response Status Code: ${response.statusCode}');
    debugPrint('Update Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update machine: ${response.body}');
    }

    return response;
  }

  // Function to delete existing company
  Future<bool> deleteBusiness(int businessId) async {
    // Get the access token from secure storage
    String? token = await secureStorage.read(key: "access_token");

    if (token == null) {
      // Return false if token is not found
      return false;
    }

    // Prepare headers
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Send DELETE request
    final response = await http.delete(
      Uri.parse(ApiConstants.deleteBusiness(businessId)),
      headers: headers,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      // Handle error (you can check the response body for more details)
      debugPrint('Error: ${response.statusCode}');
      return false; // Failure to delete
    }
  }

  // Function to delete existing machine
  Future<bool> deleteMachine(int machineId) async {
    try {
      // Get the stored token from Flutter secure storage
      String? token = await secureStorage.read(key: "access_token");
      if (token == null) {
        throw Exception("No token found");
      }

      // Construct the URL for the delete request
      String url = ApiConstants.deleteMachine(machineId);

      // Send the DELETE request with the Bearer token
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        return true; // Machine deleted successfully
      } else {
        return false; // Failed to delete the machine
      }
    } catch (e) {
      debugPrint("Error deleting machine: $e");
      return false; // Error occurred
    }
  }

  // Function to get company details by user id
  Future<Map<String, dynamic>> getBusinessById(int businessId) async {
    try {
      // Retrieve token from secure storage
      final token = await secureStorage.read(key: "access_token");

      if (token == null) {
        throw Exception("Token not found");
      }

      // API endpoint
      final url = ApiConstants.getBusinessById(businessId);

      // HTTP GET request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Check for successful response
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch company details: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error in getBusinessById: $e");
    }
  }

  // Function to send otp to the email
  Future<Map<String, dynamic>> sendForgotPasswordEmail(String email) async {
    final Uri url = Uri.parse(ApiConstants.forgotPassword);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send forgot password email: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Function to verify the entered otp
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse(ApiConstants.verifyOtpEndpoint);

    // Prepare the request payload
    final Map<String, dynamic> body = {
      'email': email,
      'otp': otp,
    };

    try {
      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Check if the response is successful (HTTP status 200)
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;  // Return the response from the API
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      // Handle any errors
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Function to reset the password
  Future<Map<String, dynamic>> passwordReset(String resetToken, String newPassword) async {
    final url = Uri.parse(ApiConstants.resetPassword);

    try {
      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'reset_token': resetToken,
          'new_password': newPassword,
        }),
      );

      debugPrint('Request Body: ${json.encode({
        'reset_token': resetToken,
        'new_password': newPassword,
      })}');

      if (response.statusCode == 200) {
        // Return the response as a map if the request is successful
        debugPrint('Response body : $response');
        return json.decode(response.body);

      } else {
        // If the request failed, throw an error with the response message
        throw Exception('Failed to reset password: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error in resetPassword: $e");
      throw Exception('Error resetting password');
    }
  }

  // Function to get "My Company" data
  Future<Map<String, dynamic>> getMyBusiness() async {
    const url = ApiConstants.myBusiness;

    try {
      // Retrieve the access token from Flutter Secure Storage
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Access token not found. Please log in again.'
        };
      }

      debugPrint('Access Token : $accessToken');

      // Configure headers with the Bearer token and additional headers
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // Parse and return the JSON response
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Handle error response
        return {
          'success': false,
          'message': 'Failed to fetch company data: ${response.statusCode}'
        };
      }
    } catch (error) {
      // Handle network or parsing errors
      return {
        'success': false,
        'message': 'An error occurred: $error',
      };
    }
  }

  // Function to fetch the machine details by company
  Future<List<Map<String, dynamic>>?> fetchMachines(String token) async {
    final url = Uri.parse(ApiConstants.myMachines);
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        // Handle non-200 responses
        debugPrint("Error: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      // Handle connection or parsing errors
      debugPrint("Exception: $e");
      return null;
    }
  }

  // function to update company details
  Future<Map<String, dynamic>> updateBusiness(
      String token, int businessId, String name, String mobile) async {
    final url = ApiConstants.updateBusiness.replaceAll('{business_id}', businessId.toString());
    final headers = {
      'Content-Type': 'application/json', // Specify JSON content
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'name': name,
      'mobile': mobile,
    });

    debugPrint('Request URL: $url');
    debugPrint('Request Headers: $headers');
    debugPrint('Request Body: $body'); // Debugging

    try {
      final response = await http.put(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error response: ${response.body}'); // Log error
        throw Exception('Failed to update business: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
      throw Exception('An error occurred: $error');
    }
  }



}
