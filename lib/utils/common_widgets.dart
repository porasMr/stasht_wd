import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/onboarding/onboarding_screen.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:permission_handler/permission_handler.dart' as permission;


class CommonWidgets {
  static Future<dynamic> googleSignup(ApiCallback callBack) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print(googleUser!.displayName!);
            print(googleAuth!.accessToken);

      print(googleUser.email);
            print(googleUser.id);

      CommonWidgets.progressDialog();
      ApiCall.scocialLogin(
          api: ApiUrl.socialLogin,
          email: googleUser.email,
          type: 'google',
          name:googleUser.displayName!,
          id:googleUser.id,
          callack: callBack);
    } catch (e) {
      print(e);
    }
  }

  static initiateAppleSignUp(ApiCallback callBack) async {
    try {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          try {
            print("successfull sign in");
            final AppleIdCredential? appleIdCredential = result.credential;

            String s = String.fromCharCodes(result.credential!.identityToken!);
            var outputAsUint8List = Uint8List.fromList(s.codeUnits);
            var convertedIdentityToken =
                Utf8Decoder().convert(outputAsUint8List);
            print("Identity token: ${convertedIdentityToken}");

            if (appleIdCredential!.email != null) {
              print(
                  "Apple Login Credentials...  ${appleIdCredential.email} \n  ${appleIdCredential.fullName!.givenName} \n ${appleIdCredential.fullName!.familyName}");
                  CommonWidgets.progressDialog();

              ApiCall.scocialLogin(
                  api: ApiUrl.socialLogin,
                  email: appleIdCredential.email!,
                  type: 'apple',
                  name: appleIdCredential.fullName!.givenName??'',
                  id: convertedIdentityToken,
                  callack: callBack);
            }
          } catch (e) {
            print("error");
          }
          break;
        case AuthorizationStatus.error:
          print("Apple AuthorizationStatus.error");
          break;

        case AuthorizationStatus.cancelled:
          print("Apple AuthorizationStatus.cancelled");
          break;
      }
    } catch (error) {
      print("error with apple sign in");
    }
  }

  static Future<AccessToken?>? loginWithFacebook() async {
    final LoginResult result = Platform.isAndroid
        ? await FacebookAuth.instance
            .login(permissions: ['email', 'user_photos'])
        : await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {

      // print('Access Token: ${accessToken.tokenString}');
    return result.accessToken!;

    } else {
      print('Login failed: ${result.message}');
    }
    return null;
  }

  ///Get link from the google photos from drive
  static Future<GoogleSignIn?> getFileFromGoogleDrive(
      BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      googleSignIn = GoogleSignIn(
        scopes: <String>[
          DriveApi.driveScope,
          DriveApi.driveFileScope,
          DriveApi.driveMetadataScope,
          DriveApi.drivePhotosReadonlyScope,
        ],
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      // Get authentication details, including access token

      if (account != null) {
        return googleSignIn;
      } else {}
    } catch (e) {

    }
    return null;
  }

  static Future<AccessToken?> loginWithInstagram() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {

      // print('Access Token: ${accessToken.tokenString}');
      return result.accessToken!;
      // controller.fetchFacebookPhotos(accessToken);
    } else {
      print('Login failed: ${result.message}');
    }
    return null;
  }

  static Future<String>? openInstagramPage() {
    Get.to(() => InstagramLoginPage())?.then((value) async{
      print("code====>$value");
      if (value != null) {
        return value;
        //await controller.instaRequestForAccessToken(value);
      }
    });
    return null;
  }

  static Widget buttonView({String? imagePath, String? title}) {
    return Column(
      children: [
        SvgPicture.asset(
          imagePath ?? "",
          height: 42,
        ),
        Text(title ?? "",
            style: appTextStyle(
              fz: 11,
              color: Colors.black,
              fm: interMedium,
              height: 30 / 11,
            ))
      ],
    );
  }

  static progressDialog(){
  double _progress = 0.0;
  Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
    _progress += 0.03;

    EasyLoading.showProgress(
      _progress,
       // Show percentage
    );

    if (_progress >= 0.9) {
      timer.cancel(); // Stop the timer
      EasyLoading.dismiss(); // Dismiss the dialog
    }
  });
  

  }
   static fbView(BuildContext context,{VoidCallback ? calback}) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .7,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(fbSmall, height: 76, width: 76),
            Text(
              AppStrings.fbPhotos,
              style: appTextStyle(
                  height: 15 / 17,
                  fz: 17,
                  fm: robotoBold,
                  color: Color(0XFF585858)),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "To access all your Facebook photos you need to \nauthorize Stasht to access them on this device",
              style: appTextStyle(
                  height: 19 / 13,
                  fz: 13,
                  fm: robotoRegular,
                  color: Color(0XFF585858)),
            ),
            const SizedBox(
              height: 20,
            ),
        GestureDetector(
                onTap: () {
                  if(calback!=null){
                    calback();
                  }

                },
                child: button(
                    color: const Color(0XFF1877F2),
                    title: "Connect to Facebook",
                    context)),
          ],
        ),
      ),
    );
  }

  static instaView(BuildContext context,{VoidCallback ? callback}) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .7,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(instaSmall, height: 66, width: 66),
            const SizedBox(
              height: 15,
            ),
            Text(
              AppStrings.instaPhotos,
              style: appTextStyle(
                  height: 15 / 17,
                  fz: 17,
                  fm: robotoBold,
                  color: Color(0XFF585858)),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "To access all your Instagram photos you need to \nauthorize Stasht to access them on this device",
              style: appTextStyle(
                  height: 19 / 13,
                  fz: 13,
                  fm: robotoRegular,
                  color: Color(0XFF585858)),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                if(callback!=null){
                  callback();
                }
               /* uploadCount=0;
                progressbarValue.value = 0.0;
                update();
                ///InstaLogin Function
                Get.to(() => InstagramLoginPage())?.then((value) {
                  print("code====>$value");
                  if (value != null) {
                    instaRequestForAccessToken(value);
                    // controller.instaRequestForAccessToken(value);
                  }
                });*/
              },
              child: button(
                color: Color(0XFF3CD3F87),
                title: "Connect to Instagram",
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
static button(BuildContext context, {Color? color, String? title}) {
    return Container(
      height: 35,
      width: MediaQuery.of(context).size.width * .6,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: color ?? AppColors.primaryColor),
      alignment: Alignment.center,
      child: Text(title ?? "",
          style: appTextStyle(
              height: 19 / 13, fz: 13, fm: robotoBold, color: Colors.white)),
    );
  }

  static driveView(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .7,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(driveSmall, height: 76, width: 76, fit: BoxFit.cover),
            Text(
              AppStrings.googleDrive,
              style: appTextStyle(
                  height: 15 / 17,
                  fz: 17,
                  fm: robotoBold,
                  color: Color(0XFF585858)),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "To access all your Google drive photos you need to \nauthorize Stasht to access them on this device",
              style: appTextStyle(
                  height: 19 / 13,
                  fz: 13,
                  fm: robotoRegular,
                  color: Color(0XFF585858)),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                // progressbarValue.value = 0.0;
                // update();
                // getFileFromGoogleDrive();
              },
              child: button(
                  color: Color(0XFF34A853),
                  title: "Connect to Google Drive",
                  context),
            ),
          ],
        ),
      ),
    );
  }
  static Future<List<AssetEntity>> getLocalImages() async {
      List<AssetEntity> assets = [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(

        type: Platform.isAndroid? RequestType.image:RequestType.all,
        filterOption: FilterOptionGroup(
            orders: [
              const OrderOption(type: OrderOptionType.createDate,asc: false)
            ]
        )
    );
    AssetPathEntity? cameraRoll;
    for(var path in paths){

      if(Platform.isAndroid){
        if(path.name.toLowerCase()=="camera" || path.name.toLowerCase()=="dcim"){
          cameraRoll=path;
          break;
        }
      }
      else{
        cameraRoll = path;
        break;

      }
    }
    
    List<AssetEntity> allAssets = [];

    int page = 0;

    int size = 100; // Number of assets per page
 
    while (true) {
      assets = await cameraRoll!.getAssetListPaged(page: page, size: size);

      if (assets.isEmpty) {
        break;
      }

      allAssets.addAll(assets);

      page++;
    }
   
return allAssets;
  
    
  }
  static Future<void> requestStoragePermission(Function(List<AssetEntity> allAssets)? onPressed) async {

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 33) {
        // Request READ_EXTERNAL_STORAGE for older versions
        final status = await permission.Permission.storage.request();
        if (status.isGranted) {
          final PermissionState ps =
              await PhotoManager.requestPermissionExtend();
          if (ps.isAuth) {
            await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
          } else if (ps.hasAccess) {
          await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
          } else {
            PhotoManager.openSetting();
          }
        } else if (status.isDenied) {
          final status = await permission.Permission.storage.request();
          if (status.isGranted) {
            final PermissionState ps =
                await PhotoManager.requestPermissionExtend();
            if (ps.isAuth) {
             await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
            } else if (ps.hasAccess) {
              await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
            } else {
              PhotoManager.openSetting();
            }
          } else {
            permission.openAppSettings();
          }
        }
      } else {
        final status = await permission.Permission.photos.request();
        if (status.isGranted) {
          await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
          
        } else if (status.isDenied) {
          final status = await permission.Permission.photos.request();
          if (status.isGranted) {
           await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
            
          } else {
            permission.openAppSettings();
          }
        }
      }
    } else {
      
      final PermissionState ps = await PhotoManager
          .requestPermissionExtend(); // the method can use optional param `permission`.
      if (ps.isAuth) {
       await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });
      } else if (ps.hasAccess) {
await getLocalImages(
                ).then((value) {
                  onPressed!(value);
                });      } else {
        PhotoManager.openSetting();
      }

    }
  }

  static googleButton(ApiCallback callback) {
    return GestureDetector(
      onTap: () {
        CommonWidgets.googleSignup(callback);
      },
      child: CommonWidgets.buttonView(
        imagePath: googleImage,
        title: AppStrings.google,
      ),
    );
  }

 static appleButton(ApiCallback callback) {
    return GestureDetector(
        onTap: () {
          CommonWidgets.initiateAppleSignUp(callback);
        },
        child: CommonWidgets.buttonView(imagePath: appleImage, title: AppStrings.apple));
  }

}
