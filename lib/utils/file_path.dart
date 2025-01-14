import 'dart:convert';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    // Compress the image using flutter_image_compress
    final result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 700, // Minimum width (optional)
      minHeight: 1350, // Minimum height (optional)
      quality: 90, // Quality (1-100, lower means more compression)
      rotate: 0, // Rotate (optional)
    );

    if (result != null) {
      // Save the compressed image to a new file
      try{
      final compressedFile = await File(file.path.replaceFirst(RegExp(r'\.[a-zA-Z]+$'), '_compressed.jpg')).writeAsBytes(result);
           return compressedFile; // Return the compressed image file

      }catch(e){
return file;
      }
    }
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
                  message('Failed to upload post: ${response.body}');

      print('Failed to upload post: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
  
  static Future<String>? getImageLocation(AssetEntity asset) async {
    // Get the file path of the image from AssetEntity
    File? file = await asset.originFile;
    var address = "";
    if (file != null) {
      try {
        // Read EXIF data from the file bytes
        final bytes = await file.readAsBytes();
        final tags = await readExifFromBytes(bytes);

        // Check if the image contains GPS data
        if (tags.containsKey('GPS GPSLatitude') &&
            tags.containsKey('GPS GPSLongitude')) {
          PermissionStatus status =
              await Permission.accessMediaLocation.request();

          if (status.isGranted) {
            // Fetch latitude and longitude from the photo metadata
            final LatLng latLng = await asset.latlngAsync();
            if (latLng != null &&
                (latLng.latitude != 0.0 || latLng.longitude != 0.0)) {
              print(
                  'Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');
              address = await getAddressFromLatLng(
                      latLng.latitude ?? 0.0, latLng.longitude ?? 0.0) ??
                  "";
            } else {
              print('No location data found or lat/long is 0.0');
            }
          } else {
            print('Permission denied');
          }
        } else {
          print("No GPS location data found for this image.");
        }
      } catch (e) {
        print("Error reading EXIF data: $e");
      }
    } else {
      print("Unable to get the file from asset.");
    }
    return address;
  }
  static Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      // Use the placemarkFromCoordinates method to get location details
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      // Accessing the first placemark (usually the most relevant)
      Placemark place = placemarks[0];

      // Constructing a readable address
      String address = '${place.street}, ${place.locality}';
      return address;
    } catch (e) {
      print('Error: $e');
    }
  }

}