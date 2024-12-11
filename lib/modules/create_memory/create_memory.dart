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
import 'package:stasht/modules/create_memory/model/sub_category_model.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
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
      this.memoryListData,this.title,this.memoryId,this.cateId,this.subId});
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];
  List<MemoryListData>? memoryListData = [];
  String? title='';
  String? memoryId='';
  String? cateId='';
  String? subId='';


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

  selectionOfAllPhoto() {
    titleController.text = widget.title??'';
    categoryId = widget.cateId??'';
    memoryId = widget.memoryId ??'';
    subCategoryId =
        widget.subId??'';
    if (subCategoryId.isNotEmpty) {

      for (int sub = 0;
      sub < categoryMemoryModelWithoutPage.subCategories!.length;
      sub++) {
        print("subCategoryId${categoryMemoryModelWithoutPage.subCategories![sub].id ==
            int.parse(subCategoryId)}");

        if (categoryMemoryModelWithoutPage.subCategories![sub].id ==
            int.parse(subCategoryId) ) {
          categoryMemoryModelWithoutPage.subCategories![sub].isselected = true;
        }else{
          categoryMemoryModelWithoutPage.subCategories![sub].isselected = false;
        }
      }
    }
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      if (categoryModel.categories![i].id ==
          int.parse(categoryId) ) {
        categoryModel.categories![i].isSelected = true;
        categoryId = categoryModel.categories![i].id.toString();
      }else{
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
    for (int i = 0; i < widget.photosList.length; i++) {
      if (widget.photosList[i].assetEntity.id == selectedId) {
        widget.photosList[i].selectedValue = true;
        widget.photosList[i].isEditmemory = true;
      }
    }

    setState(() {});
  }

  void updateFbSelectedValue(String selectedId) {
    for (int i = 0; i < fbModel.length; i++) {
      if (fbModel[i].id == selectedId) {
        fbModel[i].isSelected = true;
        fbModel[i].isEdit = true;
      }
    }

    setState(() {});
  }

  void updateInstaSelectedValue(String selectedId) {
    for (int i = 0; i < instaModel.length; i++) {
      if (instaModel[i].id == selectedId) {
        instaModel[i].isSelected = true;
        fbModel[i].isEdit = true;
      }
    }
    setState(() {});
  }

  void updateDriveSelectedValue(String selectedId) {
    for (int i = 0; i < driveModel.length; i++) {
      if (instaModel[i].id == selectedId) {
        driveModel[i].isSelected = true;
        fbModel[i].isEdit = true;
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
                        uploadData(getSelectedCategory(), selectedSubCategory());
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
    value = value +
        widget.photosList
            .where(
                (photo) => (photo.selectedValue || photo.isEditmemory))
            .length;
    value = value + fbModel.where((photo) => (photo.isSelected||photo.isEdit)).length;
    value = value + instaModel.where((photo) =>(photo.isSelected||photo.isEdit)).length;
    value = value + driveModel.where((photo) => (photo.isSelected||photo.isEdit)).length;

    return value;
  }

  selectedtabView(BuildContext context) {
    if (selectedIndex == 0) {
      return CommonWidgets.albumView(
        widget.future,
        widget.photosList,
        viewRefersh,
      );
    } else if (selectedIndex == 1) {
      return CommonWidgets.albumView(
          widget.future, widget.photosList, viewRefersh);
    } else if (selectedIndex == 2) {
      if (fbModel.isEmpty) {
        return CommonWidgets.fbView(context, getFacebbokPhoto);
      } else {
        return CommonWidgets.fbPhtotView(fbModel, viewRefersh);
      }
    } else if (selectedIndex == 3) {
      if (instaModel.isEmpty) {
        return CommonWidgets.instaView(context, getInstaView);
      } else {
        return CommonWidgets.instaPhtotView(instaModel, viewRefersh);
      }
    } else if (selectedIndex == 4) {
      if (driveModel.isEmpty) {
        return CommonWidgets.driveView(context, getDriveView);
      } else {
        return CommonWidgets.drivePhtotView(driveModel, viewRefersh);
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

    CommonWidgets.errorDialog(context, message);
     if(countSelectedPhotos()==0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('');
      }
  }

  @override
  void onSuccess(String data, String apiType) {
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
          setState(() {

          });
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
        clossProgressDialog('');
        if (createModel.memoryId != null) {
          ApiCall.createMemory(
              api: ApiUrl.updateMemory, model: createModel, callack: this);
        } else {
          ApiCall.createMemory(
              api: ApiUrl.createMemory, model: createModel, callack: this);
        } // Dismiss the dialog
      }
    } else if (apiType == ApiUrl.createMemory) {
      if(countSelectedPhotos()==0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('');
      }

      deselectAll();
      titleController.text = "";
      labelController.text = "";
      CommonWidgets.successDialog(context, json.decode(data)['message']);
      Navigator.pop(context, true);

      print(data);
    }
    else if (apiType == ApiUrl.updateMemory) {
      if(countSelectedPhotos()==0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('');
      }
      deselectAll();
      titleController.text = "";
      labelController.text = "";
      CommonWidgets.successDialog(context, json.decode(data)['message']);
      Navigator.pop(context, true);

    }else if (apiType == ApiUrl.createSubCategory) {
      SubCategoryResModel subCategoryResModel =
          SubCategoryResModel.fromJson(json.decode(data));
      uploadData(getSelectedCategory(), subCategoryResModel.categories!.id.toString());
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
    int i = widget.photosList
        .where((photo) => (photo.selectedValue && photo.isEditmemory == false))
        .length;
    print("dfasf$i");
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

    for (int i = 0; i < widget.photosList.length; i++) {
      if (widget.photosList[i].selectedValue &&
          widget.photosList[i].isEditmemory == false) {
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
    if (fbModel.isNotEmpty) {
      for (int i = 0; i < fbModel.length; i++) {
        if (fbModel[i].isSelected && fbModel[i].isEdit == false) {
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
        if (instaModel[i].isSelected && instaModel[i].isEdit == false) {
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
        if (driveModel[i].isSelected && driveModel[i].isEdit == false) {
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
      if (widget.photosList[i].selectedValue &&
          widget.photosList[i].isEditmemory == false) {
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
}
