import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GooglePhotosPickerWebView extends StatefulWidget {
  final String pickerUri;

  GooglePhotosPickerWebView({required this.pickerUri});

  @override
  _GooglePhotosPickerWebViewState createState() => _GooglePhotosPickerWebViewState();
}

class _GooglePhotosPickerWebViewState extends State<GooglePhotosPickerWebView> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onHttpError: (HttpResponseError error) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )
  ..loadRequest(Uri.parse(widget.pickerUri));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Photos Picker")),
      body: WebViewWidget(controller: controller),
    );
  }
}
