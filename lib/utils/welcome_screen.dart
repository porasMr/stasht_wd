import 'package:flutter/material.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_in.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_up.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration:const  BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.pinkColor,
            AppColors.primaryColor
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight)
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.asset(
              "assets/images/gradient.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  Image.asset("assets/images/Stasht_whiteLogo.png"),
                  const SizedBox(
                    height: 85,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Connect all your \nmemories.",
                      style: TextStyle(
                          fontFamily: robotoBold,
                          fontSize: 30,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Share with friends, family\nor colleagues. Seamlessly\nand safely.",
                      style: TextStyle(
                          fontFamily: robotoRegular,
                          fontSize: 22,
                          height: 30.6 / 22,
                          color: Colors.white),
                    ),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: appButton(
                            btnText: AppStrings.signUpBtnText,
                            fromOnboardScreen: true),
                        onTap: () {
                          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>const Signup()));
                        },
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>const SignIn()));
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                    text: TextSpan(
                                        text: AppStrings.alreadyHaveAccount,
                                        style: appTextStyle(
                                          color: Colors.white,
                                          fm: robotoRegular,
                                          fz: 17,
                                        ),
                                        children: [
                                      TextSpan(
                                        text: AppStrings.signInBtnText,
                                        style: appTextStyle(
                                            fm: robotoBold,
                                            fz: 17,
                                            color: Colors.white),
                                      )
                                    ]))),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      )
                    ],
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
