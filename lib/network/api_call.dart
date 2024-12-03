
import 'dart:convert';

import 'package:http/http.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/network/api_callback.dart';

import 'network_request.dart';

class ApiCall {
  static Future<void> registerUserAccount(
      {required String api,
      required String email,
      required String name,
      required String password,
      String? deviceToken,
      String? deviceType,
      required ApiCallback callack}) async {
    final body = {
      "email": email,
      "name": name,
      "password": password,
      "device_token": '',
      "device_type": '',
    };
    print(body);
    try {
      final Response response =
          await ApiClient.postTypeApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure("Something went wrong");
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> loginWithEmailPassword(
      {required String api,
      required String email,
      required String password,
      required ApiCallback callack}) async {
    final body = {
      "email": email,
      "password": password,
    };

    try {
      final Response response =
          await ApiClient.postTypeApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> scocialLogin(
      {required String api,
      required String email,
      required String type,
      required String name,
      required String id,
      required ApiCallback callack}) async {
    final body = {
      "email": email,
      "type": type,
      "id": id,
      "name": name,
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeApi(api: api, body: body);
      print(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> syncAccount(
      {required String api,
      required String type,
      required String status,
      required ApiCallback callack}) async {
    final body = {
      "type": type,
      "status": status,
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> category(
      {required String api, required ApiCallback callack}) async {
    try {
      final Response response = await ApiClient.getTypeWithTokenApi(
        api: api,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> getMomories(
      {required String api, required ApiCallback callack}) async {
    try {
      final Response response = await ApiClient.getTypeWithTokenApi(
        api: api,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> createCategory(
      {required String api,
      required String name,
      
      required ApiCallback callack}) async {
    final body = {
      "name": name,
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> ediCategory(
      {required String api,
      required String name,
      required String id,
      required ApiCallback callack}) async {
    final body = {
      "id": id,
      "name": name,
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteCategory(
      {required String api,
      required String id,
      required ApiCallback callack}) async {
    final body = {
      "id": id,
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> getSubCategory(
      {required String api, required ApiCallback callack}) async {
    try {
      final Response response = await ApiClient.getTypeWithTokenApi(
        api: api,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> memoryByCategory(
      {required String api,
      required String id,
      required String sub_category_id,
      required String type,
      required ApiCallback callack}) async {
    final body = {
      "category_id": id,
      "sub_category_id": sub_category_id,
      "type": type
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }
  static Future<void> createMemory(
      {required String api,
      required CreateMoemoryModel model,
      required ApiCallback callack}) async {
    final body = model.toJson();
    print(jsonEncode(body));

    try {
      final Response response =
          await ApiClient.postTypeWithJsonTokenApi(api: api, body:jsonEncode(body) );
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }



  static Future<void> uploadImageIntoMemory(
      {required String api,
      required String path,
      required String count,
      required ApiCallback callack}) async {
    
    try {
      
       final response=   await ApiClient.uploadImageWithAuth(api: api, path: path);
       // Handle the response
  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
        callack.onSuccess(responseBody+"=$count", api);

    // // Convert the response body to a Map or any other format depending on your API
    // var decodedResponse = json.decode(responseBody);

    // // You can now use the response data
    // print('Response Body: $decodedResponse');
    // print('Image uploaded successfully!');
    
  } else {
            callack.onFailure("Failed to upload image");

  }
    } catch (e) {
      print(e);
            callack.onFailure("Something went wrong");
    }
  }

 static Future<void> createSubCategory(
      {required String api,
      required String name,
      required String id,
      
      required ApiCallback callack}) async {
    final body = {
      "name": name,
            "category_id": id,

    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong",
        );
      }
    } catch (e) {
      print(e);
    }
  }
  
}