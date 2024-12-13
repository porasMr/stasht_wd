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
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stasht/modules/media/image_grid.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
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
                  loginWithFacebook()!.then((value) {
                    callBack(value!);
                  });
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

  static instaView(BuildContext context, Function(String token) callBack) {
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
                debugPrint("Instagram is opened this");
                openInstagramPage(context)!.then((value) {
                  callBack(value);
                });
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

  static driveView(BuildContext context, Function(GoogleSignIn v,String pageToken) callBack) {
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
                getFileFromGoogleDrive(context).then((value) {
                  callBack(value!,PrefUtils.instance.getDriveToken()!);
                });
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
        type: Platform.isAndroid ? RequestType.image : RequestType.all,
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
              color: Color.fromARGB(255, 245, 74, 74),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
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
              color: Color.fromARGB(255, 12, 160, 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Success',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
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

  static String dateFormatRetrun(String value) {
    return DateFormat("MMM d, yyyy").format(DateTime.parse(value));
  }

  static drivePhtotView(
    List<PhotoDetailModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
    ScrollController? controller,
  }) {
    print(photosList);

    return GridView.builder(
      controller: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 2, // Aspect ratio of each grid item
      ),
      itemCount: photosList.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) {
                return WebImagePreview(path: photosList[index].webLink!);
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
                      imageUrl: photosList[index].thumbnailPath!,
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
                    color: photosList[index].isSelected
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
                        

                        if (selectedCountNotifier != null) {
                          if (photosList[index].isEdit) {
                            unSelectedDialog(context);
                          } else {
                            photosList[index].isSelected =
                            !photosList[index].isSelected;
                            if (photosList[index].isSelected) {
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
                            color: photosList[index].isSelected
                                ? Colors.white
                                : Colors.black.withOpacity(.3)),
                        child: photosList[index].isSelected
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
    );
  }

  static instaPhtotView(
    List<PhotoDetailModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 2, // Aspect ratio of each grid item
      ),
      itemCount: photosList.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) {
                return WebImagePreview(path: photosList[index].webLink!);
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
                      imageUrl: photosList[index].webLink ?? "",
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
                    color: photosList[index].isSelected
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
                        

                        if (selectedCountNotifier != null) {
                          if (photosList[index].isEdit) {
                            unSelectedDialog(context);
                          } else {
                            photosList[index].isSelected =
                            !photosList[index].isSelected;
                            if (photosList[index].isSelected) {
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
                            color: photosList[index].isSelected
                                ? Colors.white
                                : Colors.black.withOpacity(.3)),
                        child: photosList[index].isSelected
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
    );
  }

  static fbPhtotView(
    List<PhotoDetailModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 2, // Aspect ratio of each grid item
      ),
      itemCount: photosList.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) {
                return WebImagePreview(path: photosList[index].webLink!);
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
                      imageUrl: photosList[index].webLink ?? "",
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
                    color: photosList[index].isSelected
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
                       
                       // photosList[index].isEdit = false;

                        if (selectedCountNotifier != null) {
                           photosList[index].isSelected =
                            !photosList[index].isSelected;
                         if (photosList[index].isEdit) {
                            unSelectedDialog(context);
                          } else {
                            if (photosList[index].isSelected) {
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
                            color: photosList[index].isSelected
                                ? Colors.white
                                : Colors.black.withOpacity(.3)),
                        child: photosList[index].isSelected
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
    );
  }

  static Widget allAlbumView(
    List<Future<Uint8List?>> future,
    List<PhotoModel> photosList,
    List<PhotoDetailModel> fbList,
    List<PhotoDetailModel> driveList,
    List<PhotoDetailModel> instaList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1, // Aspect ratio of each grid item (2 / 2 = 1)
          ),
          itemCount: photosList.length,
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  builder: (context) {
                    return ImagePreview(
                        assetEntity: photosList[index].assetEntity);
                  },
                );
              },
              child: Stack(
                children: [
                  MyGridItem(future[index]),
                  Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: photosList[index].selectedValue
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
                            debugPrint("Image Selected");
                            photosList[index].selectedValue =
                                !photosList[index].selectedValue;

                            if (selectedCountNotifier != null) {
                              if (photosList[index].selectedValue) {
                                selectedCountNotifier.value =
                                    selectedCountNotifier.value + 1;
                              } else {
                                selectedCountNotifier.value =
                                    selectedCountNotifier.value - 1;
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
                              color: photosList[index].selectedValue
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.3),
                            ),
                            child: photosList[index].selectedValue
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
        //     if(fbList.isNotEmpty)
        //     GridView.builder(
        //   shrinkWrap: true,
        //   physics:const NeverScrollableScrollPhysics(),
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 3, // Number of columns
        //     crossAxisSpacing: 10.0,
        //     mainAxisSpacing: 10.0,
        //     childAspectRatio: 2 / 2, // Aspect ratio of each grid item
        //   ),
        //   itemCount: fbList.length,
        //   addAutomaticKeepAlives: false,
        //   itemBuilder: (context, index) {
        //     return GestureDetector(
        //       onTap: () {
        //         fbList[index].isSelected = !fbList[index].isSelected;
        //         if (selectedCountNotifier != null) {
        //            if (fbList[index].isSelected) {
        //                         selectedCountNotifier.value =
        //                             selectedCountNotifier.value + 1;
        //                       } else {
        //                         selectedCountNotifier.value =
        //                             selectedCountNotifier.value - 1;
        //                       }
        //         }
        //         onPressed();
        //       },
        //       child: Stack(
        //         children: [
        //           Container(
        //             height: 120,
        //             width: MediaQuery.of(context).size.width,
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             child: ClipRRect(
        //               borderRadius: BorderRadius.circular(12),
        //               child: CachedNetworkImage(
        //                   imageUrl: fbList[index].webLink ?? "",
        //                   fit: BoxFit.cover,
        //                   placeholder: (context, url) => SizedBox(
        //                         height: 120,
        //                         width: MediaQuery.of(context).size.width,
        //                         child: const Center(
        //                           child: CircularProgressIndicator(
        //                             color: AppColors.primaryColor,
        //                           ),
        //                         ),
        //                       )),
        //             ),
        //           ),
        //           Container(
        //             height: 120,
        //             width: MediaQuery.of(context).size.width,
        //             decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(12),
        //                 color: fbList[index].isSelected
        //                     ? AppColors.primaryColor.withOpacity(.65)
        //                     : null),
        //           ),
        //           Positioned(
        //             top: 5,
        //             right: 5,
        //             child: Padding(
        //               padding: EdgeInsets.only(top: 4, right: 4),
        //               child: PhysicalModel(
        //                 borderRadius: BorderRadius.circular(8),
        //                 elevation: 4,
        //                 color: Colors.transparent,
        //                 child: Container(
        //                   height: 21.87,
        //                   width: 30.07,
        //                   alignment: Alignment.center,
        //                   decoration: BoxDecoration(
        //                       border: Border.all(
        //                           color: Colors.white.withOpacity(.5), width: 1.5),
        //                       borderRadius: BorderRadius.circular(8),
        //                       color: fbList[index].isSelected
        //                           ? Colors.white
        //                           : Colors.black.withOpacity(.3)),
        //                   child: fbList[index].isSelected
        //                       ? Image.asset(
        //                           correct,
        //                           height: 12,
        //                           width: 12,
        //                         )
        //                       : const IgnorePointer(),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        // if(instaList.isNotEmpty)
        //  GridView.builder(
        //   shrinkWrap: true,
        //   physics:const NeverScrollableScrollPhysics(),
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 3, // Number of columns
        //     crossAxisSpacing: 10.0,
        //     mainAxisSpacing: 10.0,
        //     childAspectRatio: 2 / 2, // Aspect ratio of each grid item
        //   ),
        //   itemCount: instaList.length,
        //   addAutomaticKeepAlives: false,
        //   itemBuilder: (context, index) {
        //     return GestureDetector(
        //       onTap: () {
        //         instaList[index].isSelected = !instaList[index].isSelected;
        //         if (selectedCountNotifier != null) {
        //            if (instaList[index].isSelected) {
        //                         selectedCountNotifier.value =
        //                             selectedCountNotifier.value + 1;
        //                       } else {
        //                         selectedCountNotifier.value =
        //                             selectedCountNotifier.value - 1;
        //                       }
        //         }
        //         onPressed();
        //       },
        //       child: Stack(
        //         children: [
        //           Container(
        //             height: 120,
        //             width: MediaQuery.of(context).size.width,
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             child: ClipRRect(
        //               borderRadius: BorderRadius.circular(12),
        //               child: CachedNetworkImage(
        //                   imageUrl: instaList[index].webLink ?? "",
        //                   fit: BoxFit.cover,
        //                   placeholder: (context, url) => SizedBox(
        //                         height: 120,
        //                         width: MediaQuery.of(context).size.width,
        //                         child: const Center(
        //                           child: CircularProgressIndicator(
        //                             color: AppColors.primaryColor,
        //                           ),
        //                         ),
        //                       )),
        //             ),
        //           ),
        //           Container(
        //             height: 120,
        //             width: MediaQuery.of(context).size.width,
        //             decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(12),
        //                 color: instaList[index].isSelected
        //                     ? AppColors.primaryColor.withOpacity(.65)
        //                     : null),
        //           ),
        //           Positioned(
        //             top: 5,
        //             right: 5,
        //             child: Padding(
        //               padding: EdgeInsets.only(top: 4, right: 4),
        //               child: PhysicalModel(
        //                 borderRadius: BorderRadius.circular(8),
        //                 elevation: 4,
        //                 color: Colors.transparent,
        //                 child: Container(
        //                   height: 21.87,
        //                   width: 30.07,
        //                   alignment: Alignment.center,
        //                   decoration: BoxDecoration(
        //                       border: Border.all(
        //                           color: Colors.white.withOpacity(.5), width: 1.5),
        //                       borderRadius: BorderRadius.circular(8),
        //                       color: instaList[index].isSelected
        //                           ? Colors.white
        //                           : Colors.black.withOpacity(.3)),
        //                   child: instaList[index].isSelected
        //                       ? Image.asset(
        //                           correct,
        //                           height: 12,
        //                           width: 12,
        //                         )
        //                       : const IgnorePointer(),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        // if(driveList.isNotEmpty)
        // GridView.builder(
        //   shrinkWrap: true,
        //   physics:const NeverScrollableScrollPhysics(),
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 3, // Number of columns
        //     crossAxisSpacing: 10.0,
        //     mainAxisSpacing: 10.0,
        //     childAspectRatio: 2 / 2, // Aspect ratio of each grid item
        //   ),
        //   itemCount: driveList.length,
        //   addAutomaticKeepAlives: false,
        //   itemBuilder: (context, index) {
        //     return GestureDetector(
        //       onTap: () {
        //         driveList[index].isSelected = !driveList[index].isSelected;
        //         if (selectedCountNotifier != null) {
        //            if (driveList[index].isSelected) {
        //                         selectedCountNotifier.value =
        //                             selectedCountNotifier.value + 1;
        //                       } else {
        //                         selectedCountNotifier.value =
        //                             selectedCountNotifier.value - 1;
        //                       }
        //         }
        //         onPressed();
        //       },
        //       child: Stack(
        //         children: [
        //           Container(
        //             height: 120,
        //             width: MediaQuery.of(context).size.width,
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             child: ClipRRect(
        //               borderRadius: BorderRadius.circular(12),
        //               child: CachedNetworkImage(
        //                   imageUrl: driveList[index].webLink ?? "",
        //                   fit: BoxFit.cover,
        //                   placeholder: (context, url) => SizedBox(
        //                         height: 120,
        //                         width: MediaQuery.of(context).size.width,
        //                         child: const Center(
        //                           child: CircularProgressIndicator(
        //                             color: AppColors.primaryColor,
        //                           ),
        //                         ),
        //                       )),
        //             ),
        //           ),
        //           Container(
        //             height: 120,
        //             width: MediaQuery.of(context).size.width,
        //             decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(12),
        //                 color: driveList[index].isSelected
        //                     ? AppColors.primaryColor.withOpacity(.65)
        //                     : null),
        //           ),
        //           Positioned(
        //             top: 5,
        //             right: 5,
        //             child: Padding(
        //               padding: EdgeInsets.only(top: 4, right: 4),
        //               child: PhysicalModel(
        //                 borderRadius: BorderRadius.circular(8),
        //                 elevation: 4,
        //                 color: Colors.transparent,
        //                 child: Container(
        //                   height: 21.87,
        //                   width: 30.07,
        //                   alignment: Alignment.center,
        //                   decoration: BoxDecoration(
        //                       border: Border.all(
        //                           color: Colors.white.withOpacity(.5), width: 1.5),
        //                       borderRadius: BorderRadius.circular(8),
        //                       color: driveList[index].isSelected
        //                           ? Colors.white
        //                           : Colors.black.withOpacity(.3)),
        //                   child: driveList[index].isSelected
        //                       ? Image.asset(
        //                           correct,
        //                           height: 12,
        //                           width: 12,
        //                         )
        //                       : const IgnorePointer(),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // )
      ],
    );
  }

  static Widget albumView(
    List<Future<Uint8List?>> future,
    List<PhotoModel> photosList,
    VoidCallback onPressed, {
    ValueNotifier<int>? selectedCountNotifier,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1, // Aspect ratio of each grid item (2 / 2 = 1)
      ),
      itemCount: photosList.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) {
                return ImagePreview(assetEntity: photosList[index].assetEntity);
              },
            );
          },
          child: Stack(
            children: [
              MyGridItem(future[index]),
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: photosList[index].selectedValue
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
                        debugPrint("Image Selected");
                        

                       
                        if (photosList[index].isEditmemory) {
                            unSelectedDialog(context);
                          } else {
                            photosList[index].selectedValue =
                            !photosList[index].selectedValue;
                            if (selectedCountNotifier != null) {
                          if (photosList[index].selectedValue) {
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
                          color: photosList[index].selectedValue
                              ? Colors.white
                              : Colors.black.withOpacity(0.3),
                        ),
                        child: photosList[index].selectedValue
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

  }
