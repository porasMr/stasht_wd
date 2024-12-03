import 'package:flutter/material.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:stasht/utils/welcome_screen.dart';

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
    handleNavigation();
  }

  handleNavigation()  {
    if (PrefUtils.instance.getToken() != null) {
      print("dsfsfF");
      CommonWidgets.requestStoragePermission(((allAssets) {
        for (int i = 0; i < allAssets.length; i++) {
          photosList
              .add(PhotoModel(assetEntity: allAssets[i], selectedValue: false));
          if (allAssets.length - 1 == i) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PhotosView(photosList: photosList)));
          }
          // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
        }
      }));
    } else {
       Future.delayed(const Duration(milliseconds: 2500), () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>const WelcomeScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
