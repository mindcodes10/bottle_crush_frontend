import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
          await secureStorage.write(
              key: 'access_token', value: responseData['token']);
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

  // Future<Map<String, dynamic>> createBusiness({
  //   required String token,
  //   required String name,
  //   required String mobile,
  //   required String email,
  //   required String password,
  //   File? logoImage, // Made logoImage optional
  // }) async {
  //   final uri = Uri.parse(ApiConstants.createBusiness);
  //   final request = http.MultipartRequest('POST', uri);
  //
  //   // Add headers
  //   request.headers['Authorization'] = 'Bearer $token';
  //   request.headers['Accept'] = 'application/json';
  //
  //   // Add fields
  //   request.fields['business_data[name]'] = name;
  //   request.fields['business_data[mobile]'] = mobile;
  //   request.fields['user_data[email]'] = email;
  //   request.fields['user_data[password]'] = password;
  //
  //   // Add logo image if it's not null
  //   if (logoImage != null) {
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'logo_image',
  //       logoImage.path,
  //     ));
  //   }
  //
  //   // Print request details for debugging
  //   print('Sending request to: ${request.url}');
  //   print('Request headers: ${request.headers}');
  //   print('Request fields: ${request.fields}');
  //   print('Request files: ${request.files.map((file) => file.filename).toList()}');
  //
  //   try {
  //     // Send the request
  //     final response = await request.send();
  //
  //     // Print the response status code
  //     print('Response status code: ${response.statusCode}');
  //
  //     // Handle the response
  //     if (response.statusCode == 200) {
  //       final responseData = await response.stream.toBytes();
  //       final responseString = String.fromCharCodes(responseData);
  //       print('Response body: $responseString'); // Print the response body
  //       return json.decode(responseString);
  //     } else {
  //       // Print error message before throwing exception
  //       print('Failed to create business: ${response.statusCode}');
  //       throw Exception('Failed to create business: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Print any exceptions that occur
  //     print('Error occurred: $e');
  //     throw Exception('Error occurred: $e');
  //   }
  // }

  // import 'dart:convert';
  // import 'dart:io';
  // import 'package:http/http.dart' as http;

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
        print('Response body: $responseBody');
        return jsonDecode(responseBody);
      } else {
        print('Failed to create business: ${response.statusCode}');
        throw Exception('Failed to create business: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred: $e');
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
        return jsonResponse[
            'businesses']; // Adjust this based on your API response structure
      } else {
        throw Exception(
            'Failed to load business details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching business details: $e');
      throw Exception('Error fetching business details: $e');
    }
  }

  // Method to fetch machine details
  Future<List<dynamic>> fetchMachineDetails(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.viewMachines),
        headers: {
          'Accept': 'application/json',
          'Authorization':
              'Bearer $token', // Include the bearer token in headers
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
      print('Error: $e');
      rethrow;
    }
  }

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
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        throw Exception('Failed to create machine: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
      rethrow;
    }
  }

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
    // Retrieve the access token from Flutter Secure Storage
    String? token = await secureStorage.read(key: "access_token");
    if (token == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    // API URL
    final String url = "${ApiConstants.updateMachine}/$machineId";

    // Request headers
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    // Request body
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
      body: jsonEncode(body),
    );

    return response;
  }
}
