import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stasht/memory_detail_bottom_sheet.dart';
import 'package:stasht/modules/create_memory/create_memory.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/media_screen.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/memories_screen.dart';
import 'package:stasht/modules/profile/profile_screen.dart';

import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/pref_utils.dart';
import '../../bottom_bar_visibility_provider.dart';
import 'package:provider/provider.dart';

class PhotosView extends StatefulWidget {
  PhotosView(
      {super.key,
      required this.photosList,
      required this.isSkip,
      this.memoryId,
      this.imageLink,
      this.title,
      this.profileImge,
      this.userName});
  List<PhotoModel> photosList = [];
  bool isSkip;
  final String? memoryId;
  final String? title;
  final String? imageLink;
  final String? profileImge;
  final String? userName;

  @override
  State<PhotosView> createState() => _PhotosViewState();
}

class _PhotosViewState extends State<PhotosView> with WidgetsBindingObserver {
  int selectedIndex = 0; // Default selected index
  // final MediaController mediaController = Get.put(MediaController());

  UserModel model = UserModel();
  final GlobalKey<MemoriesScreenState> _scaffoldKey =
      GlobalKey<MemoriesScreenState>();
  List<Future<Uint8List?>> future = [];
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });

    for (int i = 0; i < widget.photosList.length; i++) {
      future.add(widget.photosList[i].assetEntity
          .thumbnailDataWithSize(ThumbnailSize(300, 300)));
      // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
    }

    if (widget.memoryId != null) {
      Future.delayed(Duration.zero, () {
        _showMemoryDetailsBottomSheet();
      });
    }

    super.initState();
  }

  void _showMemoryDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return MemoryDetailsBottomSheet(
            memoryId: widget.memoryId,
            title: widget.title,
            imageLink: widget.imageLink,
            userName: widget.userName,
            profileImage: widget.profileImge,
            userId: model.user?.id);
      },
    );
  }

  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      print("App is in background");
    } else if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.inactive) {
      print("App is inactive");
    } else if (state == AppLifecycleState.detached) {
      print("App is detached");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppbar(
        context,
        selectedIndex == 0 ? 'Memories' : "Media",
      ),
      bottomNavigationBar: Consumer<BottomBarVisibilityProvider>(
        builder: (context, bottomBarVisibilityProvider, child) {
          return bottomBarVisibilityProvider.isBottomBarVisible
              ? BottomAppBar(
                  height: 107,
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            selectedIndex = 0;
                            setState(() {});
                            if (_scaffoldKey.currentState!.mounted) {
                              _scaffoldKey.currentState!.refrehScreen();
                            }
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedIndex == 0
                                      ? AppColors.textfieldFillColor
                                      : Colors.white,
                                ),
                                child: Image.asset(home, height: 27),
                              ),
                              Text(
                                "MEMORIES",
                                style: appTextStyle(
                                  fz: 10,
                                  fw: FontWeight.w600,
                                  fm: interMedium,
                                  height: 20 / 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            selectedIndex = 1;
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedIndex == 1
                                      ? AppColors.textfieldFillColor
                                      : Colors.white,
                                ),
                                child: Image.asset(
                                  "assets/images/image.png",
                                  height: 32,
                                ),
                              ),
                              Text(
                                "MEDIA",
                                style: appTextStyle(
                                  fz: 10,
                                  fw: FontWeight.w600,
                                  fm: interMedium,
                                  height: 20 / 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox.shrink();
        },
      ),
      floatingActionButton: Consumer<BottomBarVisibilityProvider>(
        builder: (context, bottomBarVisibilityProvider, child) {
          return bottomBarVisibilityProvider.isBottomBarVisible
              ? Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      right: 0,
                      left: 0,
                      child: Visibility(
                        visible: MediaQuery.of(context).viewInsets.bottom == 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CreateMemoryScreen(
                                      photosList: widget.photosList,
                                      future: future,
                                      isBack: true,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                    _scaffoldKey.currentState!.refrehScreen();
                                    setState(() {});
                                  }
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/fabIcon.png",
                                    height: 67,
                                  ),
                                  Image.asset(
                                    "assets/images/addFabIcon.png",
                                    height: 29,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "ADD",
                              style: appTextStyle(
                                fz: 14,
                                fm: interBold,
                                height: 29 / 14,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: selectedIndex == 0
          ? MemoriesScreen(
              key: _scaffoldKey,
              photosList: widget.photosList,
              isSkip: () {},
            )
          : selectedIndex == 1
              ? MediaScreen(
                  future: future,
                  photosList: widget.photosList,
                  isFromSignUp: false,
                )
              : Container(),
    );
  }

  PreferredSizeWidget commonAppbar(
    BuildContext context,
    String title,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Expanded(
            child: Container(
              height: 30,
              margin: EdgeInsets.only(left: 0),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                    height: 28 / 22,
                    color: AppColors.black,
                    fontFamily: robotoRegular,
                    fontSize: 22),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: title == notifications
                            ? const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(eclipseImage)))
                            : null,
                        width: 50,
                        height: 50,
                        child: SvgPicture.asset("assets/images/bell.svg",
                            height: 22,
                            width: 21,
                            fit: BoxFit.scaleDown,
                            color: AppColors.black),
                      ),
                      Positioned(
                        right: 17,
                        top: 7,
                        child: notificationCount.value > 0
                            ? Container(
                                width: 18.0,
                                height: 18.0,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    color: Colors.red),
                                child: Text(
                                  '${notificationCount.value}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Container(),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
                // width: 17,
                ),
            if (model.user != null)
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const ProfileScreen())).then((value) {
PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: convertColor(color: userProfileColor.value) ??
                          AppColors.primaryColor,
                      border: Border.all(color: Colors.grey, width: 0.3)),
                  height: 46,
                  width: 46,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: model.user!.profileImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: model.user!.profileImage!,
                            fit: BoxFit.cover,
                            height: 46,
                            width: 46,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress))
                        : Text(
                            model.user!.name![0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: robotoRegular),
                          ),
                  ),
                ),
              ),
            const SizedBox(
              width: 19,
            ),
          ],
        )
      ],
    );
  }
}
