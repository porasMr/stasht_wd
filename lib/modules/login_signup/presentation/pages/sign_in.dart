import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/login_signup/presentation/pages/forgot_password_screen.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_up.dart';
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


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> implements ApiCallback {
  List<PhotoModel> photosList = [];

  int val = -1;
  bool isEmail = false;
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
    CommonWidgets.requestStoragePermission(((allAssets) {
      for (int i = 0; i < allAssets.length; i++) {
        photosList
            .add(PhotoModel(assetEntity: allAssets[i], selectedValue: false,isEditmemory: false));
        // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
      }
    }));
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    this.isLoggedIn = isLoggedIn;
    this.profileData = profileData;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 180,
                      ),
                      Center(
                        child: SvgPicture.asset(stashtLogo),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          AppStrings.signInBtnText,
                          style: const TextStyle(
                              fontSize: 27,
                              color: AppColors.primaryColor,
                              fontFamily: robotoBold,
                              height: 30 / 27),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          AppStrings.loginToAccount,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: robotoMedium,
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
                        margin:
                            const EdgeInsets.only(top: 10, left: 12, right: 12),
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
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 10),
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
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: isPasswordFocused ||
                                  passwordController.text.isNotEmpty
                              ? Colors.white
                              : AppColors.textfieldFillColor.withOpacity(0.75),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                focusNode: passwordFocusNode,
                                obscureText: isObscure, // Toggles visibility
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
                                        isObscure =
                                            !isObscure; // Toggles the obscure text state
                                      });
                                    },
                                    child: Icon(
                                      isObscure
                                          ? Icons
                                              .visibility_off // Eye closed icon
                                          : Icons.visibility, // Eye open icon
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  errorStyle: const TextStyle(
                                      color: AppColors.errorColor),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 10),
                                ),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (emailController.text.trim().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => ForgotPassword(
                                  email: emailController.text.trim(),
                                ),
                              ),
                            );

                          } else {
                            CommonWidgets.errorDialog(
                                context, 'Please enter email');
                          }
                        },
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              AppStrings.forgotPassword,
                              style: appTextStyle(
                                  fm: robotoRegular,
                                  color: AppColors.primaryColor,
                                  fz: 14),
                            )),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (checkSignInValidation()) {
                            signIn(context);
                          }
                        },
                        child: appButton(btnText: AppStrings.signInBtnText),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Signup()));
                        },
                        child: Center(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                  text: TextSpan(
                                      text: AppStrings.notAMember,
                                      style: appTextStyle(
                                        fm: robotoRegular,
                                        fz: 17,
                                      ),
                                      children: [
                                    TextSpan(
                                      text: AppStrings.signUpBtnText,
                                      style: appTextStyle(
                                          fm: robotoBold,
                                          fz: 17,
                                          color: AppColors.primaryColor),
                                    )
                                  ])),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ]),
              )),
        ),
      ],
    ));
  }

  signIn(BuildContext context) async {
    CommonWidgets.progressDialog();
    ApiCall.loginWithEmailPassword(
        api: ApiUrl.loginWithEmailPassword,
        email: emailController.value.text,
        password: passwordController.value.text,
        callack: this);
  }

  bool checkSignInValidation() {
    if (emailController.text.isEmpty) {
      CommonWidgets.errorDialog(context, "Enter a email!");
      return false;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text)) {
      CommonWidgets.errorDialog(context, "Enter a valid email!");
      return false;
    } else if (passwordController.text.isEmpty) {
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
    if (apiType == ApiUrl.socialLogin) {
      if (model.user!.facebookSynced == 0 &&
          model.user!.googleDriveSynced == 0 &&
          model.user!.instagramSynced == 0) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OnboardScreen()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    PhotosView(photosList: photosList,isSkip: false,)));
      }
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  PhotosView(photosList: photosList, isSkip: false,)));
    }

    print(model.token!);
  }

  @override
  void tokenExpired(String message) {}
}
