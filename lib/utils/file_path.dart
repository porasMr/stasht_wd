import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:http/http.dart' as http;

class FilePath{
  static Future<String?> getFilePath(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file != null) {
      return file.path; // Return the file path
    }
    return null;
  }

  static Future<File?> getFile(AssetEntity assets) async {
    final File? file = (await assets.file);
    if (file != null) {
      return file; // Return the file path
    }
    return null;
  }

static Future<void> postImageToFacebook(String shareUrl, String accessToken,Function(String message) message) async {
  final url = Uri.parse('https://graph.facebook.com/v12.0/me/feed');

  // Parameters for the request
  final body = {
    'message': "STASHT memory", // Your post message
    'link': shareUrl,        // Link you want to share
    'access_token': accessToken, // Facebook access token
  };
  try {
    final response = await http.post(
      url, // Convert to Uri here
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
            message('Post uploaded successfully: ${responseData}');

    } else {
                  message('Failed to upload photo: ${response.body}');

      print('Failed to upload photo: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
  
}