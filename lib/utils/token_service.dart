import 'dart:convert';

import 'package:flutter/cupertino.dart';

class TokenService {
  // Function to decode JWT and extract payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      // Split token into 3 parts (header, payload, signature)
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception("Invalid token");
      }

      // Decode payload (second part)
      final payload = parts[1];
      final decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(payload)));

      // Convert decoded payload into a Map
      return jsonDecode(decodedPayload);
    } catch (e) {
      debugPrint("Error decoding token: $e");
      return null;
    }
  }
}
