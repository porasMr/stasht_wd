import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_in.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/onboarding/onboarding_screen.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/pref_utils.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> implements ApiCallback {
  int val = -1;
  bool isEmail = false;
  List<PhotoModel> photosList = [];

  bool isLoggedIn = false;
  var profileData;
  bool isObscure = true;
  final bool isLoginObscure = true;
  final bool isObscureCP = true;
  var isLoadingDriveImages = false.obs;
  //var controller = Get.put(SignupController());
  final formkey = GlobalKey<FormState>();
  final formkeySignin = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool isNameFocused = false;
  bool isEmailFocused = false;
  bool isPasswordFocused = false;

  @override
  void initState() {
       CommonWidgets.initPlatformState();

    CommonWidgets.requestStoragePermission(((allAssets) {
      for (int i = 0; i < allAssets.length; i++) {
        photosList
            .add(PhotoModel(assetEntity: allAssets[i], selectedValue: false,isEditmemory: false));
        // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
      }
    }));
    nameFocusNode.addListener(() {
      setState(() {
        isNameFocused = nameFocusNode.hasFocus;
      });
    });

    emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = emailFocusNode.hasFocus;
      });
    });

    passwordFocusNode.addListener(() {
      setState(() {
        isPasswordFocused = passwordFocusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.topRight,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .61,
              child: Image.asset(
                backgroundGradient,
                width: MediaQuery.of(context).size.width * .6,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 180,
                        ),
                        Center(
                          child: SvgPicture.asset(stashtLogo),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            AppStrings.signUp,
                            style: const TextStyle(
                                fontSize: 27,
                                color: AppColors.primaryColor,
                                fontFamily: robotoBold,
                                fontWeight: FontWeight.w700,
                                height: 30 / 27),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            AppStrings.createNewAccount,
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: robotoMedium,
                                fontWeight: FontWeight.w500,
                                height: 26.2 / 20),
                          ),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CommonWidgets.googleButton(this),
                            if (Platform.isIOS) const SizedBox(width: 60),
                            if (Platform.isIOS) CommonWidgets.appleButton(this)
                          ],
                        ),
                        Container(
                          height: 29,
                          margin: const EdgeInsets.only(
                              top: 10, left: 16, right: 16),
                          child: Row(children: <Widget>[
                            const Expanded(
                                child: Divider(
                              height: 1,
                              color: Colors.black,
                            )),
                            const SizedBox(
                              width: 35,
                            ),
                            Text(
                              "or",
                              style: appTextStyle(
                                fz: 20,
                                color: AppColors.black,
                                fm: interRegular,
                              ),
                            ),
                            const SizedBox(
                              width: 35,
                            ),
                            const Expanded(
                                child: Divider(
                              height: 1,
                              color: Colors.black,
                            )),
                          ]),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: isNameFocused ||
                                          userNameController.text.isNotEmpty
                                      ? 1
                                      : 0,
                                  color: isNameFocused ||
                                          userNameController.text.isNotEmpty
                                      ? AppColors.primaryColor
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(16),
                              color: isNameFocused ||
                                      userNameController.text.isNotEmpty
                                  ? Colors.white
                                  : AppColors.textfieldFillColor
                                      .withOpacity(0.75)),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  focusNode: nameFocusNode,
                                  controller: userNameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    prefixIcon: isNameFocused ||
                                            userNameController.text.isNotEmpty
                                        ? null
                                        : const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: Icon(
                                              Icons.person_outline,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 5, 20, 10),
                                    labelText: AppStrings.fullName,
                                    labelStyle: appTextStyle(
                                      fz: isNameFocused ? 13 : 17,
                                      color: AppColors.primaryColor,
                                      fm: interRegular,
                                    ),
                                    hintStyle: appTextStyle(
                                      fz: 17,
                                      color: AppColors.primaryColor,
                                      fm: interRegular,
                                    ),
                                    errorStyle: const TextStyle(
                                        color: AppColors.errorColor),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 50,
                          // padding:   EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  width: isEmailFocused ||
                                          emailController.text.isNotEmpty
                                      ? 1
                                      : 0,
                                  color: isEmailFocused ||
                                          emailController.text.isNotEmpty
                                      ? AppColors.primaryColor
                                      : Colors.transparent),
                              color: isEmailFocused ||
                                      emailController.text.isNotEmpty
                                  ? Colors.white
                                  : AppColors.textfieldFillColor
                                      .withOpacity(0.75)),
                          // padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  focusNode: emailFocusNode,
                                  controller: emailController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: isEmailFocused ||
                                            emailController.text.isNotEmpty
                                        ? null
                                        : const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: Icon(
                                              Icons.mail_outline,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                    labelText: AppStrings.email,
                                    hintStyle: appTextStyle(
                                      fz: 17,
                                      color: AppColors.primaryColor,
                                      fm: interRegular,
                                    ),
                                    labelStyle: appTextStyle(
                                      fz: isEmailFocused ? 13 : 17,
                                      color: AppColors.primaryColor,
                                      fm: interRegular,
                                    ),
                                    errorStyle: const TextStyle(
                                        color: AppColors.errorColor),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 5, 20, 10),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: isPasswordFocused ||
                                      passwordController.text.isNotEmpty
                                  ? 1
                                  : 0,
                              color: isPasswordFocused ||
                                      passwordController.text.isNotEmpty
                                  ? AppColors.primaryColor
                                  : Colors
                                      .transparent, // Border only when focused or text present
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: isPasswordFocused ||
                                    passwordController.text.isNotEmpty
                                ? Colors.white
                                : AppColors.textfieldFillColor.withOpacity(
                                    0.75), // Set a consistent background color
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  focusNode: passwordFocusNode,
                                  obscureText: isObscure,
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    prefixIcon: isPasswordFocused ||
                                            passwordController.text.isNotEmpty
                                        ? null
                                        : const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: Icon(
                                              Icons.lock_outline,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                    labelText: AppStrings.password,
                                    hintStyle: appTextStyle(
                                      fz: 17,
                                      color: AppColors.primaryColor,
                                      fm: interRegular,
                                    ),
                                    labelStyle: appTextStyle(
                                      fz: isPasswordFocused ? 13 : 17,
                                      color: AppColors.primaryColor,
                                      fm: interRegular,
                                    ),
                                    suffixIcon: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setState(() {
                                          isObscure = !isObscure;
                                        });
                                      },
                                      child: Icon(
                                        isObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: AppColors.errorColor),
                                    border: InputBorder
                                        .none, // No border inside TextFormField
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 5, 20, 10),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (checkSignUpValidation()) {
                                signUp(context);
                              }
                            },
                            child: appButton(
                              btnText: AppStrings.signUpBtnText,
                            )),
                        const SizedBox(
                          height: 36,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const SignIn()));
                          },
                          child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                    text: TextSpan(
                                        text: AppStrings.alreadyHaveAccount,
                                        style: appTextStyle(
                                          fm: robotoRegular,
                                          fz: 17,
                                        ),
                                        children: [
                                      TextSpan(
                                        text: AppStrings.signInBtnText,
                                        style: appTextStyle(
                                            fm: robotoBold,
                                            fz: 17,
                                            color: AppColors.primaryColor),
                                      )
                                    ]))),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ));
  }

  bool checkSignUpValidation() {
    if (userNameController.value.text.isEmpty) {
      CommonWidgets.errorDialog(context, "Username can't be empty!");
      return false;
    } else if (emailController.value.text.isEmpty) {
      CommonWidgets.errorDialog(context, "Enter a email!");
      return false;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.value.text)) {
      CommonWidgets.errorDialog(context, "Enter a valid email!");
      return false;
    } else if (passwordController.value.text.isEmpty) {
      CommonWidgets.errorDialog(context, "Password field can't be empty!");
      return false;
    } else if (passwordController.value.text.length<6) {
      CommonWidgets.errorDialog(context, "Password length should be six character");
      return false;
    }
    else {
      return true;
    }
  }

  signUp(BuildContext context) async {
    CommonWidgets.progressDialog();

    ApiCall.registerUserAccount(
        api: ApiUrl.register,
        email: emailController.value.text,
        password: passwordController.value.text,
        name: userNameController.value.text,
      deviceToken:PrefUtils.instance.getOneSingalToken()??'',
      deviceType: Platform.isAndroid?"android":"ios",

        callack: this);
  }

  @override
  void onFailure(String message) {
    
    CommonWidgets.errorDialog(context, message);
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);

    print(apiType);
    UserModel model = UserModel.fromJson(jsonDecode(data));
    PrefUtils.instance.saveUserToPrefs(model);
    PrefUtils.instance.authToken(model.token!);
    if (apiType == ApiUrl.register) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const OnboardScreen()));
    } else if (apiType == ApiUrl.socialLogin) {
      if (model.hasMemory == 0 ) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const OnboardScreen()));
      }else{
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  PhotosView(photosList: photosList, isSkip: false,)));
      }
    
      }
      
    }
  

  @override
  void tokenExpired(String message) {}
}
