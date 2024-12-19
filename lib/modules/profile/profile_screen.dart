import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/profile/change_password.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';

import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/pref_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> implements ApiCallback {
  UserModel model = UserModel();
  File? _image;
  final picker = ImagePicker();

  bool changeUserName = false;
  TextEditingController password1Controller = TextEditingController();

  TextEditingController nameController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool changePassowrd = false;
  bool isDriveSync = false;
  bool isFbSync = false;

  bool isInstaeSync = false;
  String selectedType = "";
  @override
  void initState() {
    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      nameController.text = model.user!.name!;
      if (model.user!.googleDriveSynced == 1) {
        isDriveSync = true;
      }
      if (model.user!.facebookSynced == 1) {
        isFbSync = true;
      }
      if (model.user!.googleDriveSynced == 1) {
        isDriveSync = true;
      }
      setState(() {});
    });
    PrefUtils.instance.getDrivePrefs().then((value) {
      if (value.isNotEmpty) {
        isDriveSync = true;
      }
      setState(() {});
    });
    PrefUtils.instance.getFacebookPrefs().then((value) {
      if (value.isNotEmpty) {
        isFbSync = true;
      }
      setState(() {});
    });
    PrefUtils.instance.getInstaPrefs().then((value) {
      if (value.isNotEmpty) {
        isInstaeSync = true;
      }
      setState(() {});
    });
    super.initState();
  }

  Future getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // _image = File(image.path);

      uploadImageToDB(image.path);
    } else {
      debugPrint('No image selected.');
    }
  }

  uploadImageToDB(image) {
    EasyLoading.show();
    ApiCall.uploadImageIntoMemory(
        api: ApiUrl.uploadImageTomemory,
        path: image,
        count: "1",
        callack: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: const IgnorePointer(),
          leadingWidth: 0,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 15.0),
          //     child: Text(
          //       AppStrings.done,
          //       style: appTextStyle(
          //           fz: 17,
          //           fm: interMedium,
          //           color: Color(0XFF808080).withOpacity(.55)),
          //     ),
          //   )
          // ],
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back)),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  AppStrings.settings,
                  style: appTextStyle(
                      fz: 22,
                      height: 28 / 22,
                      fm: robotoRegular,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        /*  appBar: commonAppbar(
        context,
        settingsTitle,
        pageSelected: (isMemory, isPhotos, isNotification, isSettings) => {
          if (isMemory)
            {
              Get.back()
              // Get.offNamed(AppRoutes.memories)
            }
          else if (isNotification)
            {
              notificationCount.value = 0,
              controller.updateNotificationCount(),
              Get.offNamed(AppRoutes.notifications)
            }
        },
      ),*/
        body: SingleChildScrollView(
            child: Form(
          key: formkey,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 90,
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          getImage();
                        },
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100)),
                          child: Container(
                            height: 63,
                            width: 63,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                            margin: const EdgeInsets.only(top: 10),
                            child: model.user!.profileImage != ''
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(10000.0),
                                    child: CachedNetworkImage(
                                        imageUrl: model.user!.profileImage!,
                                        fit: BoxFit.cover,
                                        height: 63,
                                        width: 70,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress)),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Container(
                                      height: 63,
                                      width: 70,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryColor,
                                        /*??
                                                      AppColors
                                                          .primaryColor,*/

                                        // Color(int.tryParse(controller.userProfileColor.value.replaceAll("#", " "))!),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              207, 216, 220, 1),
                                        ),
                                      ),
                                      child: Text(
                                        "${model.user!.name![0]}",
                                        style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontFamily: robotoRegular),
                                      ) /*Image.asset(userIcon)*/,
                                    ),
                                  ),
                          ),
                        ),
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        indent: 0,
                        endIndent: 0,
                        color: AppColors.textfieldFillColor.withOpacity(.75),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 18,
                                    child: TextFormField(
                                      cursorColor: changeUserName
                                          ? Colors.blue
                                          : Colors.transparent,
                                      enableInteractiveSelection:
                                          changeUserName,
                                      readOnly: !changeUserName,
                                      // Disable text editing when readOnly is true
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      style: appTextStyle(
                                        fm: robotoRegular,
                                        fz: 17,
                                        height: 18 / 17,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    model.user!.email!,
                                    style: appTextStyle(
                                      color: AppColors.lightGrey,
                                      fm: robotoRegular,
                                      fz: 14,
                                      height: 18 / 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Toggle the cursor and editing capability
                                if (changeUserName) {
                                  if (nameController.value.text.isNotEmpty) {
                                    changeUserNameFunc();
                                  } // Save functionality
                                  else {
                                    CommonWidgets.errorDialog(
                                        context, 'Username can\'t be empty');
                                    //  Get.snackbar("Error", "Username can't be empty",
                                    //      colorText: AppColors.redColor);
                                  }
                                } else {
                                  setState(() {
                                    changeUserName = true;
                                  });
                                }

                                // Toggle the value
                              },
                              child: Text(
                                changeUserName ? "Save" : "Change",
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontFamily: robotoRegular,
                                  fontSize: 14,
                                  height: 18 / 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                AppStrings.password,
                                style: appTextStyle(
                                    fm: robotoRegular, fz: 17, height: 18 / 17),
                              ),
                            ),
                            /*        Expanded(
                              child: Obx(() => TextFormField(
                                    controller:
                                        controller.nameController.value,
                                    readOnly:
                                        !controller.changeUserName.value,
                                    decoration: const InputDecoration(
                                        labelText: "Display Name",
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            bottom: 10, top: 5)),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    validator: (userName) {
                                      if (userName!.isEmpty) {
                                        return "Please enter username";
                                      }
                                      return null;
                                    },
                                  ))),*/
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const ChangePassword()));
                                },
                                child: Text(
                                  changePassowrd ? "Save" : "Change",
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontFamily: robotoRegular,
                                    fontSize: 14,
                                    height: 18 / 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 16),
                        child: Text(
                          AppStrings.syncAccount,
                          style: appTextStyle(
                              fm: robotoRegular, fz: 17, height: 18 / 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 36, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.instagram,
                              style: appTextStyle(
                                  fm: robotoRegular, fz: 17, height: 18 / 17),
                            ),
                            /*        Expanded(
                              child: Obx(() => TextFormField(
                                    controller:
                                        controller.nameController.value,
                                    readOnly:
                                        !controller.changeUserName.value,
                                    decoration: const InputDecoration(
                                        labelText: "Display Name",
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            bottom: 10, top: 5)),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    validator: (userName) {
                                      if (userName!.isEmpty) {
                                        return "Please enter username";
                                      }
                                      return null;
                                    },
                                  ))),*/
                            switchIcon(type: "insta"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 36, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.facebook,
                              style: appTextStyle(
                                  fm: robotoRegular, fz: 17, height: 18 / 17),
                            ),
                            /*        Expanded(
                              child: Obx(() => TextFormField(
                                    controller:
                                        controller.nameController.value,
                                    readOnly:
                                        !controller.changeUserName.value,
                                    decoration: const InputDecoration(
                                        labelText: "Display Name",
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            bottom: 10, top: 5)),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    validator: (userName) {
                                      if (userName!.isEmpty) {
                                        return "Please enter username";
                                      }
                                      return null;
                                    },
                                  ))),*/
                            switchIcon(type: "fb"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 36, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.googleDrive,
                              style: appTextStyle(
                                  fm: robotoRegular, fz: 17, height: 18 / 17),
                            ),
                            /*        Expanded(
                              child: Obx(() => TextFormField(
                                    controller:
                                        controller.nameController.value,
                                    readOnly:
                                        !controller.changeUserName.value,
                                    decoration: const InputDecoration(
                                        labelText: "Display Name",
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            bottom: 10, top: 5)),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    validator: (userName) {
                                      if (userName!.isEmpty) {
                                        return "Please enter username";
                                      }
                                      return null;
                                    },
                                  ))),*/
                            switchIcon(type: "drive"),
                          ],
                        ),
                      ),
                      Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 13),
                        child: GestureDetector(
                          onTap: () async{
                            
         GoogleSignIn().signOut();

 EasyLoading.show();
                      ApiCall.deleteUserAccount(api: ApiUrl.unSyncAccount, callack: this);

                            
                          },
                          child: Text(
                            AppStrings.logout,
                            style: appTextStyle(
                                fm: robotoRegular, fz: 17, height: 18 / 17),
                          ),
                        ),
                      ),
                      Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 13),
                        child: GestureDetector(
                          onTap: () {
                            deleteAccountAlert(context);
                          },
                          child: Text(
                            deleteAccount,
                            style: appTextStyle(
                                fm: robotoRegular, fz: 17, height: 18 / 17),
                          ),
                        ),
                      ),
                      Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75),
                      ),
                      /* const SizedBox(
                      height: 60,
                    ),
                    Center(
                      child: MaterialButton(
                        onPressed: () {
                          controller.logoutUser();
                        },
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5))),
                        color: AppColors.primaryColor,
                        child: const Text('Logout',
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (!isSocailUser)
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.changePassword);
                        },
                        child: Text(
                          changePassword,
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        controller.deleteAccountAlert(context);
                      },
                      child: Text(
                        deleteAccount,
                        style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline),
                        textAlign: TextAlign.center,
                      ),
                    ),*/
                    ],
                  )
                ],
              ),
            ),
          ),
        )));
  }

  switchIcon({String? type}) {
    return Switch(
      value: type == "drive"
          ? isDriveSync
          : type == "fb"
              ? isFbSync
              : type == "insta"
                  ? isInstaeSync
                  : false,
      activeColor: Colors.white,
      trackOutlineColor: borderColorValue(type: type),
      trackColor: activeColorValue(type: type),
      inactiveThumbColor: Color(0XFF79747E),
      activeTrackColor: AppColors.primaryColor,
      onChanged: (bool value) async {
        if (type == "drive") {
          isDriveSync = false;
          selectedType = "google_drive_synced";
        } else if (type == "fb") {
          isFbSync = false;
          selectedType = "facebook_synced";
        } else {
          isInstaeSync = false;
          selectedType = "instagram_synced";
        }
        if (value == false) {
          EasyLoading.show();

          ApiCall.syncAccount(
              api: ApiUrl.syncAccount,
              type: selectedType,
              status: "0",
              callack: this);
        }
        setState(() {});
      },
    );
  }

  void changeUserNameFunc() {
    if (formkey.currentState!.validate()) {
      model.user!.profileImage = nameController.text;

      EasyLoading.show();
      ApiCall.updateProfile(
          api: ApiUrl.updateProfile,
          type: "name",
          value: nameController.text,
          callack: this);
    }
  }

  activeColorValue({String? type}) {
    // if (type == "drive") {
    //   if (controller.isDriveSync.isTrue) {
    //     return MaterialStateProperty.all(AppColors.primaryColor);
    //   } else {
    //     return MaterialStateProperty.all(const Color(0XFFE6E0E9));
    //   }
    // } else if (type == "insta") {
    //   if (controller.isInstaeSync.isTrue) {
    //     return MaterialStateProperty.all(AppColors.primaryColor);
    //   } else {
    //     return MaterialStateProperty.all(const Color(0XFFE6E0E9));
    //   }
    // } else {
    //   if (controller.isFbSync.isTrue) {
    //     return MaterialStateProperty.all(AppColors.primaryColor);
    //   } else {
    //     return MaterialStateProperty.all(const Color(0XFFE6E0E9));
    //   }
    // }
  }

  borderColorValue({String? type}) {
    // if (type == "drive") {
    //   if (controller.isDriveSync.isTrue) {
    //     return MaterialStateProperty.all(Colors.transparent);
    //   } else {
    //     return MaterialStateProperty.all(const Color(0XFF79747E));
    //   }
    // } else if (type == "insta") {
    //   if (controller.isInstaeSync.isTrue) {
    //     return MaterialStateProperty.all(Colors.transparent);
    //   } else {
    //     return MaterialStateProperty.all(const Color(0XFF79747E));
    //   }
    // } else {
    //   if (controller.isFbSync.isTrue) {
    //     return MaterialStateProperty.all(Colors.transparent);
    //   } else {
    //     return MaterialStateProperty.all(const Color(0XFF79747E));
    //   }
    // }
  }

  logoutUser() {}

  void deleteAccountAlert(
    BuildContext context,
  ) {
    FocusNode focusNode = FocusNode();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                color: Colors.white),
            height:  300,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
                  child: Text(
                    'Are you sure you want to delete your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.darkColor,
                        fontFamily: robotoBold),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                                 GoogleSignIn().signOut();

                        EasyLoading.show();
                      ApiCall.deleteUserAccount(api: ApiUrl.deleteUserAccount, callack: this);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: AppColors.hintTextColor),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primaryColor,
                              fontFamily: robotoBold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: AppColors.hintTextColor),
                        child: const Text(
                          'No',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primaryColor,
                              fontFamily: robotoBold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }).whenComplete(() {
      password1Controller.clear();
      focusNode.unfocus();
    });
  }

  @override
  void onFailure(String message) {
    EasyLoading.dismiss();

    CommonWidgets.errorDialog(context, message);
  }

  @override
  void onSuccess(String data, String apiType) {
              EasyLoading.dismiss();

    print(data);
    if (apiType == ApiUrl.uploadImageTomemory) {
      var img = json.decode(data.split("=")[0])['file'].toString();
      model.user!.profileImage = img;
      PrefUtils.instance.saveUserToPrefs(model);
                  CommonWidgets.successDialog(context, json.decode(data)['message']);

      ApiCall.updateProfile(
          api: ApiUrl.updateProfile, type: "image", value: img, callack: this);
    } else if (apiType == ApiUrl.updateProfile) {
                  CommonWidgets.successDialog(context, json.decode(data)['message']);

      EasyLoading.dismiss();
      changeUserName = false;
      setState(() {});
    } else if (apiType == ApiUrl.deleteUserAccount) {
              PrefUtils.instance.driveToken('');

      PrefUtils.instance.clearPreferance();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/SignIn', (Route<dynamic> route) => false);
    } else if (apiType == ApiUrl.syncAccount) {
                  CommonWidgets.successDialog(context, json.decode(data)['message']);

      EasyLoading.dismiss();
      if (selectedType == "facebook_synced") {
        model.user!.facebookSynced = 0;
        isFbSync = false;
        PrefUtils.instance.saveFacebookPhotoLinks([]);
      } else if (selectedType == "google_drive_synced") {
        isDriveSync = false;
        model.user!.googleDriveSynced = 0;
        PrefUtils.instance.driveToken('');
        PrefUtils.instance.saveDrivePhotoLinks([]);
      } 
      else {
        PrefUtils.instance.saveInstaPhotoLinks([]);

        isInstaeSync = false;
        model.user!.instagramSynced = 0;
      }
      PrefUtils.instance.saveUserToPrefs(model);
    }else if(apiType==ApiUrl.unSyncAccount){
              PrefUtils.instance.driveToken('');

      PrefUtils.instance.clearPreferance();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/SignIn', (Route<dynamic> route) => false);
    }
if(mounted){
 setState(() {});
}
   
  }

  @override
  void tokenExpired(String message) {
    // TODO: implement tokenExpired
  }
}
