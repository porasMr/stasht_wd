import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:stasht/utils/welcome_screen.dart';

import '../../../main.dart';
import '../../memories/memories_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<PhotoModel> photosList = [];

  @override
  void initState() {
    super.initState();
   CommonWidgets.initPlatformState();
        _initDynamicLinks();

    handleNavigation();
  }

  Future<void> _initDynamicLinks() async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    debugPrint("Dyanmic Link is $dynamicLinks");
    final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    print("Data is $data");
    _handleDynamicLink(data);
    dynamicLinks.onLink.listen((PendingDynamicLinkData dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    }).onError((error) {
      debugPrint('onLink error: $error');
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData? data) {
    try {
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        debugPrint("Received deep link: $deepLink");

        String fixedLink = deepLink.toString();
        if (!fixedLink.contains('?')) {
          fixedLink = fixedLink.replaceFirst('/memory_id', '?memory_id');
        }

        final Uri fixedUri = Uri.parse(fixedLink);

        String? memoryId = fixedUri.queryParameters['memory_id'];
        String? title = fixedUri.queryParameters['title'];
        String? imageLink = fixedUri.queryParameters['image_link'];
        String? userName = fixedUri.queryParameters['user_name'];
        String? profileImage = fixedUri.queryParameters['profile_image'];

        if (memoryId != null &&
            title != null &&
            imageLink != null &&
            userName != null) {
          debugPrint(
              "Received memoryId: $memoryId, title: $title, imageLink: $imageLink, profileImage: $profileImage,userName: $userName");

          String decodedImageLink = Uri.decodeComponent(imageLink);
          debugPrint("Decoded imageLink: $decodedImageLink");
          PrefUtils.instance.memoryId(memoryId);
                    PrefUtils.instance.setTtile(title);
                                        PrefUtils.instance.imageLink(imageLink);
                                        PrefUtils.instance.profileImage(profileImage!);
                                        PrefUtils.instance.userName(userName);


          

          // if (MyApp.navigatorKey.currentState != null) {
          //   MyApp.navigatorKey.currentState?.pushReplacement(
          //     MaterialPageRoute(
          //       builder: (context) => PhotosView(
          //         memoryId: memoryId,
          //         title: title,
          //         imageLink: decodedImageLink,
          //         photosList: photosList,
          //         profileImge: profileImage,
          //         userName: userName,
          //         isSkip: false,
          //       ),
          //     ),
          //   );
          // }
        } else {
          debugPrint("Error: Missing parameters in the deep link");
        }
      } else {
        debugPrint("Error: No deep link found");
      }
    } catch (error) {
      debugPrint("Error handling dynamic link: $error");
    }
  }

  handleNavigation() {
    if (PrefUtils.instance.getToken() != null) {
      print("dsfsfF");
      CommonWidgets.requestStoragePermission(((allAssets) {
        for (int i = 0; i < allAssets.length; i++) {
          photosList
              .add(PhotoModel(assetEntity: allAssets[i], selectedValue: false, isEditmemory: false));
          if (allAssets.length - 1 == i) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PhotosView(photosList: photosList,isSkip: false,)));
          }
          // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
        }
      }));
    } else {
      Future.delayed(const Duration(milliseconds: 2500), () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const WelcomeScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: AppColors.primaryColor,
      ),
    );
    return Scaffold(
        key: const Key('key-1'),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    preLoader,
                  ))),
        ));
  }

  


}
