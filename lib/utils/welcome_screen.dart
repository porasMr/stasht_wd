import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_in.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_up.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showAllText = true;
  int _logoIndex = 0;
  late Timer _timer;

  final List<String> _logoImages = [
    "assets/images/instagram.png",
    "assets/images/apple.png",
    "assets/images/google.png",
    "assets/images/facebok.png"
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _startIconLoop();
    });
  }

  void _startIconLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_showAllText) {
            _showAllText = false;
            _logoIndex = 0;
          } else if (_logoIndex < _logoImages.length - 1) {
            _logoIndex++;
          } else {
            _showAllText = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.pinkColor, AppColors.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                  const SizedBox(height: 200),
                  Image.asset("assets/images/Stasht_whiteLogo.png"),
                  const SizedBox(height: 85),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Connect ",
                              style: TextStyle(
                                fontFamily: robotoBold,
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_showAllText) ...[
                              const Text(
                                "all",
                                style: TextStyle(
                                  fontFamily: robotoBold,
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ] else ...[
                              Image.asset(
                                _logoImages[_logoIndex],
                                width: 28,
                                color: Colors.white,
                              ),
                            ],
                            const Text(
                              " your",
                              style: TextStyle(
                                fontFamily: robotoBold,
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "memories.",
                          style: TextStyle(
                            fontFamily: robotoBold,
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Share with friends, family\nor colleagues. Seamlessly\nand safely.",
                      style: TextStyle(
                        fontFamily: robotoRegular,
                        fontSize: 22,
                        height: 30.6 / 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: appButton(
                            btnText: AppStrings.signUpBtnText,
                            fromOnboardScreen: true,
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                const Signup(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                    const SignIn(),
                                  ),
                                );
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
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
