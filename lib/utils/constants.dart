import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:stasht/utils/app_colors.dart';

import 'assets_images.dart';

String userId = "";
String userName = "";
String memoryName = "";
String memoryId = "";
Uri? memoryLink;
 bool isRequestingPermission = false;
var userImage = ValueNotifier<String>("");
var userProfileColor = ValueNotifier<String>("");
var notificationCount = ValueNotifier<int>(0);
String userEmail = "";
String globalNotificationToken = "";
bool isSocailUser = false;
String changePassword = "Change Password";
String deleteAccount = "Delete Account";

bool fromShare = false;
bool expandShareMemory = false;
var sharedMemoryCount = ValueNotifier<int>(0);
//collections
String memoriesCollection = "memories";
String userCollection = "users";
String shareLinkCollection = "share_links";
String commentsCollection = "comments";
String notificationsCollection = "notifications";

// App bar Titles
String memoriesTitle = "Memories";
String photosTitle = "Photos";
String settingsTitle = "Settings";
String notifications = "Notifications";

bool checkValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

Future<void> sendPushMessage(var receiverFBToken, String payload) async {
  if (receiverFBToken == null || receiverFBToken == "") {
    debugPrint('Unable to send FCM message, no token exists.');
    return;
  }

  try {
    final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        // await http.post(Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAASUsV4Fk:APA91bHKYQ2XsHzBAhTmIvQU24DYB5K9GGY6457CkPIm0_-vkHTPCgfLpLBWrOL1Zgvb-4cnc0AXRgzFFzGmQXo32q3MeptLclkIhuwihgcDrnpP-DtCEQVly6F0MDg5JLj7V3FERL4p",
        },
        body: payload);

    if (response.statusCode == 200) {
      debugPrint('FCM request for device sent!');
      // If server returns an OK response, parse the JSON
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  } catch (e) {
    e.toString();
  }
}

openCircleProgressIndicator(BuildContext context){
  showDialog(
    barrierDismissible: false,
    context: context,

    builder: (context) =>Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            SizedBox(height: 5,),
            Text("Processing")
          ],
        ),
      ),
    ),
  );
}

getOutlineBorder() {
  return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.hintTextColor, width: 0.1));
}

getNormalTextStyle() {
  return const TextStyle(fontSize: 12.0, color: AppColors.greyColor);
}

appTextStyle({double?fz,Color?color, FontWeight?fw, double?height,String?fm}) {
  return  TextStyle(fontSize:fz?? 12.0, color:color?? Colors.black,
  height: height??0,fontWeight: fw??FontWeight.w400,fontFamily: fm);
}

appButton({String?btnText,bool fromOnboardScreen=false}){
  return Container(
    width: double.infinity,
    height: 69,
     alignment: Alignment.center,
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(16),
       color:fromOnboardScreen?Colors.white: AppColors.primaryColor,
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(.25),
           blurRadius: 4,
           offset: const Offset(0,4)

         )
       ]
     ),
    child: Text(btnText??"",
    style: appTextStyle(
     color:fromOnboardScreen?AppColors.primaryColor: Colors.white,
      fm: interBold,
      fz:18

    ),),
  );
}

goToMemories(bool fromShareLink) {

}

goToMemoriesAndClearAll() {

}



class CustomSnackbar {
  static OverlayEntry? _overlayEntry;

  static void showSnackbar(BuildContext context, String message, Function onTap) {
    if (_overlayEntry != null) return; // Prevent multiple snackbars

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // Adjust position based on keyboard
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onTap(); // Call the onTap function
                    hideSnackbar(); // Hide snackbar after action
                  },
                  child: const Text(
                    'Load More',
                    style: TextStyle(color: Color(0xFFD1A3FF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Automatically hide the snackbar after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      hideSnackbar();
    });
  }

  static void hideSnackbar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// Generate a random color
Color generateRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255,               // Alpha channel (255 for full opacity)
    random.nextInt(256), // Red value
    random.nextInt(256), // Green value
    random.nextInt(256), // Blue value
  );
}

// Convert Color to Hex string
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

convertColor({String? color}) {
print(color);
  Color userColor;
  if(color!=null && color!=""){

// Convert the hex string to an integer, specifying radix 16
    userColor = Color(int.parse("0XFF"+color));
  }
  else{
    userColor=AppColors.primaryColor;
  }
  return userColor;




}

convertToColor({String? color}) {
  Color userColor;
  if(color!=null){
    String hexColor = (color).replaceAll("#", "");

// Convert the hex string to an integer, specifying radix 16
    userColor = Color(int.parse(hexColor, radix: 16));
  }
  else{
    userColor=AppColors.primaryColor;
  }
  return userColor;



}

 final List<Map<String, dynamic>> driveListItem = [
    {"label": "All", "icon": null},
    {"label": "Camera Roll", "icon": null},
    {"label": "Drive", "icon": FontAwesomeIcons.googleDrive}, // Example icon
    {"label": "Facebook", "icon": FontAwesomeIcons.facebookF},
    {"label": "Photos", "icon": FontAwesomeIcons.fan}, // Example icon
// Example icon
  ];
  final List<Map<String, dynamic>> facebookListItem = [
    {"label": "All", "icon": null},
    {"label": "Camera Roll", "icon": null},
        {"label": "Facebook", "icon": FontAwesomeIcons.facebookF},

    {"label": "Drive", "icon": FontAwesomeIcons.googleDrive}, // Example icon
    {"label": "Photos", "icon": FontAwesomeIcons.fan}, // Example icon
// Example icon
  ];
  final List<Map<String, dynamic>> photoListItem = [
    {"label": "All", "icon": null},
    {"label": "Camera Roll", "icon": null},
    {"label": "Photos", "icon": FontAwesomeIcons.fan}, // Example icon

    {"label": "Drive", "icon": FontAwesomeIcons.googleDrive},
            {"label": "Facebook", "icon": FontAwesomeIcons.facebookF},
 // Example icon
// Example icon
  ];

