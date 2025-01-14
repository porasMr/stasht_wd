import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DriveImagePreview extends StatefulWidget {
   DriveImagePreview({super.key,required this.fileId});
  String fileId;


  @override
  State<DriveImagePreview> createState() => _DriveImagePreviewState();
}

class _DriveImagePreviewState extends State<DriveImagePreview>  {
  String path='';
  @override
  void initState() {
    path="https://drive.google.com/uc?export=view&id=${widget.fileId}";
    super.initState();
  }

void convertToDirectLink(
     String fileId, String accessToken, var driveApi) {
    // The file ID is at index 5
    final directLink = 'https://drive.google.com/uc?export=view&id=$fileId';
    print("After ========>$directLink");
    changeFilePermission(fileId, accessToken, driveApi);
    path=directLink;
    setState(() {
      
    });
  }

  Future<void> changeFilePermission(
      String fileId, String? accessToken, var driveApi) async {
    if (accessToken == null) {
      throw Exception('Access token is null');
    }
    final authHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    // Create a Google Drive API client
    // final driveApi = drive.DriveApi(httpClient);
    // Create a permission object to set to "Anyone with the link" (public)
    final newPermission = driveApi.Permission(
      type: 'anyone', // Permission type: "anyone"
      role: 'reader', // Role: "reader" (view only)
    );
    try {
      // Apply the new permission to the file
      await driveApi.permissions.create(
        newPermission,
        fileId, // The Google Drive file ID
      );
       setState(() {
      
    });
      print(
          'File permissions updated: Now anyone with the link can access the file.');
    } catch (e) {
     
    
      print('Failed to change permission: $e');
    } finally {}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                    imageUrl: path,
                    fit: BoxFit.cover,
                   
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                            value: downloadProgress.progress)),
              )),
          Positioned(
            top: 0,
            right: -10,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
