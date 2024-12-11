import 'dart:convert';

import 'package:http/http.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';

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

  static Future<void> memoryDetails(
      {required String api,
      required String id,
      required String page,
      required ApiCallback callack}) async {
    final body = {"memory_id": id, "page": page};
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
      required String page,
      required ApiCallback callack}) async {
    final body = {
      "category_id": id,
      "sub_category_id": sub_category_id,
      "type": type,
      "page": page
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
    var body;
    if (api == ApiUrl.createMemory) {
      body = model.toJson();
    } else {
      body = model.toWithMemoryIdJson();
    }
    print(jsonEncode(body));

    try {
      final Response response = await ApiClient.postTypeWithJsonTokenApi(
          api: api, body: jsonEncode(body));
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          json.decode(response.body)['message'],
        );
      }
    } catch (e) {
      print(e);
      callack.onFailure(
        json.decode("Something went wrong"),
      );
    }
  }

  static Future<void> uploadImageIntoMemory(
      {required String api,
      required String path,
      required String count,
      required ApiCallback callack}) async {
    try {
      final response =
          await ApiClient.uploadImageWithAuth(api: api, path: path);
      // Handle the response
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        callack.onSuccess(responseBody + "=$count", api);

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

  static Future<void> updateProfile(
      {required String api,
      required String type,
      required String value,
      required ApiCallback callack}) async {
    final body = {
      "type": type,
      "value": value,
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

  static Future<void> changePassword(
      {required String api,
      required String newPassword,
      required String oldPassword,
      required ApiCallback callack}) async {
    final body = {
      "new_password": newPassword,
      "old_password": oldPassword,
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

  static Future<void> memoryPublished(
      {required String api,
      required String status,
      required String id,
      required ApiCallback callack}) async {
    final body = {
      "memory_id": id,
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

  static Future<void> deleteMemoryFile(
      {required String api,
      required String fileId,
      required String id,
      required ApiCallback callack}) async {
    final body = {
      "memory_id": id,
      "file_id": fileId,
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

  static Future<void> deleteMemory(
      {required String api,
      required String id,
      required ApiCallback callack}) async {
    final body = {
      "memory_id": id,
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

  static Future<void> saveFileDescription(
      {required String api,
      required String fileId,
      required String id,
      required String description,
      required ApiCallback callack}) async {
    final body = {
      "memory_id": id,
      "file_id": fileId,
      "description": description,
    };
    print(body);

    try {
      final Response response =
          await ApiClient.postTypeWithTokenApi(api: api, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        callack.onSuccess(response.body, api);
      } else {
        callack.onFailure(
          "Something went wrong(${response.statusCode})",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> addCollabarator({
    required String api,
    required String memoryID,
    required String userId,
    required ApiCallback callback,
  }) async {
    final body = {
      "memory_id": memoryID,
      "user_id": userId,
    };

    try {
      final Response response = await ApiClient.postTypeWithTokenApi(
        api: api,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        callback.onSuccess(response.body, api);
      } else if (response.statusCode == 409) {
        callback.onSuccess(
            response.body, api); // Handling 409 as success (conflict)
      } else {
        callback.onFailure("Something went wrong");
      }
    } catch (e) {
      print("Exception is: $e");
      callback.onFailure("An error occurred: $e");
    }
  }

  static Future<void> getComments(
      {required String api, required ApiCallback callack}) async {
    try {
      final Response response = await ApiClient.getTypeWithTokenApi(
        api: api,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('this invokesss');
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

  static Future<void> addComment(
      {required String api,
      required String memoryID,
      required String imageId,
      required String comment,
      required ApiCallback callack}) async {
    final body = {
      "memory_id": memoryID,
      "image_id": imageId,
      "comment": comment
    };
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

static Future<void> deleteUserAccount(
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
  
}
