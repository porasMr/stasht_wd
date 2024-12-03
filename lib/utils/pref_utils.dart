import 'dart:convert';

import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/utils/shared_pref.dart';
import 'package:stasht/utils/shared_pref_keys.dart';

class PrefUtils {
  PrefUtils._();
  static PrefUtils? _instance;
  static PrefUtils get instance => _instance ??= PrefUtils._();

  SharedPrefProvider prefsProvider = SharedPrefProvider();

  Future<void> init() => prefsProvider.init();

  bool get isFirstSession =>
      !prefsProvider.prefs.containsKey(SPKeys.firstSessionComplete);

  Future<void> firstSessionComplete() =>
      prefsProvider.prefs.setBool(SPKeys.firstSessionComplete, true);

  Future<void> authToken(String token) =>
      prefsProvider.prefs.setString(SPKeys.token, token);
  Future<void> clearPreferance() => prefsProvider.prefs.clear();
  // Retrieve token in a single line
  String? getToken() { 

  return   prefsProvider.prefs.getString(SPKeys.token);
    }

  Future<void> saveUserToPrefs(UserModel user) async {

    String userJson = jsonEncode(user.toJson()); // Convert model to JSON string
    await prefsProvider.prefs.setString(
        SPKeys.userData, userJson); // Save JSON string to SharedPreferences
  }

  Future<UserModel?> getUserFromPrefs() async {
    String? userJson = prefsProvider.prefs.getString(SPKeys.userData);

    if (userJson == null) {
      return null;
    } // Return null if no data is found

    Map<String, dynamic> userMap = jsonDecode(userJson); // Decode JSON string
    return UserModel.fromJson(userMap);
  }

   Future<void> saveDrivePhotoLinks(List<PhotoDetailModel> photoLinks) async {
  
  // Convert each PhotoLink to JSON and then to a list of JSON strings
  String jsonList = jsonEncode(photoLinks.map((link) => link.toJson()).toList());

   await prefsProvider.prefs.setString(
        SPKeys.driveData, jsonList) ;
}

 Future<List<PhotoDetailModel>> getDrivePrefs() async {
    String? jsonList = prefsProvider.prefs.getString(SPKeys.driveData);

  

  if (jsonList != null) {
    List<dynamic> decodedList = jsonDecode(jsonList);

    // Map each item to a PhotoLink object
    return decodedList.map((item) => PhotoDetailModel.fromJson(item)).toList();
  }

  return []; // Return an empty list if not found
  }

 Future<void> saveFacebookPhotoLinks(List<PhotoDetailModel> photoLinks) async {
  
  // Convert each PhotoLink to JSON and then to a list of JSON strings
  String jsonList = jsonEncode(photoLinks.map((link) => link.toJson()).toList());

   await prefsProvider.prefs.setString(
        SPKeys.fbData, jsonList) ;
}

 Future<List<PhotoDetailModel>> getFacebookPrefs() async {
    String? jsonList = prefsProvider.prefs.getString(SPKeys.fbData);

  

  if (jsonList != null) {
    List<dynamic> decodedList = jsonDecode(jsonList);

    // Map each item to a PhotoLink object
    return decodedList.map((item) => PhotoDetailModel.fromJson(item)).toList();
  }

  return []; // Return an empty list if not found
  }

Future<void> saveInstaPhotoLinks(List<PhotoDetailModel> photoLinks) async {
  
  // Convert each PhotoLink to JSON and then to a list of JSON strings
  String jsonList = jsonEncode(photoLinks.map((link) => link.toJson()).toList());

   await prefsProvider.prefs.setString(
        SPKeys.instaData, jsonList) ;
}

 Future<List<PhotoDetailModel>> getInstaPrefs() async {
    String? jsonList = prefsProvider.prefs.getString(SPKeys.instaData);

  

  if (jsonList != null) {
    List<dynamic> decodedList = jsonDecode(jsonList);

    // Map each item to a PhotoLink object
    return decodedList.map((item) => PhotoDetailModel.fromJson(item)).toList();
  }

  return []; // Return an empty list if not found
  }

}