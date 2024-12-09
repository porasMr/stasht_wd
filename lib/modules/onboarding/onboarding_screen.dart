import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/media_screen.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:stasht/utils/progress_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;



class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> implements ApiCallback {

  DriveApi? driveApi;
var fbValue = false;
  var instaValue = false;
  var isLoading = false;
  var driveValue = false;
  List<PhotoDetailModel> assetsItems = [];

  List<PhotoDetailModel> photoLinks = [];
  int uploadCount = 0;
  var progressbarValue = 0.0;
  var groupedAssets = {};
List<PhotoModel> photosList = [];
 SharedPreferences? pref;
   List<Future<Uint8List?>> future = [];

UserModel model=UserModel();
@override
  void initState() {
PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });
     SharedPreferences.getInstance().then((value) => pref=value);
    pref?.setBool("isFirstOnBoard", true);
     CommonWidgets.requestStoragePermission(((allAssets) {
      for (int i = 0; i < allAssets.length; i++) {
        photosList
            .add(PhotoModel(assetEntity: allAssets[i], selectedValue: false,isEditmemory: false));
            if(allAssets.length-1==i){
            getImageFutureData();

            }
           // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
      }
     
    })); 
       super.initState();
  }
  getImageFutureData(){
      for (int i = 0; i < photosList.length; i++) {
      future.add(photosList[i].assetEntity
          .thumbnailDataWithSize(ThumbnailSize(300, 300)));
      // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
    }
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      body: _onboardView(context),
    );
  }

  _onboardView(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        _backgroudImage(context),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      GestureDetector(
                        onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PhotosView(photosList:photosList,isSkip: true,)));

                        },
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: isLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                      AppStrings.skip,
                                      style: appTextStyle(
                                          color: AppColors.primaryColor,
                                          fm: robotoRegular,
                                          fz: 22),
                                    ),
                            ),
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                      Center(
                        child: SvgPicture.asset(stashtLogo),
                      ),
                      const SizedBox(height: 55),
                      Center(
                        child: Text(
                          AppStrings.chooseMoreApps,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: robotoMedium,
                              height: 26.2 / 20),
                        ),
                      ),
                      Center(
                        child: Container(
                            width: MediaQuery.of(context).size.width < 400
                                ? MediaQuery.of(context).size.width * .7
                                : MediaQuery.of(context).size.width * .6,
                            margin: const EdgeInsets.only(top: 50),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: _fbLogo(),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    _switchIcon(type: "fb", context: context),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width <
                                              400
                                          ? MediaQuery.of(context).size.width *
                                              .45
                                          : MediaQuery.of(context).size.width *
                                              .4,
                                      child: _instaLogo(),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    _switchIcon(
                                        type: "insta", context: context),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: _driveLogo(),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    _switchIcon(
                                        type: "drive", context: context),
                                  ],
                                )
                              ],
                            )),
                      )
                    ]),
              )),
        ),
      ],
    );
  }

  _backgroudImage(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .61,
      child: Image.asset(
        backgroundGradient,
        width: MediaQuery.of(context).size.width * .6,
        fit: BoxFit.cover,
      ),
    );
  }

  _fbLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(
          fbLogo,
          height: 32.65,
        ),
      ],
    );
  }

  _instaLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(instaLogo, height: 68),
      ],
    );
  }

  _driveLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(driveLogo, height: 56),
      ],
    );
  }

  _switchIcon({String? type, required BuildContext context}) {
    return  Switch(
          value: type == "fb"
              ? fbValue
              : type == "insta"
                  ? instaValue
                  : driveValue,
          onChanged: (value) async {
            changeSwitchValue(value, type);
            if (type == "insta" && instaValue) {
              CommonWidgets.openInstagramPage(context)!.then((value) {
                instaRequestForAccessToken(value);
              });
            } else if (type == "drive" && driveValue) {
              CommonWidgets.getFileFromGoogleDrive(context).then((value) {
                fetchPhotosFromDrive(value!, context);
              });
            } else if (type == "fb" && fbValue) {
              CommonWidgets.loginWithFacebook()!.then((value) {
                fetchFacebookPhotos(value!);
              });
            }
            setState(() {
              
            });
          },
          activeColor: Colors.white,
          trackColor: MaterialStateProperty.all(
              const Color(0XFFD9DAFF).withOpacity(.75)),
        );
  }
  
  void changeSwitchValue(bool value, String? type) {
  /* if(type == "drive") {
      driveValue.value = value;
      instaValue.value = true;
      fbValue.value = true;
    }*/
     if (type == "fb") {
         fbValue = value;
      instaValue = false;
      driveValue = false;
    }
    else if (type == "insta") {
           instaValue = value;
      fbValue = false;
      driveValue = false;
    }
    else {
      driveValue = value;
      instaValue = false;
      fbValue = false;
    }
    setState(() {
      
    });
  }

  fetchPhotosFromDrive(GoogleSignIn googleSignIn, BuildContext context,
     ) async {
    try {
      photoLinks.clear();
      List<File> allFiles = [];
      FileList fileList;
      String? nextPageToken;
      var httpClient = await googleSignIn.authenticatedClient();
      if (httpClient == null) {
        print('Failed to get authenticated client');
        return null;
      }
      var driveApi = DriveApi(httpClient);
      print(httpClient.credentials.accessToken.data);
      showProgressDialog(context);

      // do {
      do {
        fileList = await driveApi.files.list(
          // q: "mimeType contains 'image/'",
          q: "mimeType='image/png' or mimeType='image/jpeg' or mimeType='image/jpg' and visibility='anyoneWithLink'",
          pageToken: nextPageToken,
          $fields:
          "nextPageToken, files(id, name, webViewLink,thumbnailLink,createdTime, modifiedTime,properties,webContentLink)",
        );
        if (fileList.files != null) {

          if (fileList.files!.length > 50) {
            allFiles.addAll(fileList.files!.take(50));
          }
          {
            allFiles.addAll(fileList.files!);
          }
        }
        nextPageToken = fileList.nextPageToken;
      } while (nextPageToken != null);
      if (allFiles.isNotEmpty) {
        if (allFiles.length > 50) {
            for (int i = 0; i < allFiles.take(50).length; i++) {
              if (allFiles[i].webViewLink != null) {
                photoLinks.add(PhotoDetailModel(
                    id: allFiles[i].id,
                    createdTime: allFiles[i].createdTime,
                    modifiedTime: allFiles[i].modifiedTime,
                    isSelected: false,
                    isEdit: false,
                    type: "drive",
                    webLink: allFiles[i].thumbnailLink,
                    thumbnailPath: convertToDirectLink(allFiles[i].webViewLink!,allFiles[i].id!,httpClient.credentials.accessToken.data,driveApi)));
                uploadCount += 1;
                progressbarValue = uploadCount / allFiles.take(50).length;
                      progressNotifier.value=progressbarValue;

                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  
                });
              }
            }
              clossProgressDialog('google_drive_synced');

        }
        else {
          for (int i = 0; i < allFiles.length; i++) {
            if (allFiles[i].webViewLink != null) {
              photoLinks.add(PhotoDetailModel(
                  id: allFiles[i].id,
                  createdTime: allFiles[i].createdTime,
                  modifiedTime: allFiles[i].modifiedTime,
                  isSelected: false,
                  isEdit: false,
                  type: "drive",
                  webLink: allFiles[i].thumbnailLink,
                  thumbnailPath: convertToDirectLink(allFiles[i].webViewLink!,allFiles[i].id!,httpClient.credentials.accessToken.data,driveApi)));
              uploadCount += 1;
              progressbarValue = uploadCount / allFiles.length;
                    progressNotifier.value=progressbarValue;

              await Future.delayed(const Duration(seconds: 1));
              setState(() {
                
              });
              clossProgressDialog('google_drive_synced');
            }
          }
        }
       
        await Future.delayed(const Duration(seconds: 1), () {
          
        });
      } else {
        CommonWidgets.errorDialog(context, 'No image available in drive');

        await Future.delayed(const Duration(seconds: 2), () {
          // Get.offNamed(AppRoutes.photosViewScreen, arguments: {
          //   "photoList": photoLinks,
          //   "context": context,
          //   "groupAssets": groupedAssets,
          //   "assetsList": assetsItems,
          //   "assets": assets,
          //   "fromMedia": true
          // });
        });
        // goToMemories(false);
      }
    } catch (e) {
      print('Error fetching files: $e');
      return null;
    }
  }

clossProgressDialog(String type){
  if((progressbarValue * 100).toStringAsFixed(0)=='100'){
        Navigator.pop(context);
        progressbarValue=0.0;
        if(type=="google_drive_synced"){
        PrefUtils.instance.saveDrivePhotoLinks(photoLinks);

        }else if(type=='facebook_synced'){
                  PrefUtils.instance.saveFacebookPhotoLinks(photoLinks);

        }else{
                  PrefUtils.instance.saveInstaPhotoLinks(photoLinks);

        }
        ApiCall.syncAccount(api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
       }
}

  updateProgressValue({var galleryLength, var driveLength}) async {
    if (galleryLength.isNotEmpty && driveLength.isNotEmpty) {
      uploadCount += 1;
      progressbarValue =
          uploadCount / galleryLength.length + driveLength.length;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String convertToDirectLink(String shareableLink,String fileId,String accessToken,var driveApi) {
    print("Before ====>$shareableLink");
    final parts = shareableLink.split('/');
    final fileId = parts[5]; // The file ID is at index 5
    final directLink = 'https://drive.google.com/uc?export=view&id=$fileId';
    print("After ========>$directLink");

    changeFilePermission(fileId,accessToken,driveApi);

    return directLink;
  }


  Future<void> changeFilePermission(String fileId, String? accessToken,var driveApi) async {
    if (accessToken == null) {
      throw Exception('Access token is null');
    }




    // Create a Google Drive API client
   // final driveApi = drive.DriveApi(httpClient);

    // Create a permission object to set to "Anyone with the link" (public)
    final newPermission = drive.Permission(
      type: 'anyone', // Permission type: "anyone"
      role: 'reader', // Role: "reader" (view only)
    );

    try {
      // Apply the new permission to the file
      await driveApi.permissions.create(
        newPermission,
        fileId, // The Google Drive file ID
      );

      print('File permissions updated: Now anyone with the link can access the file.');
    } catch (e) {
      photoLinks.forEach((element){
        if(element.id ==fileId){
          photoLinks.remove(element);
        }
        setState(() {
          
        });
      });
      print('Failed to change permission: $e');
    } finally {

    }
  }


 
   Future<void> groupAssetsByMonth(List<PhotoDetailModel> assets,
      {bool signUpScreen = false}) async {
    final grouped = <DateTime, List<PhotoDetailModel>>{};

    for (var asset in assets) {
      final date = asset.createdTime;

      if (date != null) {
        final monthKey = DateTime(date.year, date.month);

        if (!grouped.containsKey(monthKey)) {
          grouped[monthKey] = [];
        }

        grouped[monthKey]!.add(asset);
      }
    }
    

setState(() {
  
});  }

  void instaRequestForAccessToken(value) async {
    pref = await SharedPreferences.getInstance();
    pref!.setString("selectedTab", jsonEncode({"type": "insta"}));
    String clientId = '1261297914899174';
    // String clientId = '820343826870430';
    String clientSecret = 'ad28543d801e5a81087105fdcd9adf46';
    // String clientSecret = '1805f78dbdb29d02d1c7790806e119ec';
    String redirectUri = 'https://stashtdev.page.link/';
    String authorizationCode = value;
    try {
      final response = await http.post(
        Uri.parse('https://api.instagram.com/oauth/access_token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
          'code': authorizationCode,
        },
      );

      if (response.statusCode == 200) {
        // Handle the response here
        final data = jsonDecode(response.body);
        print('Access Token: ${data['access_token']}');
        if (data != null) {
          /* await FirebaseFirestore.instance
              .collection(userCollection).doc(userId).update({"instaToken":data['access_token'],
          "syncAccount":"insta"});*/
          await fetchMedia(data['access_token']);
        }
      } else {
        // Print out error details
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        //fetchMedia(accessToke);
      }
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }

  Future<void> fetchMedia(String accessToken, {bool fromSplash = false}) async {
    final response = await http.get(
      Uri.parse(
          'https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,thumbnail_url,permalink,timestamp&access_token=$accessToken'),
    );

    // Extract rate limit headers
    var rateLimit = response.headers['x-ratelimit-limit'];
    var rateLimitRemaining = response.headers['x-ratelimit-remaining'];
    var rateLimitReset = response.headers['x-ratelimit-reset'];

    // Log or handle rate limit information
    print('Rate Limit: $rateLimit');
    print('Rate Limit Remaining: $rateLimitRemaining');
    print('Rate Limit Reset: $rateLimitReset');

    if (response.statusCode == 200) {
      // Successfully received the media
      var data = jsonDecode(response.body);
      if (data["data"] != null) {
              showProgressDialog(context);

        // requestStoragePermission();
        await Future.forEach(data["data"], (dynamic element) async {
          if (element["media_type"] == "IMAGE") {
            photoLinks.add(PhotoDetailModel(
              createdTime: convertTimeStampIntoDateTime(element["timestamp"]),
              isSelected: false,
              isEdit: false,
              type: "insta",
              id: element["id"],
              webLink: element["media_url"],
            ));
          }
          uploadCount += 1;
          progressbarValue = uploadCount / data["data"].length;
                progressNotifier.value=progressbarValue;

          await Future.delayed(const Duration(seconds: 1));
setState(() {
  
});          clossProgressDialog('instagram_synced');
        });

        await Future.delayed(const Duration(seconds: 2), () {
         
        });
      } else {
        CommonWidgets.errorDialog(context, "No image available in Insta");

        await Future.delayed(const Duration(seconds: 2), () {
        
        });
      }
    } else {
      // Handle errors, including potential rate limiting
      if (response.statusCode == 429) {
        // HTTP 429 Too Many Requests
        print('Rate limit exceeded, retrying after reset time...');
        final resetTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(rateLimitReset ?? "") * 1000);
        final waitDuration = resetTime.difference(DateTime.now()).inSeconds;

        // Wait until the reset time before retrying
        await Future.delayed(Duration(seconds: waitDuration));
        await fetchMedia(accessToken,
            fromSplash: fromSplash); // Retry the request
      } else {
        _refreshInstaAccessToken(accessToken);
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  Future<String?> _refreshInstaAccessToken(String shortLivedToken) async {
    final response = await http.get(
      Uri.parse(
          "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=$shortLivedToken"),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data != null) {
       
        await fetchMedia(data['access_token']);
      }
      return data['access_token'];
    } else {
      print('Error exchanging token: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  convertTimeStampIntoDateTime(dateString) {
    String formattedDateString = dateString.replaceAll('+0000', 'Z');
    DateTime dateTime = DateTime.parse(formattedDateString);

    return dateTime;
  }

 


 
  


  fetchFacebookPhotos(AccessToken accessToken) async {
    // EasyLoading.show(status: 'Processing');

    final response = await http.get(
      Uri.parse(
        'https://graph.facebook.com/me/photos?type=uploaded&access_token=${accessToken.tokenString}',
      ),
    );

    if (response.statusCode == 200) {
      List<FaceBookPhoto> faceBook = [];
      final data = json.decode(response.body);
      var photos = data['data'] as List;
      photos.forEach((element) {
        faceBook.add(FaceBookPhoto(
            id: element["id"], createdTime: element["created_time"]));
      });
      if (faceBook.isNotEmpty) {
              showProgressDialog(context);

        await Future.forEach(faceBook, (dynamic element) async {
          await fetchFacebookPhotosById(
                  accessToken.tokenString, element, faceBook)
              .then((value) {});
        });
      }
      if (photoLinks.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 2), () {
          // Get.offNamed(AppRoutes.photosViewScreen, arguments: {
          //   "photoList": photoLinks,
          //   "context": Get.context,
          //   "groupAssets": groupedAssets,
          //   "assetsList": assetsItems,
          //   "assets": assets,
          //   "fromMedia": true,
          //   "type": "fb"
          // });
        });
        // groupFbByMonth(photoList);
      }

      // Extract the URL of the first image from each photo
    } else {
      throw Exception('Failed to load photos');
    }
  }

  ///Fetch facebook url by photo id
  Future fetchFacebookPhotosById(
    String accessToken,
    FaceBookPhoto element,
    List<FaceBookPhoto> faceBook,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://graph.facebook.com/${element.id}?fields=images&access_token=$accessToken',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      photoLinks.add(PhotoDetailModel(
          type: "fb",
          createdTime: DateTime.tryParse(element.createdTime??""),
          webLink: data['images'][0]["source"],
          id: element.id));
      print(photoLinks);
      uploadCount += 1;
      progressbarValue = uploadCount / faceBook.length;
      progressNotifier.value=progressbarValue;
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        
      });
                    clossProgressDialog('facebook_synced');

    } else {
      throw Exception('Failed to load photos');
    }
  }

final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal
      builder: (context) => ProgressDialog(progressNotifier),
    );
  }
  @override
  void onFailure(String message) {
    
            CommonWidgets.errorDialog(context, message);


  }

  @override
  void onSuccess(String data, String apiType) {
    if(apiType==ApiUrl.syncAccount){
      if(model.user!.facebookSynced!=0||model.user!.googleDriveSynced!=0||model.user!.instagramSynced!=0){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PhotosView(photosList:photosList,isSkip: false,)));

      }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MediaScreen(photosList:photosList,future: future,isFromSignUp: true,)));

      }


 
   }
  }

  @override
  void tokenExpired(String message) {
  }



}

class InstagramLoginPage extends StatefulWidget {
  @override
  _InstagramLoginPageState createState() => _InstagramLoginPageState();
}

class _InstagramLoginPageState extends State<InstagramLoginPage> {
  // final String clientId = '820343826870430';
  // final String redirectUri = 'https://stashtdev.page.link/';

  // String clientId = '820343826870430';
  // String clientSecret = '1805f78dbdb29d02d1c7790806e119ec';
  /*String clientId = '484474764495171';*/
  String clientId = '1261297914899174';
  // String clientId = '820343826870430';
/*  String clientSecret = 'ebdd100d779883a59465ca1908703e73';*/
  String clientSecret = 'ad28543d801e5a81087105fdcd9adf46';
  // String clientSecret = '1805f78dbdb29d02d1c7790806e119ec';
  String redirectUri = 'https://stashtdev.page.link/';

  final String scope = 'user_profile,user_media';
  final String responseType = 'code';
  var controller = WebViewController();
  var cookieController = WebViewCookieManager();

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar, if needed
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
            if (url == "https://www.instagram.com/?hl=en&deoia=1") {
              controller.loadRequest(
                  Uri.parse('https://api.instagram.com/oauth/authorize'
                      '?client_id=$clientId'
                      '&redirect_uri=$redirectUri'
                      '&scope=$scope'
                      '&response_type=$responseType'
                      '&auth_type=reauthenticate'));
            }
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onHttpError: (HttpResponseError error) {
            print('HTTP error: $error');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: $error');
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            if (request.url == "https://www.instagram.com/?deoia=1" ||
                request.url ==
                    "https://www.instagram.com/accounts/onetap/?next=%2F&hl=en") {
              controller.loadRequest(
                  Uri.parse('https://api.instagram.com/oauth/authorize'
                      '?client_id=$clientId'
                      '&redirect_uri=$redirectUri'
                      '&scope=$scope'
                      '&response_type=$responseType'
                      '&auth_type=reauthenticate'));
              return NavigationDecision.prevent;
            }
            // Check if the URL contains the authorization code
            if (uri.queryParameters.containsKey('code')) {
              final code = uri.queryParameters['code'];
              if (code != null) {
                print('Authorization code: $code');
                clearWebViewCache();
                Get.back(result: code);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            "https://www.instagram.com/accounts/login/?hl=en&force=browser" /*'https://api.instagram.com/oauth/authorize'
            '?client_id=$clientId'
            '&redirect_uri=$redirectUri'
            '&scope=$scope'
            '&response_type=$responseType'
            '&auth_type=reauthenticate'*/
            ),
      );
  }

  void clearWebViewCache() async {
    controller.clearCache();
    cookieController.clearCookies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
