import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stasht/utils/common_widgets.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/assets_images.dart';
import '../../../../utils/constants.dart';

class ForgotPassword extends StatefulWidget {
  final String? email;

  const ForgotPassword({super.key, this.email});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isEmailFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }

    emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    emailController.dispose();
    super.dispose();
  }

  void sendResendLink() {
    if (formKey.currentState?.validate() ?? false) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
                             data:CommonWidgets.textScale(context),

      child: Scaffold(
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
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 25, right: 25),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SvgPicture.asset(
                          stashtLogo,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              "Forget Password",
                              style: TextStyle(
                                fontSize: 21,
                                fontFamily: robotoBold,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Form(
                            key: formKey,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: isEmailFocused || emailController.text.isNotEmpty
                                      ? 1
                                      : 0,
                                  color: isEmailFocused || emailController.text.isNotEmpty
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: isEmailFocused || emailController.text.isNotEmpty
                                    ? Colors.white
                                    : AppColors.textfieldFillColor.withOpacity(0.75),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      style: const TextStyle(color: Colors.black, fontSize: 17),
                                      focusNode: emailFocusNode,
                                      controller: emailController,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        prefixIcon: isEmailFocused || emailController.text.isNotEmpty
                                            ? null
                                            : const Icon(
                                          Icons.mail_outline,
                                          color: AppColors.primaryColor,
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
                                        errorStyle: const TextStyle(color: AppColors.darkColor),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                                      ),
                                      validator: (v) {
                                        if (v!.isEmpty) {
                                          return 'Enter a valid email!';
                                        } else if (!checkValidEmail(v)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: sendResendLink,
                            child: appButton(btnText: AppStrings.sendLink),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Back to login",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: robotoRegular,
                                    fontSize: 17,
                                    color: AppColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
