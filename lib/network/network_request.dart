import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/pref_utils.dart';

class ApiClient {
  static Future<http.Response> postTypeApi({
    required String api,

   required Map<String, String?> body
  }) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Bypass SSL verification
    final httpClient = IOClient(ioc);
print(ApiUrl.baseUrl+api);

    final response = await httpClient.post(
      Uri.parse(ApiUrl.baseUrl+api),
      body: body,
      headers: {
        "Accept": "application/json",
      },
    );

    return response;
  }

  static Future<http.Response> getTypeApi({
    required String api,
  }) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Bypass SSL verification
    final httpClient = IOClient(ioc);


    final response = await httpClient.get(
      Uri.parse(ApiUrl.baseUrl+api),
      headers: {
        "Accept": "application/json",
      },
    );

    return response;
  }

   static Future<http.Response> postTypeWithTokenApi({
    required String api,
   required dynamic body
  }) async {
    print(PrefUtils.instance.getToken());
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Bypass SSL verification
    final httpClient = IOClient(ioc);


    final response = await httpClient.post(
      Uri.parse(ApiUrl.baseUrl+api),
      body: body,
      headers: {
        "Accept": "application/json",
        'Authorization':'Bearer ${PrefUtils.instance.getToken()}'
      },
    );

    return response;
  }

static Future<http.Response> postTypeWithJsonTokenApi({
    required String api,
   required dynamic body
  }) async {
    print(PrefUtils.instance.getToken());
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Bypass SSL verification
    final httpClient = IOClient(ioc);


    final response = await httpClient.post(
      Uri.parse(ApiUrl.baseUrl+api),
      body: body,
      headers: {
        "Content-Type": "application/json",
        'Authorization':'Bearer ${PrefUtils.instance.getToken()}'
      },
    );

    return response;
  }
static Future<http.Response> getTypeWithTokenApi({
    required String api,
  }) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Bypass SSL verification
    final httpClient = IOClient(ioc);


    final response = await httpClient.get(
      Uri.parse(ApiUrl.baseUrl+api),
      headers: {
        "Accept": "application/json",
        'Authorization':'Bearer ${PrefUtils.instance.getToken()}'
      },
    );

    return response;
  }

 static Future<StreamedResponse> uploadImageWithAuth({required String api,required String path}
) async {
  final Uri url = Uri.parse(ApiUrl.baseUrl+api);  // Your server endpoint

  // Create a multipart request
  var request = http.MultipartRequest('POST', url);

  // Add the Authorization header
  request.headers['Authorization'] = 'Bearer ${PrefUtils.instance.getToken()}';  // Include the Bearer token

  // Attach the file to the request
  var file = await http.MultipartFile.fromPath(
    'image',  // The name of the field in the backend (usually "file")
    path,
    contentType: MediaType('image', 'jpeg'), // MIME type based on the image format (e.g., 'image/jpeg')
  );

  
  // Add the file to the request
  request.files.add(file);

  // Send the request
  var response = await request.send();
return response;
 
}

}
