import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stasht/bottom_bar_visibility_provider.dart';
import 'package:stasht/modules/invite_collaborator/invite_collaborator_screen.dart';
import 'package:stasht/modules/media/image_grid.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stasht/utils/file_path.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:stasht/utils/progress_dialog.dart';
import '../create_memory/model/sub_category_model.dart';
import 'model/phot_mdoel.dart';

// ignore: must_be_immutable

class MediaScreen extends StatefulWidget {
  MediaScreen(
      {super.key,
      required this.future,
      required this.photosList,
      required this.isFromSignUp});
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];
  List<PhotoModel> isFrom = [];
  bool isFromSignUp;

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> implements ApiCallback {
  List<String> tabListItem = [
    "All",
    "Camera Roll",
    "Facebook",
    "Instagram",
    "Drive"
  ];
  String selectedTab = "";

  int selectedIndex = 0;
  CategoryModel categoryModel = CategoryModel();
  SubCategorymodel subCategoryModel = SubCategorymodel();
  TextEditingController titleController = TextEditingController();
  TextEditingController labelController = TextEditingController();

  final FocusNode titleFocusNode = FocusNode();
  GlobalKey<_MediaScreenState> _titleWidgetKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isExpandedDrop = false;
  bool isLableAvailable = false;

  CategoryMemoryModelWithoutPage categoryMemoryModelWithoutPage =
      CategoryMemoryModelWithoutPage();
  bool isTitleFocused = false;
  bool addLable = false;
  bool isLabelTexFormFeildShow = false;
  String selectedMemoryId = '';

  //----------bottom sheet variable------------

  double _bottomSheetHeight = 0;
  double initialChildSize = 0.47;
  List<String> thumbnails = []; // Cache for thumbnail data
  double _progress = 0.0;
  int _currentIndex = 1;
  List<PhotoDetailModel> driveModel = [];
  List<PhotoDetailModel> fbModel = [];
  List<PhotoDetailModel> instaModel = [];

  List<PhotoDetailModel> photoLinks = [];
  int uploadCount = 0;
  var progressbarValue = 0.0;
  bool isBottomSheetOpen = false;
  ValueNotifier<int> selectedCountNotifier = ValueNotifier<int>(0);

  double radians(double degree) {
    return ((degree * 180) / pi);
  }

  void swipe(moveEvent) {
    double angle = radians(moveEvent.delta.direction);
    if (angle >= -45 && angle <= 45) {
      debugPrint("Swipe Right");
    } else if (angle >= 45 && angle <= 135) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusManager.instance.primaryFocus?.unfocus();
          titleController.clear();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            debugPrint("No routes to pop");
          }

          isBottomSheetOpen = false;
          Provider.of<BottomBarVisibilityProvider>(
            context,
            listen: false,
          ).showBottomBar();
          debugPrint("Swipe Down");
        }
      });
    } else if (angle <= -45 && angle >= -135) {
      debugPrint("Swipe Up");
    } else {
      debugPrint("Swipe Left");
    }
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    PrefUtils.instance.getDrivePrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      driveModel = value;
    });
    PrefUtils.instance.getFacebookPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      fbModel = value;
    });
    PrefUtils.instance.getInstaPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      instaModel = value;
    });
    deselectAll();
    ApiCall.category(api: ApiUrl.categories, callack: this);
  }

  void deselectAll() {
    selectedMemoryId = "";
    for (var photoList in widget.photosList) {
      photoList.selectedValue = false;
    }
    if (fbModel.isNotEmpty) {
      for (var photoList in fbModel) {
        photoList.isSelected = false;
      }
    }
    if (driveModel.isNotEmpty) {
      for (var photoList in driveModel) {
        photoList.isSelected = false;
      }
    }
    if (instaModel.isNotEmpty) {
      for (var photoList in instaModel) {
        photoList.isSelected = false;
      }
    }
  }

  Future<XFile?> _compressAsset(AssetEntity asset) async {
    final file = await asset.originFile;
    if (file == null) return null;

    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${asset.title}_compressed.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, // Input file path
      targetPath, // Output file path
      quality: 50, // Compression quality (0-100)
    );

    return compressedFile;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.isFromSignUp
          ? AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: const IgnorePointer(),
              leadingWidth: 0,
              actions: [
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => PhotosView(
                                    photosList: widget.photosList,
                                    isSkip: false,
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        AppStrings.skip,
                        style: appTextStyle(
                            fz: 17,
                            fm: interMedium,
                            color: AppColors.primaryColor),
                      ),
                    ))
              ],
              title: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Photos",
                    style: appTextStyle(
                        fz: 22,
                        height: 28 / 22,
                        fm: robotoRegular,
                        color: Colors.black),
                  ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: tab(),
          ),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: selectedtabView(context))),
        ],
      ),
    );
  }

  selectedtabView(BuildContext context) {
    if (selectedIndex == 0) {
      debugPrint("Index is 0");
      return CommonWidgets.albumView(
          widget.future, widget.photosList, viewRefersh,
          selectedCountNotifier: selectedCountNotifier);
    } else if (selectedIndex == 1) {
      return CommonWidgets.albumView(
          widget.future, widget.photosList, viewRefersh,
          selectedCountNotifier: selectedCountNotifier);
    } else if (selectedIndex == 2) {
      if (fbModel.isEmpty) {
        return CommonWidgets.fbView(context, getFacebbokPhoto);
      } else {
        return CommonWidgets.fbPhtotView(fbModel, viewRefersh,
            selectedCountNotifier: selectedCountNotifier);
      }
    } else if (selectedIndex == 3) {
      if (instaModel.isEmpty) {
        return CommonWidgets.instaView(context, getInstaView);
      } else {
        return CommonWidgets.instaPhtotView(instaModel, viewRefersh,
            selectedCountNotifier: selectedCountNotifier);
      }
    } else if (selectedIndex == 4) {
      if (driveModel.isEmpty) {
        return CommonWidgets.driveView(context, getDriveView);
      } else {
        return CommonWidgets.drivePhtotView(driveModel, viewRefersh,
            selectedCountNotifier: selectedCountNotifier);
      }
    }
  }

  getFacebbokPhoto(AccessToken token) {
    fetchFacebookPhotos(token);
  }

  getInstaView(String token) {
    instaRequestForAccessToken(token);
  }

  getDriveView(GoogleSignIn v1) {
    fetchPhotosFromDrive(v1, context);
  }

  viewRefersh() {
    debugPrint("Refresh Function Count");
    setState(() {});
    if(widget.isFromSignUp){
      if(categoryMemoryModelWithoutPage
          .data!=null) {
        openAddPillBottomSheetForSignUp(context);
      }
    }else{
      if(categoryMemoryModelWithoutPage
          .data!=null) {
        openAddPillBottomSheet(context);
      }

    }
  }

  //------------Tab function---------------
  tab() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabListItem.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              selectedTab = tabListItem[index];
              selectedIndex = index;
              setState(() {});
            },
            child: Container(
              height: 35,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: selectedIndex != -1 && selectedIndex == index
                      ? AppColors.black
                      : AppColors.selectedTabColor),
              child: Text(
                tabListItem[index],
                style: appTextStyle(
                    fm: interMedium,
                    height: 27 / 14,
                    fz: 14,
                    color: selectedIndex != -1 && selectedIndex == index
                        ? Colors.white
                        : AppColors.black),
              ),
            ),
          );
        },
      ),
    );
  }

  tabTitle({String? title, int? index}) {
    return Container(
      height: 35,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selectedIndex != -1 && selectedIndex == index
              ? AppColors.black
              : AppColors.selectedTabColor),
      child: Text(
        title ?? "",
        style: appTextStyle(
            fm: interMedium,
            height: 27 / 14,
            fz: 14,
            color: selectedIndex != -1 && selectedIndex == index
                ? Colors.white
                : AppColors.black),
      ),
    );
  }

  //---------------Selected tab view-----------

  @override
  void onFailure(String message) {
    EasyLoading.dismiss();

    CommonWidgets.errorDialog(context, message);
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);
    if (apiType == ApiUrl.categories) {
      if (widget.isFromSignUp) {
        showFirstMemoryDialog(context);
      }
      debugPrint("Data Come now..");
      categoryModel = CategoryModel.fromJson(jsonDecode(data));
      categoryModel.categories![0].isSelected = true;

      ApiCall.memoryByCategory(
          api: ApiUrl.memoryByCategory,
          id: categoryModel.categories![0].id.toString(),
          sub_category_id: '',
          type: 'no_page',
          page: '1',
          callack: this);
    } else if (apiType == ApiUrl.memoryByCategory) {
      categoryMemoryModelWithoutPage =
          CategoryMemoryModelWithoutPage.fromJson(jsonDecode(data));

      setState(() {
        if (categoryMemoryModelWithoutPage.subCategories!.isEmpty) {
          addLable = true;
        }
      });
    } else if (apiType == ApiUrl.uploadImageTomemory) {
      String count = data.split("=")[1];
      print(json.decode(data.split("=")[0])['file'].toString());

      print(int.parse(count));
      uploadCount += 1;
      progressbarValue = uploadCount / countSelectedPhotos();
      // Ensure progress doesn't exceed 1.0
      if (progressbarValue > 1.0) {
        progressbarValue = 1.0;
      }

      progressNotifier.value = progressbarValue;
      print(progressbarValue);
      createModel.images![int.parse(count)].link =
          json.decode(data.split("=")[0])['file'].toString();

      if (valueNotEmpty()) {
        clossProgressDialog('');
        if (createModel.memoryId != null) {
          ApiCall.createMemory(
              api: ApiUrl.updateMemory, model: createModel, callack: this);
        } else {
          ApiCall.createMemory(
              api: ApiUrl.createMemory,
              model: createModel,
              callack: this); // Dismiss the dialog
        }
      }
    } else if (apiType == ApiUrl.createMemory) {
      deselectAll();
      titleController.text = "";
      labelController.text = "";

      CommonWidgets.successDialog(context, json.decode(data)['message']);
      if (widget.isFromSignUp) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => InviteCollaborator(
                      title: json.decode(data)['memory']['title'].toString(),
                      memoryId: json.decode(data)['memory']['id'].toString(),
                      image: json
                          .decode(data)['memory']['last_update_img']
                          .toString(),
                      photosList: widget.photosList,
                    )));
      }
      setState(() {});
    } else if (apiType == ApiUrl.updateMemory) {
      deselectAll();
      titleController.text = "";
      labelController.text = "";

      CommonWidgets.successDialog(context, json.decode(data)['message']);
      setState(() {});
    } else if (apiType == ApiUrl.syncAccount) {
      setState(() {});
    }else if(apiType==ApiUrl.createSubCategory){
      SubCategoryResModel subCategoryResModel =
      SubCategoryResModel.fromJson(json.decode(data));
      uploadData(selectedCategoryId(), subCategoryResModel.categories!.id.toString());
    }
  }

  bool valueNotEmpty() {
    bool allNonEmpty =
        createModel.images!.every((element) => element.link!.isNotEmpty);
    return allNonEmpty;
  }


  @override
  void tokenExpired(String message) {}

  //-----------------bottom sheet-------------------------
  int countSelectedPhotos() {
    debugPrint("This Invoked Count");

    return widget.photosList.where((photo) => photo.selectedValue).length;
  }

  int allSelectedPhotos() {
    int value = 0;
    value =
        value + widget.photosList.where((photo) => photo.selectedValue).length;
    value = value + fbModel.where((photo) => photo.isSelected).length;
    value = value + instaModel.where((photo) => photo.isSelected).length;
    value = value + driveModel.where((photo) => photo.isSelected).length;

    return value;
  }

  String selectedCategory() {
    if (categoryModel.categories != null) {
      for (var category in categoryModel.categories!) {
        if (category.isSelected == true) {
          return category.name ?? '';
        }
      }
    }
    return '';
  }

  String selectedCategoryId() {
    for (var category in categoryModel.categories!) {
      if (category.isSelected) {
        return category.id.toString();
      }
    }
    return '';
  }

  String selectedSubCategory() {
    for (var category in categoryMemoryModelWithoutPage.subCategories!) {
      if (category.isselected) {
        return category.id.toString();
      }
    }
    return '';
  }



/*==============================================================================================================================================================================================*/

  void openAddPillBottomSheet(BuildContext context) {
    if (isBottomSheetOpen) return;

    isBottomSheetOpen = true;
    Provider.of<BottomBarVisibilityProvider>(context, listen: false)
        .hideBottomBar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final titleContext = _titleWidgetKey.currentContext;
      if (titleContext != null) {
        FocusScope.of(titleContext).requestFocus(titleFocusNode);
      }
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      bool isReadOnly = false;
      _scaffoldKey.currentState!.showBottomSheet(
        (BuildContext context) {
          return SafeArea(
            top: true,
            bottom: false,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                debugPrint("Update on bottomSheet");
                return SingleChildScrollView(
                  child: Container(
                      height:MediaQuery.of(context).size.height/2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 48,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              child: const Icon(Icons.close),
                                              onTap: () {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                titleController.clear();
                                                Navigator.pop(context);
                                                isBottomSheetOpen = false;
                                                Provider.of<BottomBarVisibilityProvider>(
                                                        context,
                                                        listen: false)
                                                    .showBottomBar();
                                              },
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              AppStrings.addAMemory,
                                              style: appTextStyle(
                                                fm: robotoBold,
                                                fz: 20,
                                                color: Colors.black,
                                                height: 25 / 20,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            ValueListenableBuilder<int>(
                                              valueListenable:
                                                  selectedCountNotifier,
                                              builder: (context, selectedCount,
                                                  child) {
                                                return Text(
                                                  "($selectedCount)",
                                                  style: appTextStyle(
                                                    fm: robotoBold,
                                                    fz: 20,
                                                    color: Colors.black,
                                                    height: 25 / 20,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (titleController.text.isEmpty) {
                                              CommonWidgets.errorDialog(context,
                                                  "Enter memory title");

                                              //Get.snackbar("Error", "Enter memory title", colorText: AppColors.redColor);
                                            } else if (allSelectedPhotos() ==
                                                0) {
                                              CommonWidgets.errorDialog(context,
                                                  "Please select photo");
                                            } else {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              Navigator.pop(context);
                                              isBottomSheetOpen = false;
                                              uploadCount = 1;
                                              progressbarValue = 0.0;
                                              if (labelController
                                                  .text.isEmpty) {
                                                isLabelTexFormFeildShow = false;
                                                uploadData(
                                                    selectedCategoryId(), selectedSubCategory());
                                              } else {
                                                isLabelTexFormFeildShow = false;

                                                ApiCall.createSubCategory(
                                                    api: ApiUrl
                                                        .createSubCategory,
                                                    name: labelController.text,
                                                    id: selectedCategoryId(),
                                                    callack: this);
                                              }
                                              Provider.of<BottomBarVisibilityProvider>(
                                                      context,
                                                      listen: false)
                                                  .showBottomBar();
                                            }
                                          },
                                          child: Text(
                                            AppStrings.done,
                                            style: appTextStyle(
                                              fm: robotoRegular,
                                              fz: 17,
                                              color: titleController
                                                      .text.isNotEmpty
                                                  ? AppColors.black
                                                  : const Color(0XFF858484),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Divider(
                                  color: AppColors.textfieldFillColor
                                      .withOpacity(.75),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10),
                                  child: Row(
                                    children: [
                                      if ((categoryModel.categories?.length ??
                                              0) >
                                          1)
                                        GestureDetector(
                                          onTap: () {
                                            isExpandedDrop = !isExpandedDrop;
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: 24.0,
                                            margin: const EdgeInsets.only(
                                                top: 8, left: 15, bottom: 10),
                                            child: Image.asset(isExpandedDrop
                                                ? chevronDown
                                                : chevronLeft),
                                          ),
                                        ),
                                      Image.asset(
                                        book,
                                        height: 15,
                                        width: 15,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        selectedCategory(),
                                        style: appTextStyle(
                                            fm: robotoMedium,
                                            fz: 14,
                                            color: AppColors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                isExpandedDrop
                                    ? Container(
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: ListView.builder(
                                          itemCount: categoryModel.categories!
                                              .where((test) =>
                                                  test.name != "Shared" &&
                                                  test.name != "Published")
                                              .length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                for (int i = 0;
                                                    i <
                                                        categoryModel
                                                            .categories!.length;
                                                    i++) {
                                                  if (i == index) {
                                                    categoryModel
                                                        .categories![index]
                                                        .isSelected = true;
                                                  } else {
                                                    categoryModel.categories![i]
                                                        .isSelected = false;
                                                  }
                                                }
                                                setState(() {});
                                                ApiCall.getSubCategory(
                                                    api: ApiUrl.subCategory +
                                                        categoryModel
                                                            .categories![index]
                                                            .id
                                                            .toString(),
                                                    callack: this);
                                              },
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth:
                                                      90, // Ensure the min width is 90
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: selectedCategory() ==
                                                          categoryModel
                                                              .categories![
                                                                  index]
                                                              .name
                                                      ? AppColors.subTitleColor
                                                      : Colors.grey
                                                          .withOpacity(.2),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                child: Center(
                                                  child: Text(
                                                    categoryModel
                                                        .categories![index]
                                                        .name!,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const IgnorePointer(),
                                const SizedBox(height: 10),
                                Divider(
                                  color: AppColors.textfieldFillColor
                                      .withOpacity(.75),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.memoryTitle,
                                        style: appTextStyle(
                                            fm: interRegular,
                                            fz: 14,
                                            height: 19.2 / 14,
                                            color: AppColors.primaryColor),
                                      ),
                                      if (categoryMemoryModelWithoutPage.data !=
                                              null ||
                                          categoryMemoryModelWithoutPage
                                              .data!.isNotEmpty)
                                        isLabelTexFormFeildShow
                                            ? GestureDetector(
                                                onTap: () {
                                                  isLabelTexFormFeildShow =
                                                      false;
                                                  titleController.text = "";
                                                  createModel.memoryId =
                                                      memoryId;
                                                  selectedMemoryId = '';
                                                  setState(() {});
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                  color: AppColors.greyColor,
                                                ),
                                              )
                                            :

                                        Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                    color: AppColors.greyColor,
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      isReadOnly = false;
                                                      isLabelTexFormFeildShow =
                                                          true;
                                                      setState(() {});
                                                    },
                                                    child: Text(
                                                      // controller.isLabelTexFormFeildShow.value
                                                      //     ? AppStrings.done
                                                      //     :
                                                      AppStrings.addNew,
                                                      style: appTextStyle(
                                                          fm: interRegular,
                                                          fz: 14,
                                                          height: 19.2 / 14,
                                                          color: AppColors
                                                              .greyColor),
                                                    ),
                                                  ),
                                                ],
                                              )
                                    ],
                                  ),
                                ),

                                  categoryMemoryModelWithoutPage
                                      .data!.isNotEmpty &&
                                      isLabelTexFormFeildShow == false
                                      ? Container(

                                      height:categoryMemoryModelWithoutPage
                                          .data!.isEmpty?50:100,
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                            categoryMemoryModelWithoutPage
                                                .data!.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  isLabelTexFormFeildShow =
                                                  true;
                                                  isReadOnly = true;
                                                  selectedMemoryId =
                                                      categoryMemoryModelWithoutPage
                                                          .data![index].id
                                                          .toString();
                                                  print(selectedMemoryId);
                                                  titleController.text =
                                                  categoryMemoryModelWithoutPage
                                                      .data![index]
                                                      .title!;
                                                  setState(() {});
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    if (index > 0)
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          left: 8.0,
                                                          right: 8.0),
                                                      child: Row(
                                                        children: [
                                                          ClipRRect(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  5.0),
                                                              child: CachedNetworkImage(
                                                                  imageUrl: categoryMemoryModelWithoutPage
                                                                      .data![
                                                                  index]
                                                                      .lastUpdateImg!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  height: 30,
                                                                  width: 30,
                                                                  progressIndicatorBuilder: (
                                                                      context,
                                                                      url,
                                                                      downloadProgress) =>
                                                                      CircularProgressIndicator(
                                                                          value:
                                                                          downloadProgress
                                                                              .progress))),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Column(
                                                            mainAxisSize:
                                                            MainAxisSize
                                                                .min,
                                                            children: [
                                                              Text(
                                                                categoryMemoryModelWithoutPage
                                                                    .data![
                                                                index]
                                                                    .title!,
                                                                style: appTextStyle(
                                                                    fm:
                                                                    interRegular,
                                                                    fz: 14,
                                                                    height:
                                                                    19.2 /
                                                                        14,
                                                                    color: AppColors
                                                                        .black),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      ))
                                      : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextFormField(
                                      controller: titleController,
                                      focusNode: titleFocusNode,
                                      readOnly: isReadOnly,
                                      cursorColor: AppColors.primaryColor,
                                      onChanged: (val) {},
                                      style: appTextStyle(
                                        fm: robotoRegular,
                                        fz: 21,
                                        height: 27 / 21,
                                        color: AppColors.black,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppStrings.memoryTitle,
                                        hintStyle: appTextStyle(
                                          fz: isTitleFocused ? 14 : 21,
                                          color: isTitleFocused
                                              ? AppColors.primaryColor
                                              : const Color(0XFF999999),
                                          fm: robotoRegular,
                                        ),
                                        labelStyle: appTextStyle(
                                          fz: isTitleFocused ? 14 : 21,
                                          height: isTitleFocused
                                              ? 19.2 / 21
                                              : null,
                                          color: isTitleFocused
                                              ? AppColors.primaryColor
                                              : const Color(0XFF999999),
                                          fm: robotoRegular,
                                        ),
                                      ),
                                    ),
                                  ),

                                const Divider(
                                  color: AppColors.textfieldFillColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.label,
                                        style: appTextStyle(
                                            fm: interRegular,
                                            fz: 14,
                                            height: 19.2 / 14,
                                            color: AppColors.primaryColor),
                                      ),
                                      (categoryMemoryModelWithoutPage
                                                      .subCategories ==
                                                  null ||
                                              categoryMemoryModelWithoutPage
                                                  .subCategories!.isEmpty)
                                          ? Container()
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.add,
                                                  size: 20,
                                                  color: AppColors.greyColor,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    addLable = true;
                                                    setState(() {});
                                                  },
                                                  child: Text(
                                                    // controller.isLabelTexFormFeildShow.value
                                                    //     ? AppStrings.done
                                                    //     :
                                                    AppStrings.addNew,
                                                    style: appTextStyle(
                                                        fm: interRegular,
                                                        fz: 14,
                                                        height: 19.2 / 14,
                                                        color: AppColors
                                                            .greyColor),
                                                  ),
                                                ),
                                              ],
                                            )
                                    ],
                                  ),
                                ),
                                addLable == false
                                    ? Container(
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: ListView.builder(
                                          itemCount:
                                              categoryMemoryModelWithoutPage
                                                      .subCategories?.length ??
                                                  0,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            print("gdfgdsgsdgds");
                                            return InkWell(
                                              onTap: () {
                                                for (int i = 0;
                                                    i <
                                                        categoryMemoryModelWithoutPage
                                                            .subCategories!
                                                            .length;
                                                    i++) {
                                                  if (i == index) {
                                                    categoryMemoryModelWithoutPage
                                                        .subCategories![index]
                                                        .isselected = true;
                                                  } else {
                                                    categoryMemoryModelWithoutPage
                                                        .subCategories![i]
                                                        .isselected = false;
                                                  }
                                                }
                                                setState(() {});
                                              },
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth:
                                                      90, // Ensure the min width is 90
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color:
                                                      categoryMemoryModelWithoutPage
                                                              .subCategories![
                                                                  index]
                                                              .isselected
                                                          ? AppColors
                                                              .subTitleColor
                                                          : Colors.grey
                                                              .withOpacity(.2),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                child: Center(
                                                  child: Text(
                                                    categoryMemoryModelWithoutPage
                                                        .subCategories![index]
                                                        .name!,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: TextFormField(
                                          controller: labelController,
                                          cursorColor: AppColors.primaryColor,
                                          onChanged: (val) {},
                                          style: appTextStyle(
                                            fm: robotoRegular,
                                            fz: 21,
                                            height: 27 / 21,
                                            color: AppColors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: AppStrings.label,
                                            hintStyle: appTextStyle(
                                              fz: 14,
                                              color: const Color(0XFF999999),
                                              fm: robotoRegular,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        )
                      ])),
                );
              },
            ),
          );
        },
        backgroundColor: Colors.transparent,
        enableDrag: false,
      );
    });
  }

  void openAddPillBottomSheetForSignUp(BuildContext context) {
    if (isBottomSheetOpen) return;

    isBottomSheetOpen = true;
    Provider.of<BottomBarVisibilityProvider>(context, listen: false)
        .hideBottomBar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final titleContext = _titleWidgetKey.currentContext;
      if (titleContext != null) {
        FocusScope.of(titleContext).requestFocus(titleFocusNode);
      }
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      bool isReadOnly = false;

      _scaffoldKey.currentState!.showBottomSheet(
            (BuildContext context) {
          return SafeArea(
            top: true,
            bottom: false,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                debugPrint("Update on bottomSheet");
                return SingleChildScrollView(
                  child: Container(
                      height:MediaQuery.of(context).size.height/2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(100),
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 48,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              child: const Icon(Icons.close),
                                              onTap: () {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                titleController.clear();
                                                Navigator.pop(context);
                                                isBottomSheetOpen = false;
                                                Provider.of<BottomBarVisibilityProvider>(
                                                    context,
                                                    listen: false)
                                                    .showBottomBar();
                                              },
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              AppStrings.addAMemory,
                                              style: appTextStyle(
                                                fm: robotoBold,
                                                fz: 20,
                                                color: Colors.black,
                                                height: 25 / 20,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            ValueListenableBuilder<int>(
                                              valueListenable:
                                              selectedCountNotifier,
                                              builder: (context, selectedCount,
                                                  child) {
                                                return Text(
                                                  "($selectedCount)",
                                                  style: appTextStyle(
                                                    fm: robotoBold,
                                                    fz: 20,
                                                    color: Colors.black,
                                                    height: 25 / 20,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (titleController.text.isEmpty) {
                                              CommonWidgets.errorDialog(context,
                                                  "Enter memory title");

                                              //Get.snackbar("Error", "Enter memory title", colorText: AppColors.redColor);
                                            } else if (allSelectedPhotos() ==
                                                0) {
                                              CommonWidgets.errorDialog(context,
                                                  "Please select photo");
                                            } else {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              Navigator.pop(context);
                                              isBottomSheetOpen = false;
                                              uploadCount = 1;
                                              progressbarValue = 0.0;

                                                uploadData(
                                                    selectedCategoryId(), '');

                                              Provider.of<BottomBarVisibilityProvider>(
                                                  context,
                                                  listen: false)
                                                  .showBottomBar();
                                            }
                                          },
                                          child: Text(
                                            AppStrings.done,
                                            style: appTextStyle(
                                              fm: robotoRegular,
                                              fz: 17,
                                              color: titleController
                                                  .text.isNotEmpty
                                                  ? AppColors.black
                                                  : const Color(0XFF858484),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Divider(
                                  color: AppColors.textfieldFillColor
                                      .withOpacity(.75),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10),
                                  child: Row(
                                    children: [
                                      if ((categoryModel.categories?.length ??
                                          0) >
                                          1)
                                        GestureDetector(
                                          onTap: () {
                                            isExpandedDrop = !isExpandedDrop;
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: 24.0,
                                            margin: const EdgeInsets.only(
                                                top: 8, left: 15, bottom: 10),
                                            child: Image.asset(isExpandedDrop
                                                ? chevronDown
                                                : chevronLeft),
                                          ),
                                        ),
                                      Image.asset(
                                        book,
                                        height: 15,
                                        width: 15,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        selectedCategory(),
                                        style: appTextStyle(
                                            fm: robotoMedium,
                                            fz: 14,
                                            color: AppColors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                isExpandedDrop
                                    ? Container(
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ListView.builder(
                                    itemCount: categoryModel.categories!
                                        .where((test) =>
                                    test.name != "Shared" &&
                                        test.name != "Published")
                                        .length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          for (int i = 0;
                                          i <
                                              categoryModel
                                                  .categories!.length;
                                          i++) {
                                            if (i == index) {
                                              categoryModel
                                                  .categories![index]
                                                  .isSelected = true;
                                            } else {
                                              categoryModel.categories![i]
                                                  .isSelected = false;
                                            }
                                          }

                                        },
                                        child: Container(
                                          constraints:
                                          const BoxConstraints(
                                            minWidth:
                                            90, // Ensure the min width is 90
                                          ),
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color: selectedCategory() ==
                                                categoryModel
                                                    .categories![
                                                index]
                                                    .name
                                                ? AppColors.subTitleColor
                                                : Colors.grey
                                                .withOpacity(.2),
                                          ),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5),
                                          child: Center(
                                            child: Text(
                                              categoryModel
                                                  .categories![index]
                                                  .name!,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                    : const IgnorePointer(),
                                const SizedBox(height: 10),
                                Divider(
                                  color: AppColors.textfieldFillColor
                                      .withOpacity(.75),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.memoryTitle,
                                        style: appTextStyle(
                                            fm: interRegular,
                                            fz: 14,
                                            height: 19.2 / 14,
                                            color: AppColors.primaryColor),
                                      ),


                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextFormField(
                                      controller: titleController,
                                      focusNode: titleFocusNode,
                                      readOnly: isReadOnly,
                                      cursorColor: AppColors.primaryColor,
                                      onChanged: (val) {},
                                      style: appTextStyle(
                                        fm: robotoRegular,
                                        fz: 21,
                                        height: 27 / 21,
                                        color: AppColors.black,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppStrings.memoryTitle,
                                        hintStyle: appTextStyle(
                                          fz: isTitleFocused ? 14 : 21,
                                          color: isTitleFocused
                                              ? AppColors.primaryColor
                                              : const Color(0XFF999999),
                                          fm: robotoRegular,
                                        ),
                                        labelStyle: appTextStyle(
                                          fz: isTitleFocused ? 14 : 21,
                                          height: isTitleFocused
                                              ? 19.2 / 21
                                              : null,
                                          color: isTitleFocused
                                              ? AppColors.primaryColor
                                              : const Color(0XFF999999),
                                          fm: robotoRegular,
                                        ),
                                      ),
                                    ),
                                  ),

                                const Divider(
                                  color: AppColors.textfieldFillColor,
                                ),
                               ],
                            ),
                          ),
                        )
                      ])),
                );
              },
            ),
          );
        },
        backgroundColor: Colors.transparent,
        enableDrag: false,
      );
    });
  }

  CreateMoemoryModel createModel = CreateMoemoryModel();

  uploadData(String categoryId, String subCategoryId) {
    if (selectedMemoryId != "") {
      createModel.memoryId = selectedMemoryId;
    }

    createModel.categoryId = categoryId;
    createModel.subCategoryId = subCategoryId;
    createModel.title = titleController.text;
    List<ImagesFile> imageFile = [];
if(countSelectedPhotos()>0) {
  for (int i = 0; i < widget.photosList.length; i++) {
    if (widget.photosList[i].selectedValue) {
      ImagesFile imp = ImagesFile();
      imp.typeId = widget.photosList[i].assetEntity.id;
      imp.type = "image";
      imp.captureDate = _getFormattedDateTime(
          widget.photosList[i].assetEntity.createDateTime);
      imp.description = '';
      imp.link = '';

      imp.location = '';
      imageFile.add(imp);
    }
  }
}
    if (fbModel.isNotEmpty) {
      for (int i = 0; i < fbModel.length; i++) {
        if (fbModel[i].isSelected) {
          ImagesFile imp = ImagesFile();
          imp.typeId = fbModel[i].id;
          imp.type = fbModel[i].type;
          imp.captureDate = _getFormattedDateTime(fbModel[i].createdTime!);
          imp.description = '';
          imp.link = fbModel[i].webLink;

          imp.location = '';
          imageFile.add(imp);
        }
      }
    }
    if (instaModel.isNotEmpty) {
      for (int i = 0; i < instaModel.length; i++) {
        if (instaModel[i].isSelected) {
          ImagesFile imp = ImagesFile();
          imp.typeId = instaModel[i].id;
          imp.type = instaModel[i].type;
          imp.captureDate = _getFormattedDateTime(instaModel[i].createdTime!);
          imp.description = '';
          imp.link = instaModel[i].webLink;

          imp.location = '';
          imageFile.add(imp);
        }
      }
    }
    if (driveModel.isNotEmpty) {
      for (int i = 0; i < driveModel.length; i++) {
        if (driveModel[i].isSelected) {
          ImagesFile imp = ImagesFile();
          imp.typeId = driveModel[i].id;
          imp.type = driveModel[i].type;
          imp.captureDate = _getFormattedDateTime(driveModel[i].createdTime!);
          imp.description = '';
          imp.link = driveModel[i].webLink;

          imp.location = '';
          imageFile.add(imp);
        }
      }
    }
    createModel.images = imageFile;
    showProgressDialog(context);
    progressNotifier.value = progressbarValue;
    //_progress = (_currentIndex++ / countSelectedPhotos()).clamp(0.0, 1.0);
    if(countSelectedPhotos()==0){
      clossProgressDialog('');
      if (createModel.memoryId != null) {
        ApiCall.createMemory(
            api: ApiUrl.updateMemory, model: createModel, callack: this);
      } else {
        ApiCall.createMemory(
            api: ApiUrl.createMemory,
            model: createModel,
            callack: this); // Dismiss the dialog
      }
    }else{
      processPhotos();

    }

    print(createModel.images!.length);
  }

  Future<void> processPhotos() async {
    for (int i = 0; i < widget.photosList.length; i++) {
      if (widget.photosList[i].selectedValue) {
        print(widget.photosList[i].assetEntity.id);

        for (int j = 0; j < createModel.images!.length; j++) {
          if (createModel.images![j].typeId ==
              widget.photosList[i].assetEntity.id) {
            // Await the file retrieval and API call
            await FilePath.getFile(widget.photosList[i].assetEntity)
                .then((value) async {
              print(value!.path);
              await ApiCall.uploadImageIntoMemory(
                api: ApiUrl.uploadImageTomemory,
                path: value.path,
                callack: this,
                count: j.toString(),
              );
            });

            print(createModel.images![j].typeId);
          }
        }
      }
    }
  }

  String _getFormattedDateTime(DateTime asset) {
    final DateTime creationDate = asset; // Get the creation date of the asset
    final DateFormat formatter =
        DateFormat('yyyy-MM-dd HH:mm:ss'); // Define the format
    return formatter.format(creationDate); // Format the date as a string
  }

  progressDialog(double p) {
    EasyLoading.showProgress(
      p,
      // Show percentage
    );

    if (p >= 0.9) {
      _progress = 0.0;
      _currentIndex = 0;
      EasyLoading.dismiss(); // Dismiss the dialog
    }
  }

  //=====================Instagram========================
  void instaRequestForAccessToken(value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref!.setString("selectedTab", jsonEncode({"type": "insta"}));
    String clientId = '1261297914899174';
    // String clientId = '820343826870430';
    String clientSecret = 'ad28543d801e5a81087105fdcd9adf46';
    // String clientSecret = '1805f78dbdb29d02d1c7790806e119ec';
    String redirectUri = 'https://stashtdev.page.link/';
    String authorizationCode = value;
    try {
      final response = await http.post(
        Uri.parse('https://api.instagram.com/oauth/access_token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
          'code': authorizationCode,
        },
      );

      if (response.statusCode == 200) {
        // Handle the response here
        final data = jsonDecode(response.body);
        print('Access Token: ${data['access_token']}');
        if (data != null) {
          /* await FirebaseFirestore.instance
              .collection(userCollection).doc(userId).update({"instaToken":data['access_token'],
          "syncAccount":"insta"});*/
          await fetchMedia(data['access_token']);
        }
      } else {
        // Print out error details
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        //fetchMedia(accessToke);
      }
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }

  Future<void> fetchMedia(String accessToken, {bool fromSplash = false}) async {
    final response = await http.get(
      Uri.parse(
          'https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,thumbnail_url,permalink,timestamp&access_token=$accessToken'),
    );

    // Extract rate limit headers
    var rateLimit = response.headers['x-ratelimit-limit'];
    var rateLimitRemaining = response.headers['x-ratelimit-remaining'];
    var rateLimitReset = response.headers['x-ratelimit-reset'];

    // Log or handle rate limit information
    print('Rate Limit: $rateLimit');
    print('Rate Limit Remaining: $rateLimitRemaining');
    print('Rate Limit Reset: $rateLimitReset');
    photoLinks.clear();

    if (response.statusCode == 200) {
      // Successfully received the media
      var data = jsonDecode(response.body);
      if (data["data"] != null) {
        showProgressDialog(context);

        // requestStoragePermission();
        await Future.forEach(data["data"], (dynamic element) async {
          if (element["media_type"] == "IMAGE") {
            photoLinks.add(PhotoDetailModel(
              createdTime: convertTimeStampIntoDateTime(element["timestamp"]),
              isSelected: false,
              isEdit: false,
              type: "insta",
              id: element["id"],
              webLink: element["media_url"],
            ));
          }
          uploadCount += 1;
          progressbarValue = uploadCount / data["data"].length;
          progressNotifier.value = progressbarValue;
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
          clossProgressDialog('instagram_synced');
        });

        await Future.delayed(const Duration(seconds: 2), () {});
      } else {
        CommonWidgets.errorDialog(context, "No image available in Insta");

        await Future.delayed(const Duration(seconds: 2), () {});
      }
    } else {
      // Handle errors, including potential rate limiting
      if (response.statusCode == 429) {
        // HTTP 429 Too Many Requests
        print('Rate limit exceeded, retrying after reset time...');
        final resetTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(rateLimitReset ?? "") * 1000);
        final waitDuration = resetTime.difference(DateTime.now()).inSeconds;

        // Wait until the reset time before retrying
        await Future.delayed(Duration(seconds: waitDuration));
        await fetchMedia(accessToken,
            fromSplash: fromSplash); // Retry the request
      } else {
        _refreshInstaAccessToken(accessToken);
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  Future<String?> _refreshInstaAccessToken(String shortLivedToken) async {
    final response = await http.get(
      Uri.parse(
          "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=$shortLivedToken"),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data != null) {
        await fetchMedia(data['access_token']);
      }
      return data['access_token'];
    } else {
      print('Error exchanging token: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  convertTimeStampIntoDateTime(dateString) {
    String formattedDateString = dateString.replaceAll('+0000', 'Z');
    DateTime dateTime = DateTime.parse(formattedDateString);

    return dateTime;
  }

  _showProgressbar() {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: progressbarValue, // Reactive value
              backgroundColor: AppColors.textfieldFillColor,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '${(progressbarValue * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal
      builder: (context) => ProgressDialog(progressNotifier),
    );
  }

  clossProgressDialog(String type) {
    if ((progressbarValue * 100).toStringAsFixed(0) == '100') {
      Navigator.pop(context);
      progressbarValue = 0.0;
      uploadCount = 0;
      if (type == "google_drive_synced") {
        driveModel = photoLinks;
        PrefUtils.instance.saveDrivePhotoLinks(photoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == 'facebook_synced') {
        fbModel = photoLinks;

        PrefUtils.instance.saveFacebookPhotoLinks(photoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == "instagram_synced") {
        instaModel = photoLinks;

        PrefUtils.instance.saveInstaPhotoLinks(photoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      }
    }
  }

//===============Drive===================
  fetchPhotosFromDrive(
    GoogleSignIn googleSignIn,
    BuildContext context,
  ) async {
    try {
      photoLinks.clear();
      List<File> allFiles = [];
      FileList fileList;
      String? nextPageToken;
      var httpClient = await googleSignIn.authenticatedClient();
      if (httpClient == null) {
        print('Failed to get authenticated client');
        return null;
      }
      var driveApi = DriveApi(httpClient);
      print(httpClient.credentials.accessToken.data);
      showProgressDialog(context);

      // do {
      do {
        fileList = await driveApi.files.list(
          // q: "mimeType contains 'image/'",
          q: "mimeType='image/png' or mimeType='image/jpeg' or mimeType='image/jpg' and visibility='anyoneWithLink'",
          pageToken: nextPageToken,
          $fields:
              "nextPageToken, files(id, name, webViewLink,thumbnailLink,createdTime, modifiedTime,properties,webContentLink)",
        );
        if (fileList.files != null) {
          if (fileList.files!.length > 50) {
            allFiles.addAll(fileList.files!.take(50));
          }
          {
            allFiles.addAll(fileList.files!);
          }
        }
        nextPageToken = fileList.nextPageToken;
      } while (nextPageToken != null);
      if (allFiles.isNotEmpty) {
        if (allFiles.length > 50) {
          for (int i = 0; i < allFiles.take(50).length; i++) {
            if (allFiles[i].webViewLink != null) {
              photoLinks.add(PhotoDetailModel(
                  id: allFiles[i].id,
                  createdTime: allFiles[i].createdTime,
                  modifiedTime: allFiles[i].modifiedTime,
                  isSelected: false,
                  isEdit: false,
                  type: "drive",
                  webLink: allFiles[i].thumbnailLink,
                  thumbnailPath: convertToDirectLink(
                      allFiles[i].webViewLink!,
                      allFiles[i].id!,
                      httpClient.credentials.accessToken.data,
                      driveApi)));
              uploadCount += 1;
              progressbarValue = uploadCount / allFiles.take(50).length;
              progressNotifier.value = progressbarValue;
              await Future.delayed(const Duration(seconds: 1));
              setState(() {});
            }
          }
          clossProgressDialog('google_drive_synced');
        } else {
          for (int i = 0; i < allFiles.length; i++) {
            if (allFiles[i].webViewLink != null) {
              photoLinks.add(PhotoDetailModel(
                  id: allFiles[i].id,
                  createdTime: allFiles[i].createdTime,
                  modifiedTime: allFiles[i].modifiedTime,
                  isSelected: false,
                  isEdit: false,
                  type: "drive",
                  webLink: allFiles[i].thumbnailLink,
                  thumbnailPath: convertToDirectLink(
                      allFiles[i].webViewLink!,
                      allFiles[i].id!,
                      httpClient.credentials.accessToken.data,
                      driveApi)));
              uploadCount += 1;
              progressbarValue = uploadCount / allFiles.length;
              progressNotifier.value = progressbarValue;

              await Future.delayed(const Duration(seconds: 1));
              setState(() {});
              clossProgressDialog('google_drive_synced');
            }
          }
        }

        await Future.delayed(const Duration(seconds: 1), () {});
      } else {
        CommonWidgets.errorDialog(context, 'No image available in drive');

        await Future.delayed(const Duration(seconds: 2), () {
          // Get.offNamed(AppRoutes.photosViewScreen, arguments: {
          //   "photoList": photoLinks,
          //   "context": context,
          //   "groupAssets": groupedAssets,
          //   "assetsList": assetsItems,
          //   "assets": assets,
          //   "fromMedia": true
          // });
        });
        // goToMemories(false);
      }
    } catch (e) {
      print('Error fetching files: $e');
      return null;
    }
  }

  String convertToDirectLink(
      String shareableLink, String fileId, String accessToken, var driveApi) {
    print("Before ====>$shareableLink");
    final parts = shareableLink.split('/');
    final fileId = parts[5]; // The file ID is at index 5
    final directLink = 'https://drive.google.com/uc?export=view&id=$fileId';
    print("After ========>$directLink");

    changeFilePermission(fileId, accessToken, driveApi);

    return directLink;
  }

  Future<void> changeFilePermission(
      String fileId, String? accessToken, var driveApi) async {
    if (accessToken == null) {
      throw Exception('Access token is null');
    }

    // Create a Google Drive API client
    // final driveApi = drive.DriveApi(httpClient);

    // Create a permission object to set to "Anyone with the link" (public)
    final newPermission = drive.Permission(
      type: 'anyone', // Permission type: "anyone"
      role: 'reader', // Role: "reader" (view only)
    );

    try {
      // Apply the new permission to the file
      await driveApi.permissions.create(
        newPermission,
        fileId, // The Google Drive file ID
      );

      print(
          'File permissions updated: Now anyone with the link can access the file.');
    } catch (e) {
      photoLinks.forEach((element) {
        if (element.id == fileId) {
          photoLinks.remove(element);
        }
        setState(() {});
      });
      print('Failed to change permission: $e');
    } finally {}
  }

//=============facebook=======================
  fetchFacebookPhotos(AccessToken accessToken) async {
    photoLinks.clear();
    // EasyLoading.show(status: 'Processing');

    final response = await http.get(
      Uri.parse(
        'https://graph.facebook.com/me/photos?type=uploaded&access_token=${accessToken.tokenString}',
      ),
    );

    if (response.statusCode == 200) {
      List<FaceBookPhoto> faceBook = [];
      final data = json.decode(response.body);
      var photos = data['data'] as List;
      photos.forEach((element) {
        faceBook.add(FaceBookPhoto(
            id: element["id"], createdTime: element["created_time"]));
      });
      if (faceBook.isNotEmpty) {
        showProgressDialog(context);

        await Future.forEach(faceBook, (dynamic element) async {
          await fetchFacebookPhotosById(
                  accessToken.tokenString, element, faceBook)
              .then((value) {});
        });
      }
      if (photoLinks.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 2), () {
          // Get.offNamed(AppRoutes.photosViewScreen, arguments: {
          //   "photoList": photoLinks,
          //   "context": Get.context,
          //   "groupAssets": groupedAssets,
          //   "assetsList": assetsItems,
          //   "assets": assets,
          //   "fromMedia": true,
          //   "type": "fb"
          // });
        });
        // groupFbByMonth(photoList);
      }

      // Extract the URL of the first image from each photo
    } else {
      throw Exception('Failed to load photos');
    }
  }

  ///Fetch facebook url by photo id
  Future fetchFacebookPhotosById(
    String accessToken,
    FaceBookPhoto element,
    List<FaceBookPhoto> faceBook,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://graph.facebook.com/${element.id}?fields=images&access_token=$accessToken',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      photoLinks.add(PhotoDetailModel(
          type: "fb",
          createdTime: DateTime.tryParse(element.createdTime ?? ""),
          webLink: data['images'][0]["source"],
          id: element.id));
      print(photoLinks);
      uploadCount += 1;
      progressbarValue = uploadCount / faceBook.length;
      progressNotifier.value = progressbarValue;

      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
      clossProgressDialog('facebook_synced');
    } else {
      throw Exception('Failed to load photos');
    }
  }

  showFirstMemoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.textfieldFillColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 312,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 280,
            // Add padding for spacing
            decoration: BoxDecoration(
              color: AppColors.textfieldFillColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Center content vertically
              children: [
                const SizedBox(
                  height: 15,
                ),
                Text(
                  AppStrings.addFirstMemory,
                  style: appTextStyle(
                    fz: 24,
                    height: 32 / 24,
                    fm: robotoRegular,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16), // Add spacing between elements
                Text(
                  AppStrings.chooseFewPhotos,
                  style: appTextStyle(
                    fz: 14,
                    height: 20 / 14,
                    fm: robotoRegular,
                    color: AppColors.dialogMiddleFontColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                    height: 30), // Add spacing before the close button
                Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.close,
                        style: appTextStyle(
                          fz: 14,
                          height: 20 / 14,
                          fm: robotoMedium,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      barrierColor: Colors.transparent,
    );
  }
}
