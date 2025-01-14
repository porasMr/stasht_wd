import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:stasht/modules/create_memory/model/group_modle.dart';
import 'package:stasht/modules/media/image_grid.dart';
import 'package:stasht/modules/media/model/CombinedPhotoModel.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/onboarding/domain/model/all_photo_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_group_model.dart';
import 'package:stasht/modules/onboarding/onboarding_screen.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:stasht/utils/web_image_preview.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../image_preview_widget.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:timeago/timeago.dart' as timeago;

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
          name: googleUser.displayName!,
          id: googleUser.id,
          deviceToken: PrefUtils.instance.getOneSingalToken() ?? '',
          deviceType: Platform.isAndroid ? "android" : "ios",
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
                  name: appleIdCredential.fullName!.givenName ?? '',
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
    } catch (e) {}
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

  static Future<String>? openInstagramPage(BuildContext context) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => InstagramLoginPage()))
        .then((value) async {
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

  static progressDialog() {
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

  static fbView(BuildContext context, Function(AccessToken token) callBack) {
    return Column(
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
              loginWithFacebook()!.then((value) {
                callBack(value!);
              });
            },
            child: button(
                color: const Color(0XFF1877F2),
                title: "Connect to Facebook",
                context)),
      ],
    );
  }

  static photoView(BuildContext context, Function(String token) callBack) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(googlePhotsSmall, height: 66, width: 66),
        const SizedBox(
          height: 15,
        ),
        Text(
          AppStrings.googlePhotos,
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
          "To access all your Google photos you need to \nauthorize Stasht to access them on this device",
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
            // debugPrint("Instagram is opened this");
            // openInstagramPage(context)!.then((value) {
            //   callBack(value);
            // });
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
            color: AppColors.googlePhotoColors,
            title: "Connect to Google Photos",
            context,
          ),
        ),
      ],
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

  static driveView(BuildContext context,
      Function(GoogleSignIn v, String pageToken) callBack) {
    return Column(
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
            getFileFromGoogleDrive(context).then((value) {
              callBack(value!, PrefUtils.instance.getDriveToken()!);
            });
          },
          child: button(
              color: Color(0XFF34A853),
              title: "Connect to Google Drive",
              context),
        ),
      ],
    );
  }

  static Future<List<AssetEntity>> getLocalImages() async {
    List<AssetEntity> assets = [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: Platform.isAndroid ? RequestType.image : RequestType.image,
        filterOption: FilterOptionGroup(orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false)
        ]));
    AssetPathEntity? cameraRoll;
    for (var path in paths) {
      if (Platform.isAndroid) {
        if (path.name.toLowerCase() == "camera" ||
            path.name.toLowerCase() == "dcim") {
          cameraRoll = path;
          break;
        }
      } else {
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

  static Future<void> requestStoragePermission(
      Function(List<AssetEntity> allAssets)? onPressed) async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 33) {
        // Request READ_EXTERNAL_STORAGE for older versions
        final status = await permission.Permission.storage.request();
        if (status.isGranted) {
          final PermissionState ps =
              await PhotoManager.requestPermissionExtend();
          if (ps.isAuth) {
            await getLocalImages().then((value) {
              onPressed!(value);
            });
          } else if (ps.hasAccess) {
            await getLocalImages().then((value) {
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
              await getLocalImages().then((value) {
                onPressed!(value);
              });
            } else if (ps.hasAccess) {
              await getLocalImages().then((value) {
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
          await getLocalImages().then((value) {
            onPressed!(value);
          });
        } else if (status.isDenied) {
          final status = await permission.Permission.photos.request();
          if (status.isGranted) {
            await getLocalImages().then((value) {
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
        await getLocalImages().then((value) {
          onPressed!(value);
        });
      } else if (ps.hasAccess) {
        await getLocalImages().then((value) {
          onPressed!(value);
        });
      } else {
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
        child: CommonWidgets.buttonView(
            imagePath: appleImage, title: AppStrings.apple));
  }

  static errorDialog(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorColors,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the snackbar after a delay
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static successDialog(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successColors,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the snackbar after a delay
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static String dateRetrun(String value) {
    return DateFormat("MMM d").format(DateTime.parse(value));
  }

  static String daysWithYearRetrun(String value) {
    return DateFormat("MMM yyyy").format(DateTime.parse(value));
  }

  static String maxDateRetrun(String value) {
    return DateFormat("MMM d/yy").format(DateTime.parse(value));
  }

  static String dateFormatRetrun(String value) {
    return DateFormat("MMM d, yyyy").format(DateTime.parse(value));
  }

  static drivePhtotView(
    List<GroupedPhotoModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
    ScrollController? controller,
  }) {
    return ListView.builder(
      controller: controller,
      itemCount: photosList.length,
      itemBuilder: (context, index) {
        return Wrap(
          children: [
            Padding(
              padding: index == 0
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: 16.0),
              child: Text(
                photosList[index].date,
                style: const TextStyle(
                  color: AppColors.monthColor,
                  fontFamily: robotoRegular,
                  fontSize: 22,
                  height: 28 / 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey(
                    'photosGrid'), // Key for persistent scroll state

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 2, // Aspect ratio of each grid item
                ),
                itemCount: photosList[index].photos.length,
                addAutomaticKeepAlives: false,
                itemBuilder: (context, index1) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) {
                          return WebImagePreview(
                              path: photosList[index].photos[index1].webLink!);
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                                imageUrl: photosList[index]
                                    .photos[index1]
                                    .thumbnailPath!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: photosList[index].photos[index1].isSelected
                                  ? AppColors.primaryColor.withOpacity(.65)
                                  : null),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, right: 4),
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  if (photosList[index].photos[index1].isEdit) {
                                    unSelectedDialog(context);
                                  } else {
                                    photosList[index]
                                            .photos[index1]
                                            .isSelected =
                                        !photosList[index]
                                            .photos[index1]
                                            .isSelected;
                                    if (selectedCountNotifier != null) {
                                      if (photosList[index]
                                          .photos[index1]
                                          .isSelected) {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value + 1;
                                      } else {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value - 1;
                                      }
                                    }
                                  }
                                  onPressed();
                                },
                                child: Container(
                                  height: 21.87,
                                  width: 30.07,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(.5),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(8),
                                      color: photosList[index]
                                              .photos[index1]
                                              .isSelected
                                          ? Colors.white
                                          : Colors.black.withOpacity(.3)),
                                  child: photosList[index]
                                          .photos[index1]
                                          .isSelected
                                      ? Image.asset(
                                          correct,
                                          height: 12,
                                          width: 12,
                                        )
                                      : const IgnorePointer(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static instaPhtotView(
    List<GroupedPhotoModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
  }) {
    return ListView.builder(
      itemCount: photosList.length,
      itemBuilder: (context, index) {
        return Wrap(
          children: [
            Padding(
              padding: index == 0
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: 16.0),
              child: Text(
                photosList[index].date,
                style: const TextStyle(
                  color: AppColors.monthColor,
                  fontFamily: robotoRegular,
                  fontSize: 22,
                  height: 28 / 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey(
                    'instaPhotosGrid'), // Key for persistent scroll state

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 2, // Aspect ratio of each grid item
                ),
                itemCount: photosList[index].photos.length,
                addAutomaticKeepAlives: false,
                itemBuilder: (context, index1) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) {
                          return WebImagePreview(
                              path: photosList[index].photos[index1].webLink!);
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                                imageUrl:
                                    photosList[index].photos[index1].webLink!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: photosList[index].photos[index1].isSelected
                                  ? AppColors.primaryColor.withOpacity(.65)
                                  : null),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, right: 4),
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  if (photosList[index].photos[index1].isEdit) {
                                    unSelectedDialog(context);
                                  } else {
                                    photosList[index]
                                            .photos[index1]
                                            .isSelected =
                                        !photosList[index]
                                            .photos[index1]
                                            .isSelected;
                                    if (selectedCountNotifier != null) {
                                      if (photosList[index]
                                          .photos[index1]
                                          .isSelected) {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value + 1;
                                      } else {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value - 1;
                                      }
                                    }
                                  }
                                  onPressed();
                                },
                                child: Container(
                                  height: 21.87,
                                  width: 30.07,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(.5),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(8),
                                      color: photosList[index]
                                              .photos[index1]
                                              .isSelected
                                          ? Colors.white
                                          : Colors.black.withOpacity(.3)),
                                  child: photosList[index]
                                          .photos[index1]
                                          .isSelected
                                      ? Image.asset(
                                          correct,
                                          height: 12,
                                          width: 12,
                                        )
                                      : const IgnorePointer(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static fbPhtotView(
    List<GroupedPhotoModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
  }) {
    print(photosList.length);
    return ListView.builder(
      itemCount: photosList.length,
      itemBuilder: (context, index) {
        return Wrap(
          children: [
            Padding(
              padding: index == 0
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: 16.0),
              child: Text(
                photosList[index].date,
                style: const TextStyle(
                  color: AppColors.monthColor,
                  fontFamily: robotoRegular,
                  fontSize: 22,
                  height: 28 / 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey(
                    'fbPhotosGrid'), // Key for persistent scroll state

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 2, // Aspect ratio of each grid item
                ),
                itemCount: photosList[index].photos.length,
                addAutomaticKeepAlives: false,
                itemBuilder: (context, index1) {
                  print(photosList[index].photos[index1]);
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) {
                          return WebImagePreview(
                              path: photosList[index].photos[index1].webLink!);
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                                imageUrl:
                                    photosList[index].photos[index1].webLink!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: photosList[index].photos[index1].isSelected
                                  ? AppColors.primaryColor.withOpacity(.65)
                                  : null),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, right: 4),
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  if (photosList[index].photos[index1].isEdit) {
                                    unSelectedDialog(context);
                                  } else {
                                    photosList[index]
                                            .photos[index1]
                                            .isSelected =
                                        !photosList[index]
                                            .photos[index1]
                                            .isSelected;
                                    if (selectedCountNotifier != null) {
                                      if (photosList[index]
                                          .photos[index1]
                                          .isSelected) {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value + 1;
                                      } else {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value - 1;
                                      }
                                    }
                                  }
                                  onPressed();
                                },
                                child: Container(
                                  height: 21.87,
                                  width: 30.07,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(.5),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(8),
                                      color: photosList[index]
                                              .photos[index1]
                                              .isSelected
                                          ? Colors.white
                                          : Colors.black.withOpacity(.3)),
                                  child: photosList[index]
                                          .photos[index1]
                                          .isSelected
                                      ? Image.asset(
                                          correct,
                                          height: 12,
                                          width: 12,
                                        )
                                      : const IgnorePointer(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget allAlbumView(
    List<CombinedPhotoModel> photoList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
    int? selectedCount,
        int? gridIndex,

    Function(double offset)? selectValue,
  }) {
      late GridObserverController observerController;

    final ScrollController _scrollController = ScrollController();
  final Map<int, ScrollController> gridControllers = {};
   if (selectedCount != null && selectedCount != 0) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
     double totalOffset = 0;

    for (int i = 0; i < selectedCount; i++) {
      // Calculate dynamic height for each ListView item
      double listItemHeight = calculateListItemHeight(
        photoList[i],
        108.0,  // Grid row height
        10.0,  // Grid spacing
        3,     // Number of columns in GridView
      );

      totalOffset += listItemHeight;
    }// Height of each GridView item row

      // ListView scroll offset

      // GridView scroll offset within the target ListView item
      double gridOffset = (gridIndex! ~/ 3) * 110;

       

      // Animate ListView scroll
      _scrollController.animateTo(
        totalOffset + gridOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

    return ListView.builder(
      controller: _scrollController,
      itemCount: photoList.length,
      itemBuilder: (context, index) {
                          gridControllers[index] = ScrollController();



        return Wrap(
          children: [
            Padding(
              padding: index == 0
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: 16.0),
              child: Text(
                photoList[index].createDate,
                style: const TextStyle(
                  color: AppColors.monthColor,
                  fontFamily: robotoRegular,
                  fontSize: 22,
                  height: 28 / 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: 
              GridView.builder(
                controller: gridControllers[index] ,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey(
                    'photoAllsGrid'), // Key for persistent scroll state

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 2, // Aspect ratio of each grid item
                ),
                itemCount: photoList[index].photos.length,
                addAutomaticKeepAlives: false,
                itemBuilder: (context, index1) {
                  return GestureDetector(
                    onTap: () {
                      if (photoList[index].photos[index1].type == "image") {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) {
                            return ImagePreview(
                                assetEntity: photoList[index]
                                    .photos[index1]
                                    .assetEntity!);
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) {
                            return WebImagePreview(
                                path: photoList[index].photos[index1].webLink!);
                          },
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        photoList[index].photos[index1].type == "image"
                            ? MyGridItem(
                                photoList[index].photos[index1].thumbData!)
                            : Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                      imageUrl: photoList[index]
                                                  .photos[index1]
                                                  .type ==
                                              "drive"
                                          ? photoList[index]
                                              .photos[index1]
                                              .drivethumbNail!
                                          : photoList[index]
                                              .photos[index1]
                                              .webLink!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => SizedBox(
                                            height: 120,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          )),
                                ),
                              ),
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: photoList[index].photos[index1].isSelected
                                ? AppColors.primaryColor.withOpacity(0.65)
                                : null,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, right: 4),
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  debugPrint(
                                      "${photoList[index].photos[index1].isEdit}");

                                  if (photoList[index].photos[index1].isEdit) {
                                    unSelectedDialog(context);
                                  } else {
                                    photoList[index].photos[index1].isSelected =
                                        !photoList[index]
                                            .photos[index1]
                                            .isSelected;
                                    if (selectedCountNotifier != null) {
                                      if (photoList[index]
                                          .photos[index1]
                                          .isSelected) {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value + 1;
                                      } else {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value - 1;
                                      }
                                    }
                                  }
                               onPressed();

                                },
                                child: Container(
                                  height: 21.87,
                                  width: 30.07,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: photoList[index]
                                            .photos[index1]
                                            .isSelected
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.3),
                                  ),
                                  child:
                                      photoList[index].photos[index1].isSelected
                                          ? Image.asset(
                                              correct,
                                              height: 12,
                                              width: 12,
                                            )
                                          : const IgnorePointer(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget albumView(
      List<PhotoGroupModel> photoList, VoidCallback onPressed,
      {ValueNotifier<int>? selectedCountNotifier,  int? selectedCount,
        int? gridIndex,}) {
     final ScrollController _scrollController = ScrollController();
  final Map<int, ScrollController> gridControllers = {};
   if (selectedCount != null && selectedCount != 0) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
     double totalOffset = 0;

    for (int i = 0; i < selectedCount; i++) {
      // Calculate dynamic height for each ListView item
      double listItemHeight = calculateCameraListItemHeight(
        photoList[i],
        80.0,  // Grid row height
        10.0,  // Grid spacing
        3,     // Number of columns in GridView
      );

      totalOffset += listItemHeight;
    }// Height of each GridView item row

      // ListView scroll offset

      // GridView scroll offset within the target ListView item
      double gridOffset = (gridIndex! ~/ 3) * 90;

       

      // Animate ListView scroll
      _scrollController.animateTo(
        totalOffset + gridOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

    return ListView.builder(
      controller: _scrollController,
      itemCount: photoList.length,
      itemBuilder: (context, index) {
        return Wrap(
          children: [
            Padding(
              padding: index == 0
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: 16.0),
              child: Text(
                photoList[index].date,
                style: const TextStyle(
                  color: AppColors.monthColor,
                  fontFamily: robotoRegular,
                  fontSize: 22,
                  height: 28 / 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey(
                    'photoAllsGrid'), // Key for persistent scroll state

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 2, // Aspect ratio of each grid item
                ),
                itemCount: photoList[index].photos.length,
                addAutomaticKeepAlives: false,
                itemBuilder: (context, index1) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) {
                          return ImagePreview(
                              assetEntity:
                                  photoList[index].photos[index1].assetEntity);
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        MyGridItem(photoList[index].future[index1]),
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: photoList[index].photos[index1].selectedValue
                                ? AppColors.primaryColor.withOpacity(0.65)
                                : null,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, right: 4),
                            child: PhysicalModel(
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  debugPrint(
                                      "${photoList[index].photos[index1].isEditmemory}");

                                  if (photoList[index]
                                      .photos[index1]
                                      .isEditmemory) {
                                    unSelectedDialog(context);
                                  } else {
                                    photoList[index]
                                            .photos[index1]
                                            .selectedValue =
                                        !photoList[index]
                                            .photos[index1]
                                            .selectedValue;
                                    if (selectedCountNotifier != null) {
                                      if (photoList[index]
                                          .photos[index1]
                                          .selectedValue) {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value + 1;
                                      } else {
                                        selectedCountNotifier.value =
                                            selectedCountNotifier.value - 1;
                                      }
                                    }
                                  }

                                  onPressed();
                                },
                                child: Container(
                                  height: 21.87,
                                  width: 30.07,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: photoList[index]
                                            .photos[index1]
                                            .selectedValue
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.3),
                                  ),
                                  child: photoList[index]
                                          .photos[index1]
                                          .selectedValue
                                      ? Image.asset(
                                          correct,
                                          height: 12,
                                          width: 12,
                                        )
                                      : const IgnorePointer(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static buttonForShareLink(BuildContext context,
      {Color? color, String? title}) {
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

  static Future<String> createDynamicLink(
    String memoryId,
    String title,
    String imageLink,
    String userName,
    String userProfileImage,
  ) async {
    String shareLink = "";
    FirebaseDynamicLinksPlatform dynamicLinks =
        FirebaseDynamicLinksPlatform.instance;

    const String URI_PREFIX_FIREBASE = "https://stashtdev.page.link";
    const String DEFAULT_FALLBACK_URL_ANDROID = "https://stashtdev.page.link";

    // Construct the dynamic link URL
    String link =
        "$DEFAULT_FALLBACK_URL_ANDROID/memory_id=${Uri.encodeComponent(memoryId)}"
        "&title=${Uri.encodeComponent(title)}"
        "&image_link=${Uri.encodeComponent(imageLink)}"
        "&user_name=${Uri.encodeComponent(userName)}"
        "&profile_image=${Uri.encodeComponent(userProfileImage)}";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: URI_PREFIX_FIREBASE,
      link: Uri.parse(link),
      androidParameters: const AndroidParameters(
        packageName: 'com.app.stasht.dev',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.app.stasht.dev',
        minimumVersion: '1',
        appStoreId: '6575378856',
      ),
    );

    try {
      final ShortDynamicLink shortLink =
          await dynamicLinks.buildShortLink(parameters);
      shareLink = shortLink.shortUrl.toString();
    } catch (error) {
      debugPrint("Error generating link: $error");
    }

    debugPrint("Generated link: $shareLink");
    return shareLink;
  }

  static void unSelectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.textfieldFillColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 312,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            height: 280,
            // Add padding for spacing
            decoration: BoxDecoration(
              color: AppColors.textfieldFillColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // Center content vertically
              children: [
                const SizedBox(
                  height: 25,
                ),
                Text(
                  "We are unable to delete \nthis photo from your \nmemory",
                  style: appTextStyle(
                    fz: 24,
                    height: 32 / 24,
                    fm: robotoRegular,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16), // Add spacing between elements
                Text(
                  "Please go to the memory details screen \nand tap on the edit icon on the top right \nof the image to delete it.",
                  style: appTextStyle(
                    fz: 14,
                    height: 20 / 14,
                    fm: robotoRegular,
                    color: AppColors.dialogMiddleFontColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                    height: 20), // Add spacing before the close button
                Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Ok",
                        style: appTextStyle(
                          fz: 14,
                          height: 20 / 14,
                          fm: robotoMedium,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      barrierColor: Colors.transparent,
    );
  }

  static void showBottomSheet(BuildContext context, VoidCallback callBack) {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissal by tapping outside
      backgroundColor: Colors.transparent,

      builder: (context) {
        // Start a timer to automatically close the bottom sheet
        Future.delayed(const Duration(seconds: 4), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close the bottom sheet
          }
        });
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: AppColors.black, borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Load another  images',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: robotoRegular),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  callBack();
                },
                child: Text('Load More',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: robotoRegular)),
              ),
            ],
          ),
        );
      },
    );
  }

static List<GroupedPhotoModel> combinedGroupPhotosByDate(
    List<PhotoDetailModel> photoLinks, List<GroupedPhotoModel> existingGroups) {
  // Map to hold grouped photos by date
  Map<String, List<PhotoDetailModel>> groupedPhotos = {};

  // Group photos by their date
  for (PhotoDetailModel photo in photoLinks) {
    String date = photo.captureDate!; // Assuming `PhotoLink` has a `date` property
    if (groupedPhotos.containsKey(date)) {
      groupedPhotos[date]!.add(photo);
    } else {
      groupedPhotos[date] = [photo];
    }
  }

  // Merge into existing groups or create new groups
  for (String date in groupedPhotos.keys) {
    // Find if the date group already exists in existingGroups
    GroupedPhotoModel? existingGroup = existingGroups.firstWhere(
      (group) => group.date == date,
            

    );

    if (existingGroup.photos.isNotEmpty) {
      // Add photos to the existing group
      existingGroup.photos.addAll(groupedPhotos[date]!);
    } else {
      // Create a new group and add it to the model
      existingGroups.add(
        GroupedPhotoModel(
          date: date,
          photos: groupedPhotos[date]!,
        ),
      );
    }
  }

  return existingGroups;
}



  static List<GroupedPhotoModel> groupPhotosByDate(
      List<PhotoDetailModel> photoDetails) {
    // Create a map to group photos by captureDate
    final groupedMap = <String, List<PhotoDetailModel>>{};

    for (var photo in photoDetails) {
      // Group photos by month-year
      if (photo.thumbnailPath != null) {
        if (photo.captureDate != null) {
          if (groupedMap.containsKey(photo.captureDate)) {
            groupedMap[photo.captureDate]!.add(photo);
          } else {
            groupedMap[photo.captureDate!] = [photo];
          }
        }
      }
    }


    // Convert the map to a list of GroupedPhotoModel
    List<GroupedPhotoModel> photGroup = groupedMap.entries.map((entry) {
      return GroupedPhotoModel(
        date: entry.key,
        photos: entry.value,
      );
    }).toList();
    photGroup.sort((a, b) {
      DateTime dateA = _parseMonthYear(a.date);
      DateTime dateB = _parseMonthYear(b.date);

      if (dateA.year != dateB.year) {
        return dateB.year.compareTo(dateA.year);
      } else {
        return dateB.month.compareTo(dateA.month);
      }
    });
    return photGroup;
  }

  static List<GroupedPhotoModel> groupPhotosForFBAndINSTAByDate(
      List<PhotoDetailModel> photoDetails) {
    // Create a map to group photos by captureDate
    final groupedMap = <String, List<PhotoDetailModel>>{};

    for (var photo in photoDetails) {
      // Group photos by month-year
      if (photo.webLink != null) {
        if (photo.captureDate != null) {
          if (groupedMap.containsKey(photo.captureDate)) {
            groupedMap[photo.captureDate]!.add(photo);
          } else {
            groupedMap[photo.captureDate!] = [photo];
          }
        }
      }
    }

    // Convert the map to a list of GroupedPhotoModel

    List<GroupedPhotoModel> photGroup = groupedMap.entries.map((entry) {
      return GroupedPhotoModel(
        date: entry.key,
        photos: entry.value,
      );
    }).toList();
    photGroup.sort((a, b) {
      DateTime dateA = _parseMonthYear(a.date);
      DateTime dateB = _parseMonthYear(b.date);

      if (dateA.year != dateB.year) {
        return dateB.year.compareTo(dateA.year);
      } else {
        return dateB.month.compareTo(dateA.month);
      }
    });
    return photGroup;
  }

  static List<PhotoGroupModel> groupGalleryPhotosByDate(
      List<PhotoModel> photoDetails, List<Future<Uint8List?>> futures) {
    // Create a map to group photos by captureDate
    final groupedMap = <String, List<PhotoModel>>{};
    final futureMap = <String, List<Future<Uint8List?>>>{};

    for (int i = 0; i < photoDetails.length; i++) {
      // Format the capture date to 'MMM yyyy'
      String changeTime = DateFormat('MMM yyyy')
          .format(photoDetails[i].assetEntity.createDateTime);

      if (changeTime.isNotEmpty) {
        // Group the photos
        if (groupedMap.containsKey(changeTime)) {
          groupedMap[changeTime]!.add(photoDetails[i]);
          futureMap[changeTime]!.add(futures[i]);
        } else {
          groupedMap[changeTime] = [photoDetails[i]];
          futureMap[changeTime] = [futures[i]];
        }
      }
    }
    List<PhotoGroupModel> photGroup = groupedMap.entries.map((entry) {
      final date = entry.key;
      final photos = entry.value;
      final photoFutures =
          futureMap[date] ?? []; // Match futures with grouped photos

      return PhotoGroupModel(
        date: date,
        photos: photos,
        future: photoFutures,
      );
    }).toList();
    photGroup.sort((a, b) {
      DateTime dateA = _parseMonthYear(a.date);
      DateTime dateB = _parseMonthYear(b.date);

      if (dateA.year != dateB.year) {
        return dateB.year.compareTo(dateA.year);
      } else {
        return dateB.month.compareTo(dateA.month);
      }
    });

    return photGroup;
  }

  static List<CombinedPhotoModel> allPhotoGroup(
      List<GroupedPhotoModel> driveGroupModel,
      List<GroupedPhotoModel> instaGroupModel,
      List<GroupedPhotoModel> fbGroupModel,
      List<PhotoGroupModel> photoGroupModel) {
    Map<String, List<AllPhotoModel>> combinedImages = {};

    for (int k = 0; k < driveGroupModel.length; k++) {
      for (var model in driveGroupModel[k].photos) {
        AllPhotoModel photo = AllPhotoModel();
        photo.id = model.id;
        photo.webLink = model.webLink;
        photo.type = model.type;
        photo.isEdit = model.isEdit;
        photo.drivethumbNail = model.thumbnailPath;
        photo.isSelected = model.isSelected;

        combinedImages
            .putIfAbsent(driveGroupModel[k].date, () => [])
            .add(photo);
      }
    }
    // Process InstaModels
    for (int k = 0; k < instaGroupModel.length; k++) {
      for (var model in instaGroupModel[k].photos) {
        AllPhotoModel photo = AllPhotoModel();
        photo.id = model.id;
        photo.webLink = model.webLink;
        photo.type = model.type;
        photo.isEdit = model.isEdit;
        photo.isSelected = model.isSelected;

        combinedImages
            .putIfAbsent(instaGroupModel[k].date, () => [])
            .add(photo);
      }
    }

    // Process FbModels
    for (int k = 0; k < fbGroupModel.length; k++) {
      for (var model in fbGroupModel[k].photos) {
        AllPhotoModel photo = AllPhotoModel();
        photo.id = model.id;
        photo.webLink = model.webLink;
        photo.type = model.type;
        photo.isEdit = model.isEdit;
        photo.isSelected = model.isSelected;

        combinedImages.putIfAbsent(fbGroupModel[k].date, () => []).add(photo);
      }
    }
    for (int k = 0; k < photoGroupModel.length; k++) {
      for (int i = 0; i < photoGroupModel[k].photos.length; i++) {
        AllPhotoModel photo = AllPhotoModel();
        photo.id = photoGroupModel[k].photos[i].assetEntity.id;
        photo.thumbData = photoGroupModel[k].future[i];
        photo.assetEntity = photoGroupModel[k].photos[i].assetEntity;
        photo.type = "image";
        photo.isEdit = photoGroupModel[k].photos[i].isEditmemory;
        photo.isSelected = photoGroupModel[k].photos[i].selectedValue;

        combinedImages
            .putIfAbsent(photoGroupModel[k].date, () => [])
            .add(photo);
      }
    }

    // Convert combined data into a list of CombinedPhotoModel
    List<CombinedPhotoModel> photoGroupModel1 = combinedImages.entries
        .map((entry) =>
            CombinedPhotoModel(createDate: entry.key, photos: entry.value))
        .toList();
    photoGroupModel1.sort((a, b) {
      DateTime dateA = _parseMonthYear(a.createDate);
      DateTime dateB = _parseMonthYear(b.createDate);

      if (dateA.year != dateB.year) {
        return dateB.year.compareTo(dateA.year);
      } else {
        return dateB.month.compareTo(dateA.month);
      }
    });

    // Output the combined list
    for (var model in photoGroupModel1) {
      print('Date: ${model.createDate}, Images: ${model.photos}');
    }
    return photoGroupModel1;
  }

  static DateTime _parseMonthYear(String monthYear) {
    const monthNames = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12
    };

    final parts = monthYear.split(' ');
    if (parts.length != 2) {
      throw FormatException("Invalid date format: $monthYear");
    }

    final month = monthNames[parts[0]];
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      throw FormatException("Invalid date format: $monthYear");
    }

    return DateTime(year, month);
  }

  static Future<void> initPlatformState(
      {Function(String memoryId)? returnBack}) async {
    // if (!mounted) return;

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(false);

    OneSignal.initialize(AppStrings.oneSingalToken);

    OneSignal.LiveActivities.setupDefault();

    OneSignal.Notifications.clearAll();
    print("token${OneSignal.User.pushSubscription.id}");
    PrefUtils.instance.oneSignalToken(OneSignal.User.pushSubscription.id!);

    OneSignal.User.pushSubscription.addObserver((state) {});

    OneSignal.User.addObserver((state) {
      var userState = state.jsonRepresentation();
      print('OneSignal user changed: $userState');
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });

    OneSignal.Notifications.addClickListener((event) {
      print(
          'NOTIFICATION CLICK LISTENER CALLED WITH EVENT: ${event.notification.jsonRepresentation()}');
      var data = json.encode(event.notification.additionalData);
      Map p = jsonDecode(data);

      returnBack!(p["memory_id"]);
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');

      /// Display Notification, preventDefault to not display
      event.preventDefault();

      /// Do async work

      /// notification.display() to display after preventing default
      event.notification.display();

      // this.setState(() {
      // });
    });

    OneSignal.InAppMessages.paused(true);
  }

  static String formatTimeAgo(DateTime dateTime, {bool numericDates = true}) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  static double calculateListItemHeight(CombinedPhotoModel photoModel, double gridRowHeight, double gridSpacing, int crossAxisCount) {
  int itemCount = photoModel.photos.length;
  int rowCount = (itemCount / crossAxisCount).ceil(); // Total rows in the grid
  double gridHeight = (rowCount * gridRowHeight) + ((rowCount - 1) * gridSpacing); // Total height of the grid
  double additionalHeight = 50.0; // Height for other widgets like title or padding
  return gridHeight + additionalHeight;
  
}
static double calculateCameraListItemHeight(PhotoGroupModel photoModel, double gridRowHeight, double gridSpacing, int crossAxisCount) {
  int itemCount = photoModel.photos.length;
  int rowCount = (itemCount / crossAxisCount).ceil(); // Total rows in the grid
  double gridHeight = (rowCount * gridRowHeight) + ((rowCount - 1) * gridSpacing); // Total height of the grid
  // Height for other widgets like title or padding
  return gridHeight;
  
}
}
