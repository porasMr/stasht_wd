import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stasht/modules/create_memory/model/group_modle.dart';
import 'package:stasht/modules/create_memory/model/memory_item.dart';
import 'package:stasht/modules/invite_collaborator/invite_collaborator_screen.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/model/CombinedPhotoModel.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_group_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
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
class NewMemoryScreen extends StatefulWidget {
  NewMemoryScreen(
      {super.key,
      required this.future,
      required this.photosList,
      required this.driveGroupModel,
      required this.instaGroupModel,
      required this.fbGroupModel,
      required this.selectedIndexTab,
       this.selectedCount,
       this.gridItemCount,
      required this.photoGroupModel,
      required this.allPhotoGroupModel});
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];
  List<GroupedPhotoModel> driveGroupModel = [];
  List<GroupedPhotoModel> instaGroupModel = [];
  List<GroupedPhotoModel> fbGroupModel = [];
  List<PhotoGroupModel> photoGroupModel = [];
  List<CombinedPhotoModel> allPhotoGroupModel = [];

  int selectedIndexTab;
  int? selectedCount;
    int? gridItemCount;


  @override
  State<NewMemoryScreen> createState() => _NewMemoryScreenScreenState();
}

class _NewMemoryScreenScreenState extends State<NewMemoryScreen>
    implements ApiCallback {
     List<Map<String, dynamic>> tabListItem = [
   
  ];
  String selectedTab = "";

  int selectedIndex = 0;
  CategoryModel categoryModel = CategoryModel();
  SubCategorymodel subCategoryModel = SubCategorymodel();
  TextEditingController titleController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  FocusNode categoryFocusNode = FocusNode();
  FocusNode labelFocusNode = FocusNode();

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

  List<PhotoDetailModel> driveModel = [];
  List<PhotoDetailModel> fbModel = [];
  List<PhotoDetailModel> instaModel = [];

  List<PhotoDetailModel> photoLinks = [];

  int uploadCount = 0;
  var progressbarValue = 0.0;
  UserModel model = UserModel();
  ScrollController driveController = ScrollController();

  // Dummy List
  List<String> memoryOptions = [];
  List<MemoryItem> memoryItem = [];
  List<String> memoryLabel = [];

  String selectedMemory = "";
  String selectedTitle = "Choose a Memory";
  String selectLabel = "";
  bool isMemoryTitleDropdownExpanded = false;
  bool isMemoryCategoryDropDownExpanded = false;
  bool isMemoryLabelDropDownExpanded = false;
  //--------------_Drive group model================
  List<GroupedPhotoModel> driveGroupModel = [];
  List<GroupedPhotoModel> instaGroupModel = [];
  List<GroupedPhotoModel> fbGroupModel = [];
  List<PhotoGroupModel> photoGroupModel = [];
  List<CombinedPhotoModel> allPhotoGroupModel = [];

  void toggleMemoryTitleDropdown() {
    setState(() {
      isMemoryTitleDropdownExpanded = !isMemoryTitleDropdownExpanded;
    });
  }

  void selectMemory(MemoryItem memory) {
    setState(() {
      selectedTitle = memory.title;
      isMemoryTitleDropdownExpanded = false;
    });
    titleController.text = memory.title;
  }

  void selectCategory(String memory) {
    setState(() {
      selectedMemory = memory;
      isMemoryCategoryDropDownExpanded = false;
    });
    categoryController.text = memory;
  }

  void selectedLabel(String memory) {
    setState(() {
      selectLabel = memory;
      isMemoryLabelDropDownExpanded = false;
    });
    labelController.text = memory;
  }

  void toggleMemoryCategoryDropdown() {
    setState(() {
      isMemoryCategoryDropDownExpanded = !isMemoryCategoryDropDownExpanded;
    });
  }

  void toggleMemoryLabelDropdown() {
    setState(() {
      isMemoryLabelDropDownExpanded = !isMemoryLabelDropDownExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
tabListItem=CommonWidgets.syncTab();
    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });
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

    photoGroupModel = widget.photoGroupModel;

    driveGroupModel = widget.driveGroupModel;
    instaGroupModel = widget.instaGroupModel;
    fbGroupModel = widget.fbGroupModel;
    allPhotoGroupModel = widget.allPhotoGroupModel;

    //deselectAll();
    changeTab();
    ApiCall.category(api: ApiUrl.categories, callack: this);
    driveController.addListener(_onScrollEnd);
  }

  void changeTab() {
if(widget.selectedIndexTab==0){
viewRefersh();
 }else{
viewRefershOtherTab();

 }    Future.delayed(const Duration(milliseconds: 500), () async {
      selectedIndex = widget.selectedIndexTab;
      setState(() {});
    });
  }

  void deselectAll() {
    for (var photoGropupList in photoGroupModel) {
      for (var photoList in photoGropupList.photos) {
        photoList.selectedValue = false;
        photoList.isEditmemory = false;
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: const IgnorePointer(),
        leadingWidth: 0,
        actions: [
          GestureDetector(
            onTap: () {
              if (titleController.text.isEmpty) {
                CommonWidgets.errorDialog(context, "Enter memory title");
              } else if (allSelectedPhotos() == 0) {
                CommonWidgets.errorDialog(context, "Please select photo");
              } else {
                uploadCount = 1;
                progressbarValue = 0.0;
                if (labelController.text.isEmpty) {
                  uploadData(getSelectedCategory(), "");
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text(
                "Next",
                style: appTextStyle(
                    fz: 17,
                    fm: interMedium,
                    color: (allSelectedPhotos() > 0 &&
                            titleController.text.isNotEmpty)
                        ? AppColors.primaryColor
                        : AppColors.hintColor),
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
              width: 10,
            ),
            Text(
              allSelectedPhotos() > 0
                  ? "Add Memory (${allSelectedPhotos()})"
                  : "Add Memory",
              style: appTextStyle(
                  fz: 22,
                  height: 28 / 22,
                  fm: robotoRegular,
                  color: Colors.black),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Divider(
            color: AppColors.textfieldFillColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: titleController,
                        focusNode: titleFocusNode,
                        cursorColor: AppColors.primaryColor,
                        readOnly: true,
                        onChanged: (val) {},
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            builder: (context) {
                              TextEditingController memoryTitleController =
                                  TextEditingController(
                                      text: titleController.text);
                              FocusNode focusNode = FocusNode();

                              // Ensure the keyboard is displayed when the bottom sheet opens
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                focusNode.requestFocus();
                              });

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: Colors.white),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom, // Adjust for keyboard
                                        left: 16.0,
                                        right: 16.0,
                                        top: 8.0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 3,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                    color: AppColors.hintColor
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    focusNode.unfocus();
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                  )),
                                              Text(
                                                allSelectedPhotos() > 0
                  ? "Add Memory (${allSelectedPhotos()})"
                  : "Add Memory",
                                                style: appTextStyle(
                                                  fm: interRegular,
                                                  fz: 20,
                                                  fw: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                onPressed: () {
                                                  titleController.text =
                                                      memoryTitleController
                                                          .text;
                                                  selectedTitle =
                                                      memoryTitleController
                                                          .text;
                                                  focusNode.unfocus();
                                                  setState(() {});

                                                  viewRefersh();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Next',
                                                  style: appTextStyle(
                                                    fm: interRegular,
                                                    fz: 16,
                                                    color: memoryTitleController
                                                            .text.isNotEmpty
                                                        ? AppColors.violetColor
                                                        : AppColors.hintColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                          Text(
                                            'Memory',
                                            style: appTextStyle(
                                              fm: interRegular,
                                              fz: 14,
                                              fw: FontWeight.w400,
                                              color: AppColors.violetColor,
                                            ),
                                          ).paddingOnly(left: 8, top: 8),
                                          //const SizedBox(height: 5),
                                          TextFormField(
                                            controller: memoryTitleController,
                                            focusNode: focusNode,
                                            showCursor: true,
                                            cursorWidth: 2,cursorHeight: 27,
                              
                    cursorColor: AppColors.primaryColor,
                                            onChanged: (v) {
                                              setState(() {});
                                            },
                                            onFieldSubmitted: (value) {
                                              titleController.text =
                                                  memoryTitleController.text;
                                              selectedTitle =
                                                  memoryTitleController.text;
                                              focusNode.unfocus();
                                              setState(() {});

                                              viewRefersh();
                                              Navigator.pop(context);
                                            },
                                            style: appTextStyle(
                                              fm: interRegular,
                                              fz: 21,
                                              height: 1.3,
                                              color: AppColors.black,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder
                                                  .none, // No underline border
                                              enabledBorder: InputBorder
                                                  .none, // No underline when enabled
                                              focusedBorder: InputBorder.none,
                                              hintText: 'Add memory title here',
                                              hintStyle: appTextStyle(
                                                fm: interRegular,
                                                fz: 21,
                                                height: 1.3,
                                                color: AppColors.hintColor,
                                              ),
                                               contentPadding: EdgeInsets.zero, // Ensure no additional padding
    isDense: true,
                                            ),
                                          ).paddingOnly(left: 8),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        style: appTextStyle(
                          fm: robotoRegular,
                          fz: 21,
                          height: 27 / 21,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: memoryItem.isEmpty
                              ? "Add memory title here"
                              : selectedTitle,
                          hintStyle: appTextStyle(
                            fz: isTitleFocused ? 14 : 21,
                            color: isTitleFocused
                                ? AppColors.primaryColor
                                : AppColors.hintColor,
                            fm: robotoRegular,
                          ),
                        ),
                      ).paddingOnly(left: memoryItem.isEmpty ? 18 : 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: AppColors.textfieldFillColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10),
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
    for (int i = 0; i < photoGroupModel.length; i++) {
      value = value +
          photoGroupModel[i]
              .photos
              .where((photo) => (photo.selectedValue || photo.isEditmemory))
              .length;
    }

    // value = value +
    //     widget.photosList
    //         .where((photo) => (photo.selectedValue || photo.isEditmemory))
    //         .length;
    for (int i = 0; i < fbGroupModel.length; i++) {
      value = value +
          fbGroupModel[i]
              .photos
              .where((photo) => (photo.isSelected || photo.isEdit))
              .length;
    }
    for (int i = 0; i < instaGroupModel.length; i++) {
      value = value +
          instaGroupModel[i]
              .photos
              .where((photo) => (photo.isSelected || photo.isEdit))
              .length;
    }
    for (int i = 0; i < driveGroupModel.length; i++) {
      value = value +
          driveGroupModel[i]
              .photos
              .where((photo) => (photo.isSelected || photo.isEdit))
              .length;
    }
    return value;
  }
  selectedtabView(BuildContext context) {
    if (tabListItem[selectedIndex]['label']  == "All") {
      int tempSelected=widget.selectedCount!;
      widget.selectedCount=0;
      return CommonWidgets.allAlbumView(
       allPhotoGroupModel,
        viewRefersh,
        selectedCount: tempSelected,
        gridIndex:widget.gridItemCount,
      );
    } else if (tabListItem[selectedIndex]['label']  == "Camera Roll") {
     int tempSelected=widget.selectedCount!;
      widget.selectedCount=0;
      return CommonWidgets.albumView(
        photoGroupModel,
        viewRefershOtherTab,
        selectedCount: tempSelected,
        gridIndex:widget.gridItemCount,
      );
    } else if (tabListItem[selectedIndex]['label']  == "Drive") {
      if (driveGroupModel.isEmpty) {
        return CommonWidgets.driveView(context, getDriveView);
      } else {
        return CommonWidgets.drivePhtotView(driveGroupModel, viewRefershOtherTab,
            controller: driveController);
      }
    } else if (tabListItem[selectedIndex]['label']  == "Facebook") {
       if (fbGroupModel.isEmpty) {
        return CommonWidgets.fbView(context, getFacebbokPhoto);
      } else {
        return CommonWidgets.fbPhtotView(fbGroupModel, viewRefershOtherTab);
      }
    } else if (tabListItem[selectedIndex]['label']  == "Photos") {
      if (instaGroupModel.isEmpty) {
        return CommonWidgets.photoView(context, getInstaView);
      } else {
        return CommonWidgets.instaPhtotView(instaGroupModel, viewRefershOtherTab);
      }

 
    }
  }

  void _onScrollEnd() {
    if (driveController.position.pixels >=
        driveController.position.maxScrollExtent) {
      if (PrefUtils.instance.getDriveToken() != null &&
          PrefUtils.instance.getDriveToken()!.isNotEmpty) {
        CommonWidgets.showBottomSheet(context, () {
          CommonWidgets.getFileFromGoogleDrive(context).then((value) {
            getDriveView(value!, PrefUtils.instance.getDriveToken()!);
          });
        });
        // _showLoadMoreSnackbar();
      }
    }
  }

  void _showLoadMoreSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Loading more 30 photos"),
        action: SnackBarAction(
          label: 'Load more',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            CommonWidgets.getFileFromGoogleDrive(context).then((value) {
              getDriveView(value!, PrefUtils.instance.getDriveToken()!);
            });
          },
        ),
      ),
    );
  }

  getFacebbokPhoto(AccessToken token) {
    fetchFacebookPhotos(token);
  }

  getInstaView(String token) {
    instaRequestForAccessToken(token);
  }

 getDriveView(GoogleSignIn v1, String pageToken) {
    fetchPhotosFromDrive(v1, context, pageToken);
  }
  viewRefershOtherTab(){
        allPhotoGroupModel=CommonWidgets.allPhotoGroup(driveGroupModel, instaGroupModel, fbGroupModel, photoGroupModel);
viewRefersh();
  }

  viewRefersh() {
    for (int i = 0; i < allPhotoGroupModel.length; i++) {
      for (int p = 0; p < allPhotoGroupModel[i].photos.length; p++) {
        if (allPhotoGroupModel[i].photos[p].type == "image") {
          updateSelectedValue2(allPhotoGroupModel[i].photos[p].id!,allPhotoGroupModel[i].photos[p].isSelected);
        } else if (allPhotoGroupModel[i].photos[p].type == "insta") {
          updateInstaSelectedValue(
              allPhotoGroupModel[i].photos[p].id!.toString(),allPhotoGroupModel[i].photos[p].isSelected);
        } else if (allPhotoGroupModel[i].photos[p].type == "fb") {
          updateFbSelectedValue(allPhotoGroupModel[i].photos[p].id!.toString(),allPhotoGroupModel[i].photos[p].isSelected);
        } else if (allPhotoGroupModel[i].photos[p].type == "drive") {
          updateDriveSelectedValue(
              allPhotoGroupModel[i].photos[p].id!.toString(),allPhotoGroupModel[i].photos[p].isSelected);
        }
      }
    }

    setState(() {});
  }

  void updateSelectedValue(String selectedId,bool selectedValue) {
    for (int i = 0; i < photoGroupModel.length; i++) {
      for (int j = 0; j < photoGroupModel[i].photos.length; j++) {
        if (photoGroupModel[i].photos[j].assetEntity.id == selectedId) {
          photoGroupModel[i].photos[j].selectedValue = selectedValue;
        }
      }
    }

    setState(() {});
  }

  void updateSelectedValue2(String selectedId,bool selectedValue) {
    for (int k = 0; k < photoGroupModel.length; k++) {
      for (int j = 0; j < photoGroupModel[k].photos.length; j++) {
        if (photoGroupModel[k].photos[j].assetEntity.id == selectedId) {
          photoGroupModel[k].photos[j].selectedValue = selectedValue;
        }
      }
    }

    setState(() {});
  }

  void updateFbSelectedValue(String selectedId,bool selectedValue) {
    print(selectedId);
    for (int j = 0; j < fbGroupModel.length; j++) {
      for (int i = 0; i < fbGroupModel[j].photos.length; i++) {
        if (fbGroupModel[j].photos[i].id == selectedId) {
          fbGroupModel[j].photos[i].isSelected = selectedValue;
        }
      }
    }

    setState(() {});
  }

  void updateInstaSelectedValue(String selectedId,bool selectedValue) {
    for (int j = 0; j < instaGroupModel.length; j++) {
      for (int i = 0; i < instaGroupModel[j].photos.length; i++) {
        if (instaGroupModel[j].photos[i].id == selectedId) {
          instaGroupModel[j].photos[i].isSelected = selectedValue;
        }
      }
    }
    setState(() {});
  }

  void updateDriveSelectedValue(String selectedId,bool selectedValue) {
    for (int j = 0; j < driveGroupModel.length; j++) {
      for (int i = 0; i < driveGroupModel[j].photos.length; i++) {
        if (driveGroupModel[j].photos[i].id == selectedId) {
          driveGroupModel[j].photos[i].isSelected = selectedValue;
        }
      }
    }
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
              selectedTab = tabListItem[index]['label'];
              selectedIndex = index;
              setState(() {});
            },
            child: Container(
                height: 35,
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: selectedIndex != -1 && selectedIndex == index
                        ? AppColors.black
                        : AppColors.selectedTabColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Row(children: [
                            if (tabListItem[index]["icon"] !=
                                null) // Add icon if available
                              FaIcon(tabListItem[index]["icon"],
                                  size: 20,
                                  color: selectedIndex != -1 &&
                                          selectedIndex == index
                                      ? Colors.white
                                      : Colors.black),
                            if (tabListItem[index]["icon"] != null)
                              SizedBox(width: 6),
                          ]),
                    Text(
                      tabListItem[index]["label"],
                      style: appTextStyle(
                          fm: interMedium,
                          height: 27 / 14,
                          fz: 14,
                          color: selectedIndex != -1 && selectedIndex == index
                              ? Colors.white
                              : AppColors.black),
                    )
                  ],
                )),
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
    if (countSelectedPhotos() == 0) {
      progressbarValue = 1.0;
      progressNotifier.value = progressbarValue;
      print(progressbarValue);
      clossProgressDialog('', []);
    }
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);
    EasyLoading.dismiss();
    if (apiType == ApiUrl.categories) {
      categoryModel = CategoryModel.fromJson(jsonDecode(data));
      categoryModel.categories![0].isSelected = true;
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
        clossProgressDialog('', []);

        ApiCall.createMemory(
            api: ApiUrl.createMemory, model: createModel, callack: this);
        // Dismiss the dialog
      }
    } else if (apiType == ApiUrl.createMemory) {
      if (countSelectedPhotos() == 0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('', []);
      }

      deselectAll();
      titleController.text = "";
      labelController.text = "";
      CommonWidgets.successDialog(context, json.decode(data)['message']);
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

      print(data);
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
    int i = 0;

    for (var group in photoGroupModel) {
      i += group.photos
          .where(
              (photo) => (photo.selectedValue && photo.isEditmemory == false))
          .length;
    }

    print("dfasf$i");
    return i;
  }

  int getDrivePhotosCount(List<GroupedPhotoModel> groupedPhotos) {
    int selectedCount = 0;

    for (var group in groupedPhotos) {
      selectedCount += group.photos.where((photo) => photo.isSelected).length;
    }

    return selectedCount;
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

    createModel.categoryId = categoryId;
    createModel.title = titleController.text;
    List<ImagesFile> imageFile = [];

    for (int j = 0; j < photoGroupModel.length; j++) {
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
      for (int i = 0; i < fbGroupModel.length; i++) {
        for (int j = 0; j < fbGroupModel[i].photos.length; j++) {
          if (fbGroupModel[i].photos[j].isSelected &&
              fbGroupModel[i].photos[j].isEdit == false) {
            ImagesFile imp = ImagesFile();
            imp.typeId = fbGroupModel[i].photos[j].id;
            imp.type = fbGroupModel[i].photos[j].type;
            imp.captureDate =
                _getFormattedDateTime(fbGroupModel[i].photos[j].createdTime!);
            imp.description = '';
            imp.link = fbGroupModel[i].photos[j].webLink;

            imp.location = '';
            imageFile.add(imp);
          }
        }
      }
    }
    if (instaGroupModel.isNotEmpty) {
      for (int i = 0; i < instaGroupModel.length; i++) {
        for (int j = 0; j < instaGroupModel[i].photos.length; j++) {
          if (instaGroupModel[i].photos[j].isSelected &&
              instaGroupModel[i].photos[j].isEdit == false) {
            ImagesFile imp = ImagesFile();
            imp.typeId = instaGroupModel[i].photos[j].id;
            imp.type = instaGroupModel[i].photos[j].type;
            imp.captureDate = _getFormattedDateTime(
                instaGroupModel[i].photos[j].createdTime!);
            imp.description = '';
            imp.link = instaGroupModel[i].photos[j].webLink;

            imp.location = '';
            imageFile.add(imp);
          }
        }
      }
    }
    if (driveGroupModel.isNotEmpty) {
      for (int i = 0; i < driveGroupModel.length; i++) {
        for (int j = 0; j < driveGroupModel[i].photos.length; j++) {
          if (driveGroupModel[i].photos[j].isSelected &&
              driveGroupModel[i].photos[j].isEdit == false) {
            ImagesFile imp = ImagesFile();
            imp.typeId = driveGroupModel[i].photos[j].id;
            imp.type = driveGroupModel[i].photos[j].type;
            imp.captureDate = _getFormattedDateTime(
                driveGroupModel[i].photos[j].createdTime!);
            imp.description = '';
            imp.link = driveGroupModel[i].photos[j].webLink;

            imp.location = '';
            imageFile.add(imp);
          }
        }
      }
    }
    createModel.images = imageFile;
    showProgressDialog(context);
    progressNotifier.value = progressbarValue;
    print(createModel.images!.length);

    if (countSelectedPhotos() > 0) {
      processPhotos();
    } else {
      ApiCall.createMemory(
          api: ApiUrl.createMemory, model: createModel, callack: this);
    }
  }

  Future<void> processPhotos() async {
    for (int k = 0; k < photoGroupModel.length; k++) {
      for (int i = 0; i < photoGroupModel[k].photos.length; i++) {
        if (photoGroupModel[k].photos[i].selectedValue &&
            photoGroupModel[k].photos[i].isEditmemory == false) {
          print(photoGroupModel[k].photos[i].assetEntity.id);

          for (int j = 0; j < createModel.images!.length; j++) {
            if (createModel.images![j].typeId ==
                photoGroupModel[k].photos[i].assetEntity.id) {
              // Await the file retrieval and API call
              await FilePath.getFile(photoGroupModel[k].photos[i].assetEntity)
                  .then((value) async {
                print(value!.path);

                ApiCall.uploadImageIntoMemory(
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
    List<PhotoDetailModel> tempPhotoLinks = [];
    if (response.statusCode == 200) {
      // Successfully received the media
      var data = jsonDecode(response.body);
      if (data["data"] != null) {
        showProgressDialog(context);

        // requestStoragePermission();
        await Future.forEach(data["data"], (dynamic element) async {
          if (element["media_type"] == "IMAGE") {
            String capturDate =
                convertTimeStampIntoDateTime(element["timestamp"]);
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
          clossProgressDialog('instagram_synced', tempPhotoLinks);
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

  clossProgressDialog(String type, List<PhotoDetailModel> tempPhotoLinks) {
    if ((progressbarValue * 100).toStringAsFixed(0) == '100') {
      Navigator.pop(context);
      progressbarValue = 0.0;
      uploadCount = 0;
      if (type == "google_drive_synced") {
        if (driveModel.isEmpty) {
          driveModel = tempPhotoLinks;
        } else {
          driveModel.addAll(tempPhotoLinks);
        }
        PrefUtils.instance.saveDrivePhotoLinks(driveModel);
                driveGroupModel = CommonWidgets.groupPhotosByDate(driveModel);


        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == 'facebook_synced') {
        fbModel = tempPhotoLinks;

        fbGroupModel = CommonWidgets.groupPhotosForFBAndINSTAByDate(fbModel);

        PrefUtils.instance.saveFacebookPhotoLinks(tempPhotoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == "instagram_synced") {
        instaModel = tempPhotoLinks;
        instaGroupModel =
            CommonWidgets.groupPhotosForFBAndINSTAByDate(instaModel);

        PrefUtils.instance.saveInstaPhotoLinks(tempPhotoLinks);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      }
      allPhotoGroupModel = CommonWidgets.allPhotoGroup(
        driveGroupModel, instaGroupModel, fbGroupModel, photoGroupModel);
      setState(() {});
    }
  }

//===============Drive===================
  fetchPhotosFromDrive(GoogleSignIn googleSignIn, BuildContext context,
      String? nextPageToken) async {
    try {
      List<PhotoDetailModel> tempPhotoLinks = [];
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
        q: "mimeType='image/png' or mimeType='image/jpeg' or mimeType='image/jpg' and trashed=false and visibility='anyoneWithLink'",
        pageToken: nextPageToken,
        $fields:
            "nextPageToken, files(id, name, webViewLink,thumbnailLink,createdTime, modifiedTime,properties,webContentLink)",
      );
      if (fileList.files != null || fileList.files!.isNotEmpty) {
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
            String captureDate =
                DateFormat('MMM yyyy').format(allFiles[i].createdTime!);

            tempPhotoLinks.add(PhotoDetailModel(
                id: allFiles[i].id,
                createdTime: allFiles[i].createdTime,
                modifiedTime: allFiles[i].modifiedTime,
                isSelected: false,
                isEdit: false,
                type: "drive",
                webLink: allFiles[i].webContentLink,
                thumbnailPath: allFiles[i].thumbnailLink,
                captureDate: captureDate));
            uploadCount += 1;
            progressbarValue = uploadCount / allFiles.length;
            progressNotifier.value = progressbarValue;

            await Future.delayed(const Duration(microseconds: 500));
            setState(() {
              // if (allFiles.length - 1 == i) {
              //   photoLinks.addAll(tempPhotoLinks);
              // }
            });
            clossProgressDialog('google_drive_synced', tempPhotoLinks);
          }
        }

        await Future.delayed(const Duration(microseconds: 500));
      } else {
        PrefUtils.instance.driveToken('');

        CommonWidgets.errorDialog(context, 'No image available in drive');
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);
        clossProgressDialog('', []);
        PrefUtils.instance.driveToken('');

        await Future.delayed(const Duration(seconds: 2), () {});
      }
    } catch (e) {
      CommonWidgets.errorDialog(context, 'No image available in drive');
      progressbarValue = 1.0;
      progressNotifier.value = progressbarValue;
      print(progressbarValue);
      clossProgressDialog('', []);
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
      String captureDate =
          CommonWidgets.daysWithYearRetrun(element.createdTime ?? "");
      tempPhotoLinks.add(PhotoDetailModel(
          type: "fb",
          createdTime: DateTime.tryParse(element.createdTime ?? ""),
          webLink: data['images'][0]["source"],
          captureDate: captureDate,
          id: element.id));
      print(photoLinks);
      uploadCount += 1;
      progressbarValue = uploadCount / faceBook.length;
      progressNotifier.value = progressbarValue;

      await Future.delayed(const Duration(seconds: 2));
      setState(() {});
      clossProgressDialog('facebook_synced', tempPhotoLinks);
    } else {
      throw Exception('Failed to load photos');
    }
  }
}
