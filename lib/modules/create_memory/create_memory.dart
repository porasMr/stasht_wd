import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stasht/modules/create_memory/model/group_modle.dart';
import 'package:stasht/modules/create_memory/model/sub_category_model.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_group_model.dart';
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

// ignore: must_be_immutable
class CreateMemoryScreen extends StatefulWidget {
  CreateMemoryScreen(
      {super.key,
      required this.future,
      required this.photosList,
      required this.isBack,
      this.isEdit,
      this.memoryListData,
      this.title,
      this.memoryId,
      this.cateId,
      this.subId,
      this.userId});
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];
  List<MemoryListData>? memoryListData = [];
  String? title = '';
  String? memoryId = '';
  String? cateId = '';
  String? subId = '';
  String? userId = '';

  ScrollController driveController = ScrollController();

  bool? isEdit;
  bool isBack;

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen>
    implements ApiCallback {
  List<String> tabListItem = [
    "All",
    "Camera Roll",
    "Drive",
    "Facebook",
    "Instagram",
    
  ];
  String selectedTab = "";

  int selectedIndex = 0;
  CategoryModel categoryModel = CategoryModel();
  SubCategorymodel subCategoryModel = SubCategorymodel();
  TextEditingController titleController = TextEditingController();
  TextEditingController labelController = TextEditingController();

  final FocusNode titleFocusNode = FocusNode();
  bool isExpandedDrop = false;
  bool isLableAvailable = false;
  bool isRealOnly = false;

  CategoryMemoryModelWithoutPage categoryMemoryModelWithoutPage =
      CategoryMemoryModelWithoutPage();
  bool isTitleFocused = false;
  bool addLable = true;

  //----------bottom sheet variable------------

  List<String> thumbnails = []; // Cache for thumbnail data
  double _progress = 0.0;
  int _currentIndex = 1;

  String categoryId = '';
  String subCategoryId = '';
  String memoryId = '';

  List<PhotoDetailModel> driveModel = [];
  List<PhotoDetailModel> fbModel = [];
  List<PhotoDetailModel> instaModel = [];

  List<PhotoDetailModel> photoLinks = [];

  int uploadCount = 0;
  var progressbarValue = 0.0;
  UserModel model = UserModel();
  ScrollController driveController = ScrollController();

  //--------------_Drive group model================
  List<GroupedPhotoModel> driveGroupModel = [];
  List<GroupedPhotoModel> instaGroupModel = [];
  List<GroupedPhotoModel> fbGroupModel = [];
  List<PhotoGroupModel> photoGroupModel = [];

  @override
  void initState() {
    super.initState();
    photoGroupModel=groupGalleryPhotosByDate(widget.photosList,widget.future);
    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });

    PrefUtils.instance.getDrivePrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      driveModel = value;
      driveGroupModel = groupPhotosByDate(driveModel);
    });
    PrefUtils.instance.getFacebookPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      fbModel = value;
      fbGroupModel = groupPhotosForFBAndINSTAByDate(fbModel);
    });
    PrefUtils.instance.getInstaPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      instaModel = value;
      instaGroupModel = groupPhotosForFBAndINSTAByDate(instaModel);
    });

    deselectAll();
    ApiCall.category(api: ApiUrl.categories, callack: this);
    driveController.addListener(_onScrollEnd);
  }

  List<GroupedPhotoModel> groupPhotosByDate(
      List<PhotoDetailModel> photoDetails) {
    // Create a map to group photos by captureDate
    final groupedMap = <String, List<PhotoDetailModel>>{};

    for (var photo in photoDetails) {
      // Group photos by month-year
      if (photo.thumbnailPath != null) {
        if(photo.captureDate!=null){
        if (groupedMap.containsKey(photo.captureDate)) {
          groupedMap[photo.captureDate]!.add(photo);
        } else {
          groupedMap[photo.captureDate!] = [photo];
        }
        }
      }
    }

    // Convert the map to a list of GroupedPhotoModel
    return groupedMap.entries.map((entry) {
      return GroupedPhotoModel(
        date: entry.key,
        photos: entry.value,
      );
    }).toList();
  }

   List<GroupedPhotoModel> groupPhotosForFBAndINSTAByDate(
      List<PhotoDetailModel> photoDetails) {
    // Create a map to group photos by captureDate
    final groupedMap = <String, List<PhotoDetailModel>>{};

    for (var photo in photoDetails) {
      // Group photos by month-year
      if (photo.webLink != null) {
        if(photo.captureDate!=null){
        if (groupedMap.containsKey(photo.captureDate)) {
          groupedMap[photo.captureDate]!.add(photo);
        } else {
          groupedMap[photo.captureDate!] = [photo];
        }
        }
      }
    }

    // Convert the map to a list of GroupedPhotoModel
    return groupedMap.entries.map((entry) {
      return GroupedPhotoModel(
        date: entry.key,
        photos: entry.value,
      );
    }).toList();
  }

   List<PhotoGroupModel> groupGalleryPhotosByDate(
    List<PhotoModel> photoDetails, List<Future<Uint8List?>> futures) {
  // Create a map to group photos by captureDate
  final groupedMap = <String, List<PhotoModel>>{};
  final futureMap = <String, List<Future<Uint8List?>>>{};

  for (int i = 0; i < photoDetails.length; i++) {
    // Format the capture date to 'MMM yyyy'
    String changeTime =
        DateFormat('MMM yyyy').format(photoDetails[i].assetEntity.createDateTime);

    if (changeTime.isNotEmpty) {
      // Group the photos
      if (groupedMap.containsKey(changeTime)) {
        groupedMap[changeTime]!.add(photoDetails[i]);
        futureMap[changeTime]!.add(futures[i]);
      } else {
        groupedMap[changeTime] = [photoDetails[i]];
        futureMap[changeTime] = [futures[i]];
      }
    }
  }

  // Convert the map to a list of PhotoGroupModel
  return groupedMap.entries.map((entry) {
    final date = entry.key;
    final photos = entry.value;
    final photoFutures = futureMap[date] ?? []; // Match futures with grouped photos

    return PhotoGroupModel(
      date: date,
      photos: photos,
      future: photoFutures,
    );
  }).toList();
}


  selectionOfAllPhoto() {
    titleController.text = widget.title ?? '';
    categoryId = widget.cateId ?? '';
    memoryId = widget.memoryId ?? '';
    subCategoryId = widget.subId ?? '';
    if (subCategoryId.isNotEmpty) {
      for (int sub = 0;
          sub < categoryMemoryModelWithoutPage.subCategories!.length;
          sub++) {
        print(
            "subCategoryId${categoryMemoryModelWithoutPage.subCategories![sub].id == int.parse(subCategoryId)}");

        if (categoryMemoryModelWithoutPage.subCategories![sub].id ==
            int.parse(subCategoryId)) {
          categoryMemoryModelWithoutPage.subCategories![sub].isselected = true;
        } else {
          categoryMemoryModelWithoutPage.subCategories![sub].isselected = false;
        }
      }
    }
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      if (categoryModel.categories![i].id == int.parse(categoryId)) {
        categoryModel.categories![i].isSelected = true;
        categoryId = categoryModel.categories![i].id.toString();
      } else {
        categoryModel.categories![i].isSelected = false;
      }
    }
    for (int p = 0; p < widget.memoryListData!.length; p++) {
      if (widget.memoryListData![p].type == "image") {
        updateSelectedValue(widget.memoryListData![p].typeId!);
      } else if (widget.memoryListData![p].type == "insta") {
        updateInstaSelectedValue(widget.memoryListData![p].typeId!.toString());
      } else if (widget.memoryListData![p].type == "fb") {
        updateFbSelectedValue(widget.memoryListData![p].typeId!.toString());
      } else if (widget.memoryListData![p].type == "drive") {
        updateDriveSelectedValue(widget.memoryListData![p].typeId!.toString());
      }
    }
    setState(() {});
  }

  void updateSelectedValue(String selectedId) {
for(int i=0;i<photoGroupModel.length;i++){
for(int j=0;j<photoGroupModel[i].photos.length;j++){
if (photoGroupModel[i].photos[j].assetEntity.id == selectedId) {
        photoGroupModel[i].photos[j].selectedValue = true;
        photoGroupModel[i].photos[j].isEditmemory = true;
      }
}
}

   
    setState(() {});
  }

  void updateFbSelectedValue(String selectedId) {
    for(int j=0;j<fbGroupModel.length;j++){
    for (int i = 0; i < fbGroupModel[j].photos.length; i++) {
      if (fbGroupModel[j].photos[i].id == selectedId) {
        fbGroupModel[j].photos[i].isSelected = true;
        fbGroupModel[j].photos[i].isEdit = true;
      }
    }
    }

    setState(() {});
  }

  void updateInstaSelectedValue(String selectedId) {
    for(int j=0;j<instaGroupModel.length;j++){
    for (int i = 0; i < instaGroupModel[j].photos.length; i++) {
      if (instaGroupModel[j].photos[i].id == selectedId) {
        instaGroupModel[j].photos[i].isSelected = true;
        instaGroupModel[j].photos[i].isEdit = true;
      }
    }
    }
    setState(() {});
  }

  void updateDriveSelectedValue(String selectedId) {
    for(int j=0;j<driveGroupModel.length;j++){
    for (int i = 0; i < driveGroupModel[j].photos.length; i++) {
      if (driveGroupModel[j].photos[i].id == selectedId) {
        driveGroupModel[j].photos[i].isSelected = true;
        driveGroupModel[j].photos[i].isEdit = true;
      }
    }
    }
    setState(() {});
  }

  void deselectAll() {
    for (var photoList in widget.photosList) {
      photoList.selectedValue = false;
      photoList.isEditmemory = false;
    }

    for (var photoList in driveModel) {
      photoList.isEdit = false;
      photoList.isSelected = false;
    }
    for (var photoList in fbModel) {
      photoList.isEdit = false;
      photoList.isSelected = false;
    }
    for (var photoList in instaModel) {
      photoList.isEdit = false;
      photoList.isSelected = false;
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
      appBar: widget.isBack
          ? AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: const IgnorePointer(),
              leadingWidth: 0,
              actions: [
                GestureDetector(
                  onTap: () {
                    if (titleController.text.isEmpty) {
                      CommonWidgets.errorDialog(context, "Enter memory title");

                      //Get.snackbar("Error", "Enter memory title", colorText: AppColors.redColor);
                    } else if (allSelectedPhotos() == 0) {
                      CommonWidgets.errorDialog(context, "Please select photo");
                    } else {
                      uploadCount = 1;
                      progressbarValue = 0.0;
                      if (labelController.text.isEmpty) {
                        uploadData(
                            getSelectedCategory(), selectedSubCategory());
                      } else {
                        ApiCall.createSubCategory(
                            api: ApiUrl.createSubCategory,
                            name: labelController.text,
                            id: categoryId,
                            callack: this);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Text(
                      AppStrings.done,
                      style: appTextStyle(
                          fz: 17,
                          fm: interMedium,
                          color: (countSelectedPhotos() > 0 &&
                                  titleController.text.isNotEmpty)
                              ? AppColors.primaryColor
                              : AppColors.greyColor),
                    ),
                  ),
                )
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
                    widget.isEdit != null
                        ? "Edit ${AppStrings.addMemory}"
                        : "Add ${AppStrings.addMemory}",
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
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: categoryModel.categories == null
                ? Container()
                : Row(
                    children: [
                      if (categoryModel.categories!.length > 1)
                        GestureDetector(
                          onTap: () {
                            isExpandedDrop = !isExpandedDrop;
                            setState(() {});
                          },
                          child: Container(
                            width: 24.0,
                            margin: const EdgeInsets.only(top: 8, bottom: 10),
                            child: Image.asset(
                              isExpandedDrop ? chevronDown : chevronLeft,
                              width: 32,
                              height: 32,
                            ),
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
                            fm: robotoMedium, fz: 14, color: AppColors.black),
                      ),
                    ],
                  ),
          ),
          isExpandedDrop
              ? Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: categoryModel.categories!
                        .where((test) =>
                            test.name != "Shared" && test.name != "Published")
                        .length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          for (int i = 0;
                              i < categoryModel.categories!.length;
                              i++) {
                            if (i == index) {
                              categoryModel.categories![index].isSelected =
                                  true;
                            } else {
                              categoryModel.categories![i].isSelected = false;
                            }
                          }
                          setState(() {});
                          ApiCall.getSubCategory(
                              api: ApiUrl.subCategory +
                                  categoryModel.categories![index].id
                                      .toString(),
                              callack: this);
                        },
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 90, // Ensure the min width is 90
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: selectedCategory() ==
                                    categoryModel.categories![index].name
                                ? AppColors.subTitleColor
                                : Colors.grey.withOpacity(.2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          child: Center(
                            child: Text(
                              categoryModel.categories![index].name!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const IgnorePointer(),
          Divider(
            color: AppColors.textfieldFillColor.withOpacity(.75),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.memoryTitle,
                  style: appTextStyle(
                      fm: interRegular,
                      fz: 14,
                      height: 19.2 / 14,
                      color: AppColors.primaryColor),
                ),
                // categoryMemoryModelWithoutPage.data == null
                //     ? Container()
                //     : Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           const Icon(
                //             Icons.add,
                //             size: 20,
                //             color: AppColors.greyColor,
                //           ),
                //           TextButton(
                //             onPressed: () {
                //               //  labelFocusNode.unfocus();

                //               // }
                //             },
                //             child: Text(
                //               // controller.isLabelTexFormFeildShow.value
                //               //     ? AppStrings.done
                //               //     :
                //               AppStrings.addNew,
                //               style: appTextStyle(
                //                   fm: interRegular,
                //                   fz: 14,
                //                   height: 19.2 / 14,
                //                   color: AppColors.greyColor),
                //             ),
                //           ),
                //         ],
                //       )
              ],
            ),
          ),
          // categoryMemoryModelWithoutPage.data != null
          //     ? Container()
          //     :
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: titleController,
              focusNode: titleFocusNode,
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
              ),
            ),
          ),
          const Divider(
            color: AppColors.textfieldFillColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.label,
                  style: appTextStyle(
                      fm: interRegular,
                      fz: 14,
                      height: 19.2 / 14,
                      color: AppColors.primaryColor),
                ),
                (categoryMemoryModelWithoutPage.subCategories == null ||
                        categoryMemoryModelWithoutPage.subCategories!.isEmpty)
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
                                  color: AppColors.greyColor),
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
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount:
                        categoryMemoryModelWithoutPage.subCategories!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      print("gdfgdsgsdgds");
                      return InkWell(
                        onTap: () {
                          for (int i = 0;
                              i <
                                  categoryMemoryModelWithoutPage
                                      .subCategories!.length;
                              i++) {
                            if (i == index) {
                              categoryMemoryModelWithoutPage
                                  .subCategories![index].isselected = true;
                            } else {
                              categoryMemoryModelWithoutPage
                                  .subCategories![i].isselected = false;
                            }
                          }
                          subCategoryId = categoryMemoryModelWithoutPage
                              .subCategories![index].id
                              .toString();
                          setState(() {});
                        },
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 90, // Ensure the min width is 90
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: categoryMemoryModelWithoutPage
                                    .subCategories![index].isselected
                                ? AppColors.subTitleColor
                                : Colors.grey.withOpacity(.2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          child: Center(
                            child: Text(
                              categoryMemoryModelWithoutPage
                                  .subCategories![index].name!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                child: selectedtabView(context)),
          ),
        ],
      ),
    );
  }

  int allSelectedPhotos() {
    int value = 0;
    for(int i=0;i<photoGroupModel.length;i++){
    value = value +
        photoGroupModel[i].photos
            .where((photo) => (photo.selectedValue || photo.isEditmemory))
            .length;
    }
    for(int i=0;i<fbGroupModel.length;i++){
    value = value +
        fbGroupModel[i].photos.where((photo) => (photo.isSelected || photo.isEdit)).length;
    }
        for(int i=0;i<instaGroupModel.length;i++){

    value = value +
        instaGroupModel[i].photos.where((photo) => (photo.isSelected || photo.isEdit)).length;
        }
                for(int i=0;i<driveGroupModel.length;i++){

    value = value +
        driveGroupModel[i].photos.where((photo) => (photo.isSelected || photo.isEdit)).length;
                }
    return value;
  }

  selectedtabView(BuildContext context) {
    if (selectedIndex == 0) {
      return CommonWidgets.albumView(
photoGroupModel,        viewRefersh,
      );
    } else if (selectedIndex == 1) {
      return CommonWidgets.albumView(
photoGroupModel,        viewRefersh,
      );
    } else if (selectedIndex == 2) {
      if (driveGroupModel.isEmpty) {
        return CommonWidgets.driveView(context, getDriveView);
      } else {
        return CommonWidgets.drivePhtotView(driveGroupModel, viewRefersh,
            controller: driveController);
      }
    }
    else if (selectedIndex == 3) {
      if (fbGroupModel.isEmpty) {
        return CommonWidgets.fbView(context, getFacebbokPhoto);
      } else {
        return CommonWidgets.fbPhtotView(fbGroupModel, viewRefersh);
      }
    } else if (selectedIndex == 4) {
      if (instaGroupModel.isEmpty) {
        return CommonWidgets.photoView(context, getInstaView);
      } else {
        return CommonWidgets.instaPhtotView(instaGroupModel, viewRefersh);
      }
    } 
  }

  void _onScrollEnd() {
    if (driveController.position.pixels >=
        driveController.position.maxScrollExtent) {
      if (PrefUtils.instance.getDriveToken() != null &&
          PrefUtils.instance.getDriveToken()!.isNotEmpty) {
            CommonWidgets.showBottomSheet(context,(){
 CommonWidgets.getFileFromGoogleDrive(context).then((value) {
              getDriveView(value!, PrefUtils.instance.getDriveToken()!);
            });
            });
       // _showLoadMoreSnackbar();
      }
    }
  }

  // void _showLoadMoreSnackbar() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //               behavior: SnackBarBehavior.floating,

  //       content: const Text("Loading another 30 images"),
  //       action: SnackBarAction(
  //         label: 'Load more',
          
  //         onPressed: () {
  //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //           CommonWidgets.getFileFromGoogleDrive(context).then((value) {
  //             getDriveView(value!, PrefUtils.instance.getDriveToken()!);
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  getFacebbokPhoto(AccessToken token) {
    fetchFacebookPhotos(token);
  }

  getInstaView(String token) {
    instaRequestForAccessToken(token);
  }

  getDriveView(GoogleSignIn v1, String pageToken) {
   if(photoLinks.isNotEmpty){
    photoLinks.clear();
   }
    fetchPhotosFromDrive(v1, context, pageToken);
  }

  viewRefersh() {
    setState(() {});
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

  @override
  void onFailure(String message) {
    EasyLoading.dismiss();
    if (widget.isEdit!) {
      CommonWidgets.errorDialog(context, message);
      if (countSelectedPhotos() == 0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('',
        []);
      }
    }
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);
    if (apiType == ApiUrl.categories) {
      categoryModel = CategoryModel.fromJson(jsonDecode(data));
      categoryModel.categories![0].isSelected = true;
      categoryId = categoryModel.categories![0].id.toString();
      setState(() {});
      ApiCall.memoryByCategory(
          api: ApiUrl.memoryByCategory,
          id: categoryModel.categories![0].id.toString(),
          sub_category_id: '',
          type: 'no_page',
          page: "1",
          callack: this);
    } else if (apiType == ApiUrl.memoryByCategory) {
      EasyLoading.dismiss();

      categoryMemoryModelWithoutPage =
          CategoryMemoryModelWithoutPage.fromJson(jsonDecode(data));

      if (widget.isEdit!) {
        selectionOfAllPhoto();
      }

      if (categoryMemoryModelWithoutPage.subCategories!.isNotEmpty) {
        addLable = false;
        setState(() {});
      }
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
        clossProgressDialog('',[]);
        if (createModel.memoryId != null) {
          ApiCall.createMemory(
              api: ApiUrl.updateMemory, model: createModel, callack: this);
        } else {
          ApiCall.createMemory(
              api: ApiUrl.createMemory, model: createModel, callack: this);
        } // Dismiss the dialog
      }
    } else if (apiType == ApiUrl.createMemory) {
      if (countSelectedPhotos() == 0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('',[]);
      }

      deselectAll();
      titleController.text = "";
      labelController.text = "";
      CommonWidgets.successDialog(context, json.decode(data)['message']);
      Navigator.pop(context, true);

      print(data);
    } else if (apiType == ApiUrl.updateMemory) {
      if (countSelectedPhotos() == 0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('',[]);
      }
      deselectAll();
      titleController.text = "";
      labelController.text = "";
      CommonWidgets.successDialog(context, json.decode(data)['message']);
      Navigator.pop(context, true);
    } else if (apiType == ApiUrl.createSubCategory) {
      SubCategoryResModel subCategoryResModel =
          SubCategoryResModel.fromJson(json.decode(data));
      uploadData(
          getSelectedCategory(), subCategoryResModel.categories!.id.toString());
    } else if (apiType == ApiUrl.syncAccount) {
      setState(() {});
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
    int i=0;
    for(int j=0;j<photoGroupModel.length;j++){
     i =i+ photoGroupModel[j].photos
        .where((photo) => (photo.selectedValue && photo.isEditmemory == false))
        .length;
    print("dfasf$i");
    }
    return i;
  }

  String selectedCategory() {
    for (var category in categoryModel.categories!) {
      if (category.isSelected) {
        return category.name!;
      }
    }
    return '';
  }

  String getSelectedCategory() {
    for (var category in categoryModel.categories!) {
      if (category.isSelected) {
        return category.id.toString();
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

  void openAddPillBottomSheet(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(titleFocusNode);
    });
  }

  CreateMoemoryModel createModel = CreateMoemoryModel();

  uploadData(String categoryId, String subCategoryId) {
    print('fsafasf');
    if (memoryId != '') {
      createModel.memoryId = memoryId;
    }
    createModel.categoryId = categoryId;
    createModel.subCategoryId = subCategoryId;
    createModel.title = titleController.text;
    List<ImagesFile> imageFile = [];
for(int j=0;j<photoGroupModel.length;j++){
    for (int i = 0; i < photoGroupModel[j].photos.length; i++) {
      if (photoGroupModel[j].photos[i].selectedValue &&
          photoGroupModel[j].photos[i].isEditmemory == false) {
        ImagesFile imp = ImagesFile();
        imp.typeId = photoGroupModel[j].photos[i].assetEntity.id;
        imp.type = "image";
        imp.captureDate = _getFormattedDateTime(
            photoGroupModel[j].photos[i].assetEntity.createDateTime);
        imp.description = '';
        imp.link = '';

        FilePath.getImageLocation(photoGroupModel[j].photos[i].assetEntity)!
            .then((value) {
          imp.location = value;
        });
        imageFile.add(imp);
      }
    }
}
    if (fbGroupModel.isNotEmpty) {
      for(int j=0;j<fbGroupModel.length;j++){
      for (int i = 0; i <fbGroupModel[j].photos.length; i++) {
        if (fbGroupModel[j].photos[i].isSelected && fbGroupModel[j].photos[i].isEdit == false) {
          ImagesFile imp = ImagesFile();
          imp.typeId = fbGroupModel[j].photos[i].id;
          imp.type = fbGroupModel[j].photos[i].type;
          imp.captureDate = _getFormattedDateTime(fbGroupModel[j].photos[i].createdTime!);
          imp.description = '';
          imp.link = fbGroupModel[j].photos[i].webLink;

          imp.location = '';
          imageFile.add(imp);
        }
      }
      }
    }
    if (instaGroupModel.isNotEmpty) {
            for(int j=0;j<instaGroupModel.length;j++){

      for (int i = 0; i < instaGroupModel[j].photos.length; i++) {
        if (instaGroupModel[j].photos[i].isSelected && instaGroupModel[j].photos[i].isEdit == false) {
          ImagesFile imp = ImagesFile();
          imp.typeId = instaGroupModel[j].photos[i].id;
          imp.type = instaGroupModel[j].photos[i].type;
          imp.captureDate = _getFormattedDateTime(instaGroupModel[j].photos[i].createdTime!);
          imp.description = '';
          imp.link = instaGroupModel[j].photos[i].webLink;

          imp.location = '';
          imageFile.add(imp);
        }
      }
            }
    }
    if (driveGroupModel.isNotEmpty) {
                  for(int j=0;j<driveGroupModel.length;j++){

      for (int i = 0; i <driveGroupModel[j].photos.length; i++) {
        if (driveGroupModel[j].photos[i].isSelected && driveGroupModel[j].photos[i].isEdit == false) {
          ImagesFile imp = ImagesFile();
          imp.typeId = driveGroupModel[j].photos[i].id;
          imp.type = driveGroupModel[j].photos[i].type;
          imp.captureDate = _getFormattedDateTime(driveGroupModel[j].photos[i].createdTime!);
          imp.description = '';
          imp.link = driveGroupModel[j].photos[i].webLink;

          imp.location = '';
          imageFile.add(imp);
        }
      }
                  }
    }
    createModel.images = imageFile;
    showProgressDialog(context);
    progressNotifier.value = progressbarValue;
    //_progress = (_currentIndex++ / countSelectedPhotos()).clamp(0.0, 1.0);
    if (countSelectedPhotos() == 0) {
      clossProgressDialog('',[]);
      if (createModel.memoryId != null) {
        ApiCall.createMemory(
            api: ApiUrl.updateMemory, model: createModel, callack: this);
      } else {
        ApiCall.createMemory(
            api: ApiUrl.createMemory,
            model: createModel,
            callack: this); // Dismiss the dialog
      }
    } else {
      processPhotos();
    }

    print(createModel.images!.length);
  }

  Future<void> processPhotos() async {
    for(int j=0;j<photoGroupModel.length;j++){
    for (int i = 0; i < photoGroupModel[j].photos.length; i++) {
      if (photoGroupModel[j].photos[i].selectedValue &&
          photoGroupModel[j].photos[i].isEditmemory == false) {
        print(photoGroupModel[j].photos[i].assetEntity.id);

        for (int j = 0; j < createModel.images!.length; j++) {
          if (createModel.images![j].typeId ==
              photoGroupModel[j].photos[i].assetEntity.id) {
            // Await the file retrieval and API call
            await FilePath.getFile(photoGroupModel[j].photos[i].assetEntity)
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

    if (p >= 1.0) {
      _progress = 0.0;
      _currentIndex = 0;
      EasyLoading.dismiss();
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
  List<PhotoDetailModel> tempPhotoLinks=[];
    if (response.statusCode == 200) {
      // Successfully received the media
      var data = jsonDecode(response.body);
      if (data["data"] != null) {
        showProgressDialog(context);

        // requestStoragePermission();
        await Future.forEach(data["data"], (dynamic element) async {
          if (element["media_type"] == "IMAGE") {
            String capturDate= convertTimeStampIntoDateTime(element["timestamp"]);
            tempPhotoLinks.add(PhotoDetailModel(
                createdTime: convertTimeStampIntoDateTime(element["timestamp"]),
                isSelected: false,
                isEdit: false,
                type: "insta",
                id: element["id"],
                webLink: element["media_url"],
                captureDate: capturDate));
          }
          uploadCount += 1;
          progressbarValue = uploadCount / data["data"].length;
          progressNotifier.value = progressbarValue;
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
          clossProgressDialog('instagram_synced',tempPhotoLinks);
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

  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal
      builder: (context) => ProgressDialog(progressNotifier),
    );
  }

  clossProgressDialog(String type,      List<PhotoDetailModel> tempPhotoLinks
) {
    if ((progressbarValue * 100).toStringAsFixed(0) == '100') {
      Navigator.pop(context);
      progressbarValue = 0.0;
      uploadCount = 0;
      if (type == "google_drive_synced") {
        photoLinks=tempPhotoLinks;
        if (driveModel.isEmpty) {
          driveModel = photoLinks;
        } else {
          driveModel.addAll(photoLinks);
        }
        PrefUtils.instance.saveDrivePhotoLinks(driveModel);
        if(driveGroupModel.isEmpty){
        driveGroupModel = groupPhotosByDate(photoLinks);

        }else{
          driveGroupModel.addAll(groupPhotosByDate(photoLinks));
        }

        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == 'facebook_synced') {
        fbModel = tempPhotoLinks;

        fbGroupModel = groupPhotosForFBAndINSTAByDate(fbModel);

        PrefUtils.instance.saveFacebookPhotoLinks(tempPhotoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == "instagram_synced") {

        instaModel = tempPhotoLinks;
        instaGroupModel = groupPhotosForFBAndINSTAByDate(instaModel);

        PrefUtils.instance.saveInstaPhotoLinks(tempPhotoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      }
     setState(() {
          
        });
    }
  }

//===============Drive===================
    fetchPhotosFromDrive(
    GoogleSignIn googleSignIn,
    BuildContext context,
    String? nextPageToken
  ) async {
    try {
      List<PhotoDetailModel> tempPhotoLinks=[];
      List<File> allFiles = [];
      FileList fileList;
      
      var httpClient = await googleSignIn.authenticatedClient();
      if (httpClient == null) {
        print('Failed to get authenticated client');
        return null;
      }
      var driveApi = DriveApi(httpClient);
      print(httpClient.credentials.accessToken.data);
      showProgressDialog(context);

      // do {

      fileList = await driveApi.files.list(
        // q: "mimeType contains 'image/'",
q: "mimeType='image/png' or mimeType='image/jpeg' or mimeType='image/jpg' and trashed=false and visibility='anyoneWithLink' and not 'me' in owners",
      pageToken: nextPageToken,
        $fields:
            "nextPageToken, files(id, name, webViewLink,thumbnailLink,createdTime, modifiedTime,properties,webContentLink,permissions)",
      );
      if (fileList.files != null||fileList.files!.isNotEmpty) {
        // if (fileList.files!.length > 50) {
        //   allFiles.addAll(fileList.files!.take(50));
        // }
        // {
        allFiles.addAll(fileList.files!);
        //}
        nextPageToken = fileList.nextPageToken;
        print("dsfasfa${allFiles.length} $nextPageToken");
         if (nextPageToken != null) {
          PrefUtils.instance.driveToken(nextPageToken);
        } else {
          PrefUtils.instance.driveToken('');
        }
        for (int i = 0; i < allFiles.length; i++) {
          if (allFiles[i].webViewLink != null) {
            

String captureDate=   DateFormat('MMM yyyy').format(allFiles[i].createdTime!);

            tempPhotoLinks.add(PhotoDetailModel(
                id: allFiles[i].id,
                createdTime: allFiles[i].createdTime,
                modifiedTime: allFiles[i].modifiedTime,
                isSelected: false,
                isEdit: false,
                type: "drive",
             webLink: allFiles[i].webContentLink,
                thumbnailPath: allFiles[i].thumbnailLink,captureDate: captureDate));
           
          
                  uploadCount += 1;
            progressbarValue = uploadCount / allFiles.length;
            progressNotifier.value = progressbarValue;

            await Future.delayed(const Duration(microseconds: 100));
             
           clossProgressDialog('google_drive_synced',tempPhotoLinks);
 
                                  }
        }
         

            await Future.delayed(const Duration(microseconds: 100));
      } else {
          PrefUtils.instance.driveToken('');

        CommonWidgets.errorDialog(context, 'No image available in drive');
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);
        clossProgressDialog('',[]);
        PrefUtils.instance.driveToken('');

        await Future.delayed(const Duration(seconds: 2), () {
          
        });
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
  List<PhotoDetailModel> tempPhotoLinks = [];
  ///Fetch facebook url by photo id
  Future fetchFacebookPhotosById(
    String accessToken,
    FaceBookPhoto element,
    List<FaceBookPhoto> faceBook,
  ) async {
    photoLinks.clear();
    final response = await http.get(
      Uri.parse(
        'https://graph.facebook.com/${element.id}?fields=images&access_token=$accessToken',
      ),
    );

    if (response.statusCode == 200) {

      final data = json.decode(response.body);
      String captureDate=CommonWidgets.daysWithYearRetrun(element.createdTime ?? "");
      tempPhotoLinks.add(PhotoDetailModel(
          type: "fb",
          createdTime: DateTime.tryParse(element.createdTime ?? ""),
          webLink: data['images'][0]["source"],
          captureDate:captureDate,
          id: element.id));
      print(photoLinks);
      uploadCount += 1;
      progressbarValue = uploadCount / faceBook.length;
      progressNotifier.value = progressbarValue;

      await Future.delayed(const Duration(seconds: 2));
      setState(() {});
      clossProgressDialog('facebook_synced',tempPhotoLinks);
    } else {
      throw Exception('Failed to load photos');
    }
  }
}
