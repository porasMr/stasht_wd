import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/constants.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final formkeyPassword = GlobalKey<FormState>();
    bool isObscureNew = true;
  bool isObscureOld = false;
    bool isObscureConfirm = true;

 var oldPasswordcontroller = TextEditingController();
  var newPasswordcontroller = TextEditingController();
  var confirmPasswordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
             Navigator.pop(context);
            },
            icon: const Icon(
              Icons.chevron_left_sharp,
              color: Colors.black,
            )),
        centerTitle: false,
        title: Text(
          changePassword,
          style:
              const TextStyle(fontSize: 16.0, color: AppColors.primaryColor),
        ),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formkeyPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             TextFormField(
                  controller: oldPasswordcontroller,
                  decoration: InputDecoration(
                      hintText: 'Current Password',
                      labelText: 'Current Password',
                      hintStyle: getNormalTextStyle(),
                      labelStyle: getNormalTextStyle(),
                      border: getOutlineBorder(),
                      enabledBorder: getOutlineBorder(),
                      focusedBorder: getOutlineBorder(),
                      fillColor: AppColors.hintTextColor,
                      filled: true,
                      suffixIcon: IconButton(
                          onPressed: () {
                          isObscureOld =
                                !isObscureOld;
                          },
                          icon: Icon(
                           isObscureOld
                                ? Icons.visibility_outlined
                                : Icons.visibility_off,
                            size: 15,
                            color: AppColors.hintPrimaryColor,
                          ))),
                  validator: (currentPassword) {
                    if (currentPassword!.isEmpty) {
                      return 'Please enter current password';
                    } else if (currentPassword.length < 6) {
                      return 'Please enter at least 6 characters';
                    }
                    return null;
                  },
                  obscureText:isObscureOld,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                ),
              
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  controller: newPasswordcontroller,
                  decoration: InputDecoration(
                      hintText: 'New Password',
                      labelText: 'New Password',
                      hintStyle: getNormalTextStyle(),
                      labelStyle: getNormalTextStyle(),
                      border: getOutlineBorder(),
                      enabledBorder: getOutlineBorder(),
                      focusedBorder: getOutlineBorder(),
                      fillColor: AppColors.hintTextColor,
                      filled: true,
                      suffixIcon: IconButton(
                          onPressed: () {
                            isObscureNew =
                                isObscureNew;
                          },
                          icon: Icon(
                            isObscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off,
                            size: 15,
                            color: AppColors.hintPrimaryColor,
                          ))),
                  validator: (newPassword) {
                    if (newPassword!.isEmpty) {
                      return 'Please enter new password';
                    } else if (newPassword.length < 6) {
                      return 'Please enter at least 6 characters';
                    } else if (newPassword ==
                       oldPasswordcontroller.text) {
                      return 'New password should be different from old current password';
                    }
                    return null;
                  },
                  obscureText: isObscureNew,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                ),
              
              const SizedBox(
                height: 10,
              ),
             TextFormField(
                  controller:confirmPasswordcontroller,
                  decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      labelText: 'Confirm Password',
                      hintStyle: getNormalTextStyle(),
                      labelStyle: getNormalTextStyle(),
                      border: getOutlineBorder(),
                      enabledBorder: getOutlineBorder(),
                      focusedBorder: getOutlineBorder(),
                      fillColor: AppColors.hintTextColor,
                      filled: true,
                      suffixIcon: IconButton(
                          onPressed: () {
                            isObscureConfirm =
                                !isObscureConfirm;
                          },
                          icon: Icon(
                           isObscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off,
                            size: 15,
                            color: AppColors.hintPrimaryColor,
                          ))),
                  validator: (confirmPassword) {
                    if (confirmPassword!.isEmpty) {
                      return 'Please enter confirm password';
                    } else if (confirmPassword !=
                       newPasswordcontroller.text) {
                      return 'Password mismatch';
                    }
                    return null;
                  },
                  obscureText: isObscureConfirm,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                ),
              
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Min 6 characters',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ),
              MaterialButton(
                onPressed: () {
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                color: AppColors.primaryColor,
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(changePassword,
                      style: const TextStyle(
                          fontSize: 15.0, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
