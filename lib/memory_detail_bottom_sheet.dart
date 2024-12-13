import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/memory_details/model/add_collabarator_response_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/pref_utils.dart';

import 'network/api_url.dart';

class MemoryDetailsBottomSheet extends StatefulWidget {
  final String? memoryId;
  final String? title;
  final String? imageLink;
  final String? profileImage;
  final String? userName;
  var userId;
  VoidCallback? callBak;

  MemoryDetailsBottomSheet(
      {super.key,
      this.memoryId,
      this.title,
      this.imageLink,
      this.profileImage,
      this.userName,
      this.userId,this.callBak});

  @override
  _MemoryDetailsBottomSheetState createState() =>
      _MemoryDetailsBottomSheetState();
}

class _MemoryDetailsBottomSheetState extends State<MemoryDetailsBottomSheet>
    implements ApiCallback {
  bool isChecked = false;
  AddCollabaratorResponseModel addCollabaratorResponseModel =
      AddCollabaratorResponseModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: const Text('Finish', style: TextStyle(fontSize: 18))
                    .paddingOnly(right: 6),
                onTap: () {
                         widget.callBak!();

                  Navigator.pop(context);
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          const Center(
              child: Text("You've been invited to share",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          const SizedBox(height: 10),
          if (widget.imageLink != null)
            Container(
              width: MediaQuery.of(context).size.width,
              height: 103,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(18),
                color: AppColors.invitePopupItemColor,
              ),
              child: Row(
                children: [
                  Container(
                    width: 77,
                    height: 71,
                    margin: const EdgeInsets.only(
                        left: 18, right: 8, bottom: 8, top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://stasht-data.s3.us-east-2.amazonaws.com/images/${widget.imageLink}",
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Profile Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: CachedNetworkImage(
                        imageUrl: "${widget.profileImage}",
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.account_circle, size: 42),
                        fit: BoxFit.cover,
                        width: 42,
                        height: 42),
                  ).paddingOnly(left: 12, top: 8, right: 8, bottom: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.userName}",
                        style: const TextStyle(fontSize: 14),
                      ).paddingOnly(left: 10),
                      Text(
                        "${widget.title}",
                        style: const TextStyle(fontSize: 18),
                      ).paddingOnly(left: 10),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isChecked = !isChecked;
                      });
                      if (isChecked == true) {
                        debugPrint("UserId is ${widget.userId}");
                        ApiCall.addCollabarator(api: ApiUrl.addCollaborator, memoryID:  "${widget.memoryId}", userId: "${widget.userId}", callback: this);
                        
                      }
                    },
                    child: SvgPicture.asset(
                      isChecked
                          ? "assets/images/frameCheckBoxes.svg"
                          : "assets/images/Checkboxes.svg",
                      height: 26,
                      width: 25,
                      fit: BoxFit.scaleDown,
                    ).paddingOnly(right: 20),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void onFailure(String message) {
    CommonWidgets.errorDialog(context, message);
  }

  @override
  void onSuccess(String data, String apiType) {
    debugPrint("ApiType is $apiType");
    if (apiType == ApiUrl.addCollaborator) {
      final responseJson = json.decode(data);
      try {
       
          CommonWidgets.successDialog(
              context, "${responseJson['message']}");
       widget.callBak!();
        Navigator.pop(context);
        setState(() {});
      } catch (e) {
        debugPrint("Exception is $e");
      }
    }

  }

  @override
  void tokenExpired(String message) {}
}
