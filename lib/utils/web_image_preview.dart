import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:http/http.dart' as http;

class WebImagePreview extends StatefulWidget {
  final String path;
  String? type;
  String? id;
  GoogleSignIn? client;

  WebImagePreview(
      {required this.path, this.type, this.id, this.client, Key? key})
      : super(key: key);

  @override
  WebImagePreviewState createState() => WebImagePreviewState();
}

class WebImagePreviewState extends State<WebImagePreview> {
  bool isShow = false;
  @override
  void initState() {
    if (widget.type == "drive") {
      callDriveImagePremision();
    }
    super.initState();
  }

  callDriveImagePremision() async {
    isShow = true;
    setState(() {});
    var httpClient = await widget.client!.authenticatedClient();
    if (httpClient == null) {
      print('Failed to get authenticated client');
      return null;
    }

    final apiUrl =
        "https://www.googleapis.com/drive/v3/files/${widget.id}/permissions";

    final headers = {
      'Authorization': 'Bearer ${httpClient.credentials.accessToken.data}',
      'Content-Type': 'application/json'
    };

    final body = jsonEncode({"role": "reader", "type": "anyone"});

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        isShow = false;
        setState(() {});
        print("Permission set successfully for anyone with the link.");
      } else {
        print("Failed to set permission: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
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
            child: isShow
                ? const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: CircularProgressIndicator(),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.path,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            )),
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
