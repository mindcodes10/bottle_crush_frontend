import 'dart:convert';
import 'dart:io';
import 'package:bottle_crush/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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
        print("Login Successful: $responseData");

        // Store the token in Flutter Secure Storage
        if (responseData.containsKey('token')) {
          await secureStorage.write(key: 'access_token', value: responseData['token']);
        }
        return responseData;
      } else {
        // Handle errors
        print("Login Failed: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // Function to create a business
  Future<Map<String, dynamic>?> createBusiness(Map<String, dynamic> businessData) async {
    final url = Uri.parse(ApiConstants.createBusiness); // Endpoint URL

    try {
      // Retrieve the token from secure storage
      final token = await secureStorage.read(key: 'access_token');

      if (token == null) {
        print("Error: No token found. Please login first.");
        return null;
      }

      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Include the token
        },
        body: jsonEncode(businessData), // Convert business data to JSON
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful creation
        final responseData = jsonDecode(response.body);
        print("Business Created Successfully: $responseData");
        return responseData;
      } else {
        // Handle errors
        print("Business Creation Failed: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during business creation: $e");
      return null;
    }
  }

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
        print("API Response: $jsonResponse"); // Log the response for debugging
        return jsonResponse['businesses']; // Adjust this based on your API response structure
      } else {
        throw Exception('Failed to load business details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching business details: $e');
      throw Exception('Error fetching business details: $e');
    }
  }
}
