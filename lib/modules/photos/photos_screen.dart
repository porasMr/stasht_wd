import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stasht/memory_detail_bottom_sheet.dart';
import 'package:stasht/modules/create_memory/create_memory_copy.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/media_screen.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/memories_screen.dart';
import 'package:stasht/modules/memory_details/memory_lane.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/modules/notifications/notifications.dart';
import 'package:stasht/modules/profile/profile_screen.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';

import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
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

class _PhotosViewState extends State<PhotosView>
    with WidgetsBindingObserver
    implements ApiCallback {
  int selectedIndex = 0; // Default selected index
  // final MediaController mediaController = Get.put(MediaController());

  UserModel model = UserModel();
  final GlobalKey<MemoriesScreenState> _scaffoldKey =
      GlobalKey<MemoriesScreenState>();
  List<Future<Uint8List?>> future = [];
  final ScrollController _scrollController = ScrollController();
  int categorySelectedIndex = 0;
  int notificationCount=0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    ApiCall.getNotifications(api: ApiUrl.notificationCount, callack: this);
    CommonWidgets.initPlatformState(returnBack: getMemoryIdFromNotification);
    _initDynamicLinks();
    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });

    for (int i = 0; i < widget.photosList.length; i++) {
      future.add(widget.photosList[i].assetEntity
          .thumbnailDataWithSize(ThumbnailSize(300, 300)));
      // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
    }

    if (PrefUtils.instance.getMemoryId() != null &&
        PrefUtils.instance.getMemoryId()!.isNotEmpty) {
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
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24), color: Colors.white),
          child: MemoryDetailsBottomSheet(
            memoryId: PrefUtils.instance.getMemoryId(),
            title: PrefUtils.instance.getMemoryTitle(),
            imageLink: PrefUtils.instance.getMemoryImageLink(),
            userName: PrefUtils.instance.getMemoryUserName(),
            profileImage: PrefUtils.instance.getMemoryProfileImage(),
            userId: model.user?.id,
            callBak: () {
              if (_scaffoldKey.currentState!.mounted) {
                _scaffoldKey.currentState!.refrehScreen();
                PrefUtils.instance.memoryId("");
                PrefUtils.instance.setTtile("");
                PrefUtils.instance.imageLink("");
                PrefUtils.instance.profileImage("");
                PrefUtils.instance.userName("");
              }
            },
          ),
        );
      },
    );
  }

  void getMemoryIdFromNotification(memoryId) {
//CommonWidgets.successDialog(context, memoryId);
    EasyLoading.show();
    ApiCall.memoryDetails(
        api: ApiUrl.memoryDetail, id: memoryId, page: "", callack: this);
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                                        CreateMemoryCopyScreen(
                                      photosList: widget.photosList,
                                      future: future,
                                      isBack: true,
                                      fromMediaScreen: false,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                    _scaffoldKey.currentState!.refrehScreen();
                                    categorySelectedIndex = value;
                                    setState(() {});
                                  }
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/fabIcon.png",
                                    height: 90,
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
              categorySelectedIndex: categorySelectedIndex,
            )
          : selectedIndex == 1
              ? MediaScreen(
                  future: future,
                  photosList: widget.photosList,
                  isFromSignUp: false,
                  type: "")
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NotificationScreen(
                                  future: future,
                                  photosList: widget.photosList,
                                ))).then((value) {
                                      ApiCall.getNotifications(api: ApiUrl.notificationCount, callack: this);

                      if (_scaffoldKey.currentState!.mounted) {
                        _scaffoldKey.currentState!.refrehScreen();
                      }
                    });
                  },
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
                        child: notificationCount > 0
                            ? Container(
                                width: 20.0,
                                height: 20.0,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    color: AppColors.redBgColor),
                                child: Text(
                                  '${notificationCount}',
                                  style: const TextStyle(
                                      fontSize: 9, color: Colors.white),
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
                    setState(() {});
                    if (_scaffoldKey.currentState!.mounted) {
                      _scaffoldKey.currentState!.refrehScreen();
                    }
                    PrefUtils.instance.getUserFromPrefs().then((value) {
                      model = value!;
                      setState(() {});
                    });
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: convertColor(color: model.user!.profileColor),
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

          if (PrefUtils.instance.getMemoryId() != null &&
              PrefUtils.instance.getMemoryId()!.isNotEmpty) {
            Future.delayed(Duration.zero, () {
              _showMemoryDetailsBottomSheet();
            });
          }

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

  @override
  void onFailure(String message) {
    EasyLoading.dismiss();
  }

  @override
  void onSuccess(String data, String apiType) {
    EasyLoading.dismiss();
    if (apiType == ApiUrl.memoryDetail) {
      MemoryDetailsModel details =
          MemoryDetailsModel.fromJson(json.decode(data));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MemoryDetailPage(
                    memoryTtile: details.data![0].memory!.title!,
                    memoryId: details.data![0].memory!.id.toString(),
                    userName: details.data![0].user!.name!,
                    sharedCount: "0",
                    email: details.data![0].user!.id.toString(),
                    imageLink: details.data![0].memory!.lastUpdateImg!,
                    imageCaptions: details.data![0].user!.profileImage,
                    pubLished: details.data![0].memory!.published.toString(),
                    future: future,
                    photosList: widget.photosList,
                    subId: details.data![0].memory!.subCategoryId.toString(),
                    catId: details.data![0].memory!.categoryId.toString(),
                    selectionType: "Personal",
                  ))).then((value) {
        if (_scaffoldKey.currentState!.mounted) {
          _scaffoldKey.currentState!.refrehScreen();
        }
      });
    }else{
      notificationCount=json.decode(data)['data'];
      setState(() {
        
      });
    }
  }

  @override
  void tokenExpired(String message) {
    // TODO: implement tokenExpired
  }
}
