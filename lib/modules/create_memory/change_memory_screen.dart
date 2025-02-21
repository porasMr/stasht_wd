import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
import 'package:stasht/image_preview_widget.dart';
import 'package:stasht/modules/create_memory/model/group_modle.dart';
import 'package:stasht/modules/create_memory/model/memory_item.dart';
import 'package:stasht/modules/create_memory/model/sub_category_model.dart';
import 'package:stasht/modules/create_memory/select_memory.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/model/CombinedPhotoModel.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/all_photo_model.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_group_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/aws_s3_upload.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stasht/utils/file_path.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:stasht/utils/progress_dialog.dart';
import 'package:stasht/utils/web_image_preview.dart';

// ignore: must_be_immutable
class ChangeCreateMemoryScreen extends StatefulWidget {
  ChangeCreateMemoryScreen(
      {super.key,
      required this.future,
      required this.photosList,
      this.memoryListData,
      this.title,
      this.memoryId,
      this.cateId,
      this.subId,
      this.userId,
      this.fromEdit,
      required this.isEdit,
      required this.isAddPhoto});
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];

  ScrollController driveController = ScrollController();

  bool isEdit;
  var fromEdit;

  bool isAddPhoto;
  String? title = '';
  String? memoryId = '';
  String? cateId = '';
  String? subId = '';
  String? userId = '';
  List<MemoryListData>? memoryListData = [];

  @override
  State<ChangeCreateMemoryScreen> createState() =>
      _ChangeCreateMemoryScreenState();
}

class _ChangeCreateMemoryScreenState extends State<ChangeCreateMemoryScreen>
    implements ApiCallback {
  List<Map<String, dynamic>> tabListItem = [
//     {"label": "All", "icon": null},
//     {"label": "Camera Roll", "icon": null},
//     {"label": "Drive", "icon": FontAwesomeIcons.googleDrive}, // Example icon
//     {"label": "Facebook", "icon": FontAwesomeIcons.facebookF},
//     {"label": "Photos", "icon": FontAwesomeIcons.fan}, // Example icon
// // Example icon
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
  int categoryIndex = 0;

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
  String memoryImages = '';

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
  String selectedTitle = "";
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
  AllPhotoModel selectedAllPhotoModel = AllPhotoModel();
  bool isImageFullView = true;
  String photoId = "";
  List<AllPhotoModel> selectedPhoto = [];

  void toggleMemoryTitleDropdown() {
    setState(() {
      isMemoryTitleDropdownExpanded = !isMemoryTitleDropdownExpanded;
    });
  }

  void selectMemory(MemoryItem memory) {
    setState(() {
      selectedTitle = memory.title;
      titleController.text = selectedTitle;
      memoryImages = memory.imageUrl;
      memoryId = memory.id;

      isMemoryTitleDropdownExpanded = true;
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

  bool firstSelected = true;

  @override
  void initState() {
    super.initState();
    tabListItem = CommonWidgets.syncTab();
    if (widget.isEdit) {
      isImageFullView = false;
    }

    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      setState(() {});
    });
    // if (widget.fromMediaScreen == false) {

    photoGroupModel = CommonWidgets.groupGalleryPhotosByDate(
        widget.photosList, widget.future);

    PrefUtils.instance.getDrivePrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      driveModel = value;
      driveGroupModel = CommonWidgets.groupPhotosByDate(driveModel);
      viewRefershOtherTab();
    });
    PrefUtils.instance.getFacebookPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      fbModel = value;
      fbGroupModel = CommonWidgets.groupPhotosForFBAndINSTAByDate(fbModel);
      viewRefershOtherTab();
    });
    PrefUtils.instance.getInstaPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      instaModel = value;
      instaGroupModel =
          CommonWidgets.groupPhotosForFBAndINSTAByDate(instaModel);
      viewRefershOtherTab();
    });

    deselectAll();

    EasyLoading.show();
    ApiCall.category(api: ApiUrl.categories, callack: this);
    driveController.addListener(_onScrollEnd);
  }

  selectionOfAllPhoto() {
    titleController.text = widget.title ?? '';
    selectedTitle = widget.title ?? '';
    categoryId = widget.cateId ?? '';
    memoryId = widget.memoryId ?? '';
    subCategoryId = widget.subId ?? '';
    isMemoryTitleDropdownExpanded = true;

    if (subCategoryId.isNotEmpty) {
      for (int sub = 0;
          sub < categoryMemoryModelWithoutPage.subCategories!.length;
          sub++) {
        print(
            "subCategoryId${categoryMemoryModelWithoutPage.subCategories![sub].id == int.parse(subCategoryId)}");

        if (categoryMemoryModelWithoutPage.subCategories![sub].id ==
            int.parse(subCategoryId)) {
          categoryMemoryModelWithoutPage.subCategories![sub].isselected = true;
          selectLabel =
              categoryMemoryModelWithoutPage.subCategories![sub].name!;

          isMemoryLabelDropDownExpanded = true;
        } else {
          categoryMemoryModelWithoutPage.subCategories![sub].isselected = false;
        }
      }
    }

    for (int i = 0; i < categoryModel.categories!.length; i++) {
      print("category${categoryModel.categories![i].name}");

      if (categoryModel.categories![i].id == int.parse(categoryId)) {
        categoryModel.categories![i].isSelected = true;
        categoryId = categoryModel.categories![i].id.toString();
        selectedMemory = categoryModel.categories![i].name!;
        isMemoryCategoryDropDownExpanded = true;
      } else {
        categoryModel.categories![i].isSelected = false;
      }
    }
    for (int p = 0; p < widget.memoryListData!.length; p++) {
      if (widget.memoryListData![p].type == "image") {
        updateSelectedValue(widget.memoryListData![p].typeId!);
      } else if (widget.memoryListData![p].type == "insta") {
        updateInstaSelectedValue2(widget.memoryListData![p].typeId!.toString());
      } else if (widget.memoryListData![p].type == "fb") {
        updateFbSelectedValue2(widget.memoryListData![p].typeId!.toString());
      } else if (widget.memoryListData![p].type == "drive") {
        updateDriveSelectedValue2(widget.memoryListData![p].typeId!.toString());
      }
    }
    viewRefershOtherTab();
    setState(() {});
  }

  void updateSelectedValue(String selectedId) {
    for (int i = 0; i < photoGroupModel.length; i++) {
      for (int j = 0; j < photoGroupModel[i].photos.length; j++) {
        if (photoGroupModel[i].photos[j].assetEntity.id == selectedId) {
          photoGroupModel[i].photos[j].selectedValue = true;
          photoGroupModel[i].photos[j].isEditmemory = true;
        }
      }
    }

    setState(() {});
  }

  void updateFbSelectedValue2(String selectedId) {
    for (int j = 0; j < fbGroupModel.length; j++) {
      for (int i = 0; i < fbGroupModel[j].photos.length; i++) {
        if (fbGroupModel[j].photos[i].id == selectedId) {
          fbGroupModel[j].photos[i].isSelected = true;
          fbGroupModel[j].photos[i].isEdit = true;
        }
      }
    }

    setState(() {});
  }

  void updateInstaSelectedValue2(String selectedId) {
    for (int j = 0; j < instaGroupModel.length; j++) {
      for (int i = 0; i < instaGroupModel[j].photos.length; i++) {
        if (instaGroupModel[j].photos[i].id == selectedId) {
          instaGroupModel[j].photos[i].isSelected = true;
          instaGroupModel[j].photos[i].isEdit = true;
        }
      }
    }
    setState(() {});
  }

  void updateDriveSelectedValue2(String selectedId) {
    for (int j = 0; j < driveGroupModel.length; j++) {
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
    for (var photoGropupList in photoGroupModel) {
      for (var photoList in photoGropupList.photos) {
        photoList.selectedValue = false;
        photoList.isEditmemory = false;
        photoList.isFirst = false;
      }
    }
    if (driveGroupModel.isNotEmpty) {
      for (var groupPhoto in driveGroupModel) {
        for (var photoList in groupPhoto.photos) {
          photoList.isSelected = false;
          photoList.isEdit = false;
          photoList.isFirst = false;
        }
      }
    }
    if (fbGroupModel.isNotEmpty) {
      for (var groupPhoto in fbGroupModel) {
        for (var photoList in groupPhoto.photos) {
          photoList.isSelected = false;
          photoList.isEdit = false;
          photoList.isFirst = false;
        }
      }
    }
    if (instaGroupModel.isNotEmpty) {
      for (var groupPhoto in instaGroupModel) {
        for (var photoList in groupPhoto.photos) {
          photoList.isSelected = false;
          photoList.isEdit = false;
          photoList.isFirst = false;
        }
      }
    }
    viewRefershOtherTab();
    setState(() {});
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
    return MediaQuery(
      data: CommonWidgets.textScale(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: const IgnorePointer(),
          leadingWidth: 0,
          actions: [
            GestureDetector(
              onTap: () {
                if (selectedMemory == "") {
                  CommonWidgets.errorDialog(context, "Please Select Category");
                } else if (selectedTitle == "") {
                  CommonWidgets.errorDialog(
                      context, "Please select or add memory");
                } else if(!widget.isEdit){
                if (allSelectedPhotos() == 0) {
                  CommonWidgets.errorDialog(context, "Please select photo");
                }
                } else {
                  if (selectLabel == "" || subCategoryId != "") {
                    uploadCount = 1;
                    progressbarValue = 0.0;
                    uploadData(getSelectedCategory(), selectedSubCategory());
                  } else {
                    ApiCall.createSubCategory(
                        api: ApiUrl.createSubCategory,
                        name: selectLabel,
                        id: getSelectedCategory(),
                        callack: this);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: widget.isEdit
                    ? Text(
                        "Done",
                        style: appTextStyle(
                            fz: 15,
                            fm: interMedium,
                            color: (
                                    selectedTitle!=""&&selectedMemory!="")
                                ? AppColors.primaryColor
                                : AppColors.greyColor),
                      )
                    : isImageFullView
                        ? Container()
                        : Text(
                            "Next",
                            style: appTextStyle(
                                fz: 17,
                                fm: interMedium,
                                color:
                                 (allSelectedPhotos() > 0 &&
                                        selectedTitle!=""&&selectedMemory!="")
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
                  child: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  )),
              const SizedBox(
                width: 5,
              ),
              Text(
                !widget.isEdit
                    ? "Media"
                    : widget.isAddPhoto
                        ? "Edit Memory"
                        : "Media",
                style: appTextStyle(
                    fz: 20,
                    height: 28 / 22,
                    fm: robotoRegular,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            widget.isEdit
                ? categoryMemoryModelWithoutPage.data == null
                    ? Container()
                    : widget.isAddPhoto
                        ? editingView()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: AppColors.textfieldFillColor,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    if (widget.memoryListData![0].imageLink !=
                                        '')
                                      Row(
                                        children: [
                                          Container(
                                            height: 55,
                                            width: 51,
                                            padding:
                                                const EdgeInsets.only(right: 0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: widget.memoryListData![0]
                                                          .imageLink ==
                                                      ''
                                                  ? const DecorationImage(
                                                      image: AssetImage(
                                                        "assets/images/placeHolder.png",
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        widget
                                                            .memoryListData![0]
                                                            .imageLink!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                    Text(
                                      selectedTitle,
                                      style: appTextStyle(
                                        fm: robotoMedium,
                                        fz: 16,
                                        fw: FontWeight.w500,
                                        color: AppColors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: AppColors.textfieldFillColor,
                              ),
                              if (selectedPhoto.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      height: 60,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: selectedPhoto.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return selectedPhoto[index].type ==
                                                  "image"
                                              ? FutureBuilder<Uint8List?>(
                                                  future: selectedPhoto[index]
                                                      .thumbData,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child: Padding(
                                                        padding:
                                                            EdgeInsets.all(3.0),
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ));
                                                    }
                                                    if (snapshot.data == null) {
                                                      return const Center(
                                                          child: Text(
                                                              'Failed to load image.'));
                                                    }

                                                    return Stack(
                                                      children: [
                                                        Center(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                barrierColor: Colors
                                                                    .transparent,
                                                                builder:
                                                                    (context) {
                                                                  return ImagePreview(
                                                                      assetEntity:
                                                                          selectedPhoto[index]
                                                                              .assetEntity!);
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 60,
                                                              width: 60,
                                                              child:
                                                                  Image.memory(
                                                                snapshot.data!,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      builder: (context) {
                                                        return WebImagePreview(
                                                            path: selectedPhoto[
                                                                    index]
                                                                .webLink!);
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 60,
                                                    width: 60,
                                                    child: ClipRRect(
                                                      child: CachedNetworkImage(
                                                          imageUrl: selectedPhoto[
                                                                          index]
                                                                      .type ==
                                                                  "drive"
                                                              ? selectedPhoto[
                                                                      index]
                                                                  .drivethumbNail!
                                                              : selectedPhoto[
                                                                      index]
                                                                  .webLink!,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context,
                                                                  url) =>
                                                              const SizedBox(
                                                                height: 60,
                                                                width: 60,
                                                                child: Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              )),
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                    )),
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: AppColors.textfieldFillColor,
                              )
                            ],
                          )
                : isImageFullView
                    ? fullImageView()
                    : editingView(),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: tab(),
                  ),
                  Expanded(
                    child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: selectedtabView(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ValueNotifier<Uint8List?> imageBytesNotifier =
      ValueNotifier<Uint8List?>(null);
  void loadImage(AssetEntity img) async {
    final bytes = await img.originBytes;
    imageBytesNotifier.value = bytes;
  }

  Widget fullImageView() {
    return Container(
      height: 300,
      color: AppColors.memoryBackColor.withOpacity(0.8),
      child: Stack(
        children: [
          selectedAllPhotoModel.type == "image"
              ? ValueListenableBuilder<Uint8List?>(
                  valueListenable: imageBytesNotifier,
                  builder: (context, imageData, child) {
                    return Center(
                      child: Container(
                        height: 300,
                        width: 280,
                        color: Colors.grey[200], // Placeholder background
                        child: imageData != null
                            ? Image.memory(
                                imageData,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child:
                                    CircularProgressIndicator()), // Show loader if null
                      ),
                    );
                  },
                )
              : Center(
                  child: SizedBox(
                    height: 300,
                    width: 280,
                    child: CachedNetworkImage(
                      imageUrl: selectedAllPhotoModel.type == "drive"
                          ? selectedAllPhotoModel.drivethumbNail!
                          : selectedAllPhotoModel.webLink!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 300,
                            width: 280,
                            color: Colors
                                .grey[200], // Placeholder background if needed
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                              value: downloadProgress.progress,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          Center(
            child: GestureDetector(
              onTap: () {
                isImageFullView = false;
                setState(() {});
              },
              child: Container(
                width: 380,
                alignment: Alignment.topRight,
                child: Container(
                    margin: const EdgeInsets.only(top: 30),
                    width: 75,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                          color: AppColors.memoeylaneColor,
                        ),
                        Text(
                          "Add",
                          style: TextStyle(
                              color: AppColors.memoeylaneColor,
                              fontFamily: robotoMedium),
                        )
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget editingView() {
    return Column(
      children: [
        const Divider(
          color: AppColors.textfieldFillColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Category",
                        style: appTextStyle(
                          fz: 14,
                          color: AppColors.black,
                          fw: FontWeight.w500,
                          fm: robotoBold,
                        ),
                      ),
                      if (isMemoryCategoryDropDownExpanded)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              selectedMemory,
                              style: appTextStyle(
                                fz: 16,
                                color: AppColors.primaryColor,
                                fw: FontWeight.w400,
                                fm: robotoRegular,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (isMemoryCategoryDropDownExpanded)
                    GestureDetector(
                        onTap: () {
                          isMemoryCategoryDropDownExpanded = false;
                          selectedMemory = "";
                          categoryId = "";
                          if (widget.isEdit) {
                            widget.cateId = '';
                          }
                          setState(() {});
                        },
                        child: const Icon(Icons.close,
                            size: 24, color: AppColors.primaryColor))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              if (isMemoryCategoryDropDownExpanded == false &&
                  categoryModel.categories!.isNotEmpty)
                Container(
                  height: 30,
                  margin: const EdgeInsets.only(bottom: 5),
                  child: FadingEdgeScrollView.fromScrollView(
                    gradientFractionOnEnd: 0.4,
                    child: ListView.separated(
                      controller: ScrollController(),
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 10,
                        );
                      },
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryModel.categories!
                          .where((test) =>
                              test.name != "Shared" && test.name != "Published")
                          .length,
                      itemBuilder: (context, index) {
                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 3, bottom: 3),
                          decoration: BoxDecoration(
                              color: AppColors.hintTextColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8)),
                          child: GestureDetector(
                            onTap: () {
                              categoryIndex = index;
                              selectedMemory =
                                  categoryModel.categories![index].name!;
                              categoryId = categoryModel.categories![index].id
                                  .toString();
                              widget.cateId = categoryId;
                              for (int i = 0;
                                  i < categoryModel.categories!.length;
                                  i++) {
                                if (i == index) {
                                  categoryModel.categories![index].isSelected =
                                      true;
                                } else {
                                  categoryModel.categories![i].isSelected =
                                      false;
                                }
                              }
                              isMemoryCategoryDropDownExpanded = true;
                              memoryItem = [];
                              //categoryMemoryModelWithoutPage.subCategories = [];
                              if (!widget.isEdit) {
                                memoryId = "";
                              }

                           
                              setState(() {});
                              EasyLoading.show();
                              ApiCall.memoryByCategory(
                                  api: ApiUrl.memoryByCategory,
                                  id: categoryId,
                                  sub_category_id: '',
                                  type: 'no_page',
                                  page: "1",
                                  callack: this);
                            },
                            child: Text(
                              categoryModel.categories![index].name!,
                              style: appTextStyle(
                                fm: robotoMedium,
                                fz: 14,
                                fw: FontWeight.w400,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.textfieldFillColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Memory",
                        style: appTextStyle(
                          fz: 14,
                          fw: FontWeight.w500,
                          color: AppColors.black,
                          fm: robotoBold,
                        ),
                      ),
                      if (isMemoryTitleDropdownExpanded)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                if (memoryImages != '')
                                  Row(
                                    children: [
                                      Container(
                                        height: 27,
                                        width: 29,
                                        padding:
                                            const EdgeInsets.only(right: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  AppColors.skeltonBorderColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: memoryImages == ''
                                              ? const DecorationImage(
                                                  image: AssetImage(
                                                    "assets/images/placeHolder.png",
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    memoryImages,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                Text(
                                  selectedTitle,
                                  style: appTextStyle(
                                    fm: robotoRegular,
                                    fz: 16,
                                    fw: FontWeight.w400,
                                    color: AppColors.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Spacer(),
                  isMemoryTitleDropdownExpanded
                      ? GestureDetector(
                          onTap: () {
                            isMemoryTitleDropdownExpanded = false;
                            memoryImages = "";
                            if (!widget.isEdit) {
                              memoryId = "";
                            }
                            selectedTitle = "";

                            setState(() {});
                          },
                          child: const Icon(Icons.close,
                              size: 24, color: AppColors.primaryColor))
                      : widget.isEdit
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SelectMemoryScreen(
                                              memoryItem: memoryItem,
                                            ))).then((value) {
                                  if (value != null) {
                                    selectMemory(value);
                                  }
                                });
                              },
                              child: const Icon(Icons.chevron_right,
                                  size: 24, color: AppColors.black))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  if (isMemoryTitleDropdownExpanded == false)
                    SizedBox(
                      height: 30,
                      child: FadingEdgeScrollView.fromScrollView(
                        gradientFractionOnEnd: 0.4,
                        child: ListView(
                          controller: ScrollController(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () {
                                addMemoryBottomSheet(context);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                 const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      addMemoryBottomSheet(context);
                                    },
                                    child: Text(
                                      "Add Memory",
                                      style: appTextStyle(
                                        fm: interRegular,
                                        fz: 14,
                                        height: 19.2 / 14,
                                        fw: FontWeight.w400,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            widget.isEdit
                                ? Container()
                                : Container(
                                    height: 17,
                                    child: ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(
                                          width: 10,
                                        );
                                      },
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: memoryItem.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        final memory = memoryItem[index];
                                        return GestureDetector(
                                          onTap: () {
                                            // memoryItem.forEach((item) => item.isSelected = false);
                                            // memoryItem[index].isSelected=true;
                                            selectMemory(memory);
                                          },
                                          child: Container(
                                            height: 30,
                                            padding: const EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                                top: 2,
                                                bottom: 2),
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColors.memoryBackColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 27,
                                                  width: 29,
                                                  margin: const EdgeInsets.only(
                                                      right: 0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColors
                                                            .skeltonBorderColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: memory.imageUrl == ''
                                                        ? const DecorationImage(
                                                            image: AssetImage(
                                                              "assets/images/placeHolder.png",
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : DecorationImage(
                                                            image:
                                                                CachedNetworkImageProvider(
                                                              memory.imageUrl,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  memory.title,
                                                  style: appTextStyle(
                                                    fm: robotoRegular,
                                                    fz: 14,
                                                    fw: FontWeight.w500,
                                                    color: AppColors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.textfieldFillColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Add Tag",
                        style: appTextStyle(
                          fz: 14,
                          color: AppColors.black,
                          fw: FontWeight.w500,
                          fm: robotoBold,
                        ),
                      ),
                      if (isMemoryLabelDropDownExpanded)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           const SizedBox(
                              height: 6,
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.subTitleColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.subTitleColor,
                                      width: 1)),
                              child: Text(
                                selectLabel,
                                style: appTextStyle(
                                  fm: robotoRegular,
                                  fz: 16,
                                  fw: FontWeight.w400,
                                  color: AppColors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (isMemoryLabelDropDownExpanded)
                    GestureDetector(
                        onTap: () {
                          isMemoryLabelDropDownExpanded = false;
                          selectLabel = "";
                          if (widget.isEdit) {
                            widget.subId = "";
                          }
                          setState(() {});
                        },
                        child: const Icon(Icons.close,
                            size: 24, color: AppColors.primaryColor))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  if (isMemoryLabelDropDownExpanded == false)
                    SizedBox(
                      height: 35,
                      child: FadingEdgeScrollView.fromScrollView(
                        gradientFractionOnEnd: 0.2,
                        child: ListView(
                          controller: ScrollController(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () {
                                addLableBottomSheet(context);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                const  SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      addLableBottomSheet(context);
                                    },
                                    child: Text(
                                      "Add Tag",
                                      style: appTextStyle(
                                        fm: interRegular,
                                        fz: 14,
                                        height: 19.2 / 14,
                                        fw: FontWeight.w400,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 28,
                              child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    width: 10,
                                  );
                                },
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryMemoryModelWithoutPage
                                    .subCategories!.length,
                                itemBuilder: (context, index) {
                                  final memory = categoryMemoryModelWithoutPage
                                      .subCategories![index];
                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          isMemoryLabelDropDownExpanded = true;

                                          selectLabel = memory.name!;
                                          subCategoryId =
                                              categoryMemoryModelWithoutPage
                                                  .subCategories![index].id
                                                  .toString();
                                          for (int i = 0;
                                              i <
                                                  categoryMemoryModelWithoutPage
                                                      .subCategories!.length;
                                              i++) {
                                            if (index == i) {
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
                                          padding: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 2,
                                              bottom: 2),
                                          decoration: BoxDecoration(
                                              color: AppColors.memoryBackColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              // border: Border.all(
                                              //     color:
                                              //         AppColors.subTitleColor,
                                              //     width: 2)
                                                  ),
                                          child: Text(
                                            memory.name!,
                                            style: appTextStyle(
                                              fm: robotoRegular,
                                              fz: 14,
                                              fw: FontWeight.w400,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 1,
          width: MediaQuery.of(context).size.width,
          color: AppColors.textfieldFillColor,
        ),
        if (selectedPhoto.isNotEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: selectedPhoto.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return selectedPhoto[index].type == "image"
                        ? FutureBuilder<Uint8List?>(
                            future: selectedPhoto[index].thumbData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              if (snapshot.data == null) {
                                return const Center(
                                    child: Text('Failed to load image.'));
                              }

                              return Stack(
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (context) {
                                            return ImagePreview(
                                                assetEntity:
                                                    selectedPhoto[index]
                                                        .assetEntity!);
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (context) {
                                  return WebImagePreview(
                                      path: selectedPhoto[index].webLink!);
                                },
                              );
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              child: ClipRRect(
                                child: CachedNetworkImage(
                                    imageUrl: selectedPhoto[index].type ==
                                            "drive"
                                        ? selectedPhoto[index].drivethumbNail!
                                        : selectedPhoto[index].webLink!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                          height: 60,
                                          width: 60,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        )),
                              ),
                            ),
                          );
                  },
                ),
              )),
        Container(
          height: 1,
          width: MediaQuery.of(context).size.width,
          color: AppColors.textfieldFillColor,
        )
      ],
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
    if (tabListItem[selectedIndex]['label'] == "All") {
      return CommonWidgets.allAlbumView(
          isImageFullView: isImageFullView,
          allPhotoGroupModel,
          viewRefersh, selectedPhoto: (photo) {

        setState(() {
          allPhotoGroupModel = photo;
        viewRefersh();
        });
      }, onClickCheckBox: () {
        setState(() {
          isImageFullView = false;
        });
      }, clearView: () {
        if (isImageFullView) {
          clearPreviousSelection();
        }
      });
    } else if (tabListItem[selectedIndex]['label'] == "Camera Roll") {
      return CommonWidgets.albumView(
          photoGroupModel,
          isImageFullView: isImageFullView,
          viewRefershOtherTab, onClickCheckBox: () {
        setState(() {
          isImageFullView = false;
        });
      }, clearView: () {
        if (isImageFullView) {
          clearPreviousSelection();
        }
      });
    } else if (tabListItem[selectedIndex]['label'] == "Drive") {
      if (driveGroupModel.isEmpty) {
        return CommonWidgets.driveView(context, getDriveView);
      } else {
        return CommonWidgets.drivePhtotView(
            driveGroupModel, viewRefershOtherTab, onClickCheckBox: () {
          setState(() {
            isImageFullView = false;
          });
        }, clearView: () {
          if (isImageFullView) {
            clearPreviousSelection();
          }
        }, isImageFullView: isImageFullView, controller: driveController);
      }
    } else if (tabListItem[selectedIndex]['label'] == "Facebook") {
      if (fbGroupModel.isEmpty) {
        return CommonWidgets.fbView(context, getFacebbokPhoto);
      } else {
        return CommonWidgets.fbPhtotView(fbGroupModel, viewRefershOtherTab,
            isImageFullView: isImageFullView, onClickCheckBox: () {
          setState(() {
            isImageFullView = false;
          });
        }, clearView: () {
          if (isImageFullView) {
            clearPreviousSelection();
          }
        });
      }
    } else if (tabListItem[selectedIndex]['label'] == "Photos") {
      // if (instaGroupModel.isEmpty) {
      return CommonWidgets.driveView(context, getPhotoView);

      // } else {
      //   return CommonWidgets.instaPhtotView(
      //     instaGroupModel,
      //     viewRefershOtherTab,
      //     isImageFullView: isImageFullView,
      //     clearView: (){
      //   if(isImageFullView){
      //   clearPreviousSelection();
      //   }
      // }
      //   );
      // }
    }
  }

  void _onScrollEnd() {
    print("scroll end");
    if (driveController.position.pixels >=
        driveController.position.maxScrollExtent) {
      if (PrefUtils.instance.getDriveToken() != null &&
          PrefUtils.instance.getDriveToken()!.isNotEmpty) {
        CommonWidgets.showBottomSheet(context, () {
          CommonWidgets.getFileFromGoogleDrive(context).then((value) {
            getDriveView(value!, PrefUtils.instance.getDriveToken()!);
          });
        });
        //_showLoadMoreSnackbar();
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

  getPhotoView(GoogleSignIn v1, String pageToken) async {
    var httpClient = await v1.authenticatedClient();
    if (httpClient == null) {
      print('Failed to get authenticated client');
      return null;
    }
    // Create a Picker Session

    final response = await http.post(
      Uri.parse('https://photoslibrary.googleapis.com/v1/sessions'),
      headers: {
        'Authorization': 'Bearer ${httpClient.credentials.accessToken.data}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "filters": {
          "mediaTypeFilter": {
            "mediaTypes": ["PHOTO"]
          }
        }
      }),
    );
    print(response.body);

//   final pickerUri = jsonDecode(response.body)['pickerUri'];

// callBack(pickerUri);
  }

  getDriveView(GoogleSignIn v1, String pageToken) {
    fetchPhotosFromDrive(v1, context, pageToken);
  }

  viewRefershOtherTab() {
    allPhotoGroupModel = CommonWidgets.allPhotoGroup(
        driveGroupModel, instaGroupModel, fbGroupModel, photoGroupModel);
    viewRefersh();
  }

  viewRefersh() {
    if (!widget.isEdit) {
      bool isGet = false;
      for (int i = 0; i < allPhotoGroupModel.length; i++) {
        for (int p = 0; p < allPhotoGroupModel[i].photos.length; p++) {
          if (allPhotoGroupModel[i].photos[p].isFirst) {
            selectedAllPhotoModel = allPhotoGroupModel[i].photos[p];
            if (selectedAllPhotoModel.type == "image") {
              loadImage(selectedAllPhotoModel.assetEntity!);
            }
            isGet = true;
            break;
          }
        }
      }
      print("sdad$isGet");
      if (!isGet) {
        allPhotoGroupModel[0].photos[0].isFirst = true;

        selectedAllPhotoModel = allPhotoGroupModel[0].photos[0];
        if (selectedAllPhotoModel.type == "image") {
          loadImage(selectedAllPhotoModel.assetEntity!);
        }
      }
    }

    selectedPhoto = [];
    for (int i = 0; i < allPhotoGroupModel.length; i++) {
      for (int p = 0; p < allPhotoGroupModel[i].photos.length; p++) {
        if (allPhotoGroupModel[i].photos[p].isSelected) {
          selectedPhoto.add(allPhotoGroupModel[i].photos[p]);
        }
        if (allPhotoGroupModel[i].photos[p].type == "image") {
          updateSelectedValue2(
              allPhotoGroupModel[i].photos[p].id!,
              allPhotoGroupModel[i].photos[p].isSelected,
              allPhotoGroupModel[i].photos[p].isFirst);
        } else if (allPhotoGroupModel[i].photos[p].type == "insta") {
          updateInstaSelectedValue(
              allPhotoGroupModel[i].photos[p].id!.toString(),
              allPhotoGroupModel[i].photos[p].isSelected,
              allPhotoGroupModel[i].photos[p].isFirst);
        } else if (allPhotoGroupModel[i].photos[p].type == "fb") {
          updateFbSelectedValue(
              allPhotoGroupModel[i].photos[p].id!.toString(),
              allPhotoGroupModel[i].photos[p].isSelected,
              allPhotoGroupModel[i].photos[p].isFirst);
        } else if (allPhotoGroupModel[i].photos[p].type == "drive") {
          updateDriveSelectedValue(
              allPhotoGroupModel[i].photos[p].id!.toString(),
              allPhotoGroupModel[i].photos[p].isSelected,
              allPhotoGroupModel[i].photos[p].isFirst);
        }
      }
    }
    firstSelected = false;
    setState(() {});
  }

  clearPreviousSelection() {
    if (allPhotoGroupModel.isNotEmpty) {
      for (int i = 0; i < allPhotoGroupModel.length; i++) {
        for (int p = 0; p < allPhotoGroupModel[i].photos.length; p++) {
           allPhotoGroupModel[i].photos[p].isFirst=false;
          if (allPhotoGroupModel[i].photos[p].type == "image") {
            for (int k = 0; k < photoGroupModel.length; k++) {
              for (int j = 0; j < photoGroupModel[k].photos.length; j++) {
                photoGroupModel[k].photos[j].isFirst = false;
              }
            }
          } else if (allPhotoGroupModel[i].photos[p].type == "insta") {
            for (int j = 0; j < instaGroupModel.length; j++) {
              for (int i = 0; i < instaGroupModel[j].photos.length; i++) {
                instaGroupModel[j].photos[i].isFirst = false;
              }
            }
          } else if (allPhotoGroupModel[i].photos[p].type == "fb") {
            for (int j = 0; j < fbGroupModel.length; j++) {
              for (int i = 0; i < fbGroupModel[j].photos.length; i++) {
                fbGroupModel[j].photos[i].isFirst = false;
              }
            }
          } else if (allPhotoGroupModel[i].photos[p].type == "drive") {
            for (int j = 0; j < driveGroupModel.length; j++) {
              for (int i = 0; i < driveGroupModel[j].photos.length; i++) {
                driveGroupModel[j].photos[i].isFirst = false;
              }
            }
          }
        }
      }
    }

    setState(() {});
  }

  void updateSelectedValue2(
      String selectedId, bool selectedValue, bool isFirst) {
    for (int k = 0; k < photoGroupModel.length; k++) {
      for (int j = 0; j < photoGroupModel[k].photos.length; j++) {
        if (photoGroupModel[k].photos[j].assetEntity.id == selectedId) {
          photoGroupModel[k].photos[j].selectedValue = selectedValue;
          photoGroupModel[k].photos[j].isFirst = isFirst;
        }
      }
    }

    setState(() {});
  }

  void updateFbSelectedValue(
      String selectedId, bool selectedValue, bool isFirst) {
    print(selectedId);
    for (int j = 0; j < fbGroupModel.length; j++) {
      for (int i = 0; i < fbGroupModel[j].photos.length; i++) {
        if (fbGroupModel[j].photos[i].id == selectedId) {
          fbGroupModel[j].photos[i].isSelected = selectedValue;
          fbGroupModel[j].photos[i].isFirst = isFirst;
        }
      }
    }

    setState(() {});
  }

  void updateInstaSelectedValue(
      String selectedId, bool selectedValue, bool isFirst) {
    for (int j = 0; j < instaGroupModel.length; j++) {
      for (int i = 0; i < instaGroupModel[j].photos.length; i++) {
        if (instaGroupModel[j].photos[i].id == selectedId) {
          instaGroupModel[j].photos[i].isSelected = selectedValue;
          instaGroupModel[j].photos[i].isFirst = isFirst;
        }
      }
    }
    setState(() {});
  }

  void updateDriveSelectedValue(
      String selectedId, bool selectedValue, bool isFirst) {
    for (int j = 0; j < driveGroupModel.length; j++) {
      for (int i = 0; i < driveGroupModel[j].photos.length; i++) {
        if (driveGroupModel[j].photos[i].id == selectedId) {
          driveGroupModel[j].photos[i].isSelected = selectedValue;
          driveGroupModel[j].photos[i].isFirst = isFirst;
        }
      }
    }
    setState(() {});
  }

  //------------Tab function---------------
  tab() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 16,
          );
        },
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
                height: 36,
                padding: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: selectedIndex != -1 && selectedIndex == index
                        ? AppColors.black
                        : AppColors.selectedTabColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      if (tabListItem[index]["icon"] !=
                          null) // Add icon if available
                        FaIcon(tabListItem[index]["icon"],
                            size: 22,
                            color: selectedIndex != -1 && selectedIndex == index
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
    print(apiType);
    if (apiType == ApiUrl.categories) {
      categoryModel = CategoryModel.fromJson(jsonDecode(data));
      int k = 0;
      if (selectedMemory == "") {
        categoryModel.categories![k].isSelected = true;
        categoryId = categoryModel.categories![k].id.toString();
        selectedMemory = categoryModel.categories![k].name!;
        isMemoryCategoryDropDownExpanded = true;
      }
      if (categoryModel.categories != null &&
          categoryModel.categories!.isNotEmpty) {
        for (var category in categoryModel.categories!) {
          if (category.name != "Shared" && category.name != "Published") {
            memoryOptions.add(category.name!);
          }
        }
      }

      ApiCall.memoryByCategory(
          api: ApiUrl.memoryByCategory,
          id: categoryId,
          sub_category_id: '',
          type: 'no_page',
          page: "1",
          callack: this);
    } else if (apiType == ApiUrl.memoryByCategory) {
      debugPrint("Memory By Categories Api hit");
      setState(() {
        EasyLoading.dismiss();
      });

      categoryMemoryModelWithoutPage =
          CategoryMemoryModelWithoutPage.fromJson(jsonDecode(data));
      if (categoryMemoryModelWithoutPage.data!.isNotEmpty) {
        for (var memory in categoryMemoryModelWithoutPage.data!) {
          memoryItem.add(MemoryItem(
              imageUrl: memory.lastUpdateImg ?? '',
              title: memory.title!,
              id: memory.id.toString()));
        }
      } else {
        memoryItem = [];
      }
      if (categoryMemoryModelWithoutPage.subCategories!.isNotEmpty) {
        //categoryMemoryModelWithoutPage.subCategories![0].isselected = true;

        if (categoryMemoryModelWithoutPage.subCategories != null) {
          for (var subCategory
              in categoryMemoryModelWithoutPage.subCategories!) {
            memoryLabel.add(subCategory.name ?? "");
            //selectLabel = memoryLabel[0];
          }
        }
      } else {
        memoryLabel = [];
      }
      if (widget.isEdit) {
        selectionOfAllPhoto();
      }
      EasyLoading.dismiss();

      setState(() {});
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

        clossProgressDialog('', []);
      }

      deselectAll();
      titleController.text = "";
      labelController.text = "";
      if (widget.isEdit) {
        Navigator.pop(context, photoId);
      } else {
        Navigator.pop(context, categoryIndex);
      }

      CommonWidgets.successDialog(context, json.decode(data)['message']);

      print(data);
    } else if (apiType == ApiUrl.updateMemory) {
      if (countSelectedPhotos() == 0) {
        progressbarValue = 1.0;
        progressNotifier.value = progressbarValue;
        print(progressbarValue);

        clossProgressDialog('', []);
      }
      deselectAll();
      titleController.text = "";
      labelController.text = "";
      if (widget.isEdit) {
        Navigator.pop(context, photoId);
      } else {
        Navigator.pop(context, categoryIndex);
      }
      CommonWidgets.successDialog(context, json.decode(data)['message']);
    } else if (apiType == ApiUrl.createSubCategory) {
      SubCategoryResModel subCategoryResModel =
          SubCategoryResModel.fromJson(json.decode(data));
      uploadCount = 1;
      progressbarValue = 0.0;
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
    if (memoryId != '') {
      createModel.memoryId = memoryId;
    }
    createModel.categoryId = categoryId;
    createModel.subCategoryId = subCategoryId;
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
          photoId = photoGroupModel[j].photos[i].assetEntity.id;

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
            photoId = fbGroupModel[i].photos[j].id;
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
            photoId = instaGroupModel[i].photos[j].id;

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
            photoId = driveGroupModel[i].photos[j].id;

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
      clossProgressDialog('', []);
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
      //  CommonWidgets.fetchPaginatedGooglePhotos(httpClient.credentials.accessToken.data);
      showProgressDialog(context);

      //     final api = PhotosLibraryApi(httpClient);

      // // Example: List albums
      // var albums = await api.albums.list(pageSize: 10);
      // print("Albums:${albums.albums!.length}");
      // for (var album in albums.albums ?? []) {
      //   print(album.title);
      // }

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
    // EasyLoading.show(status: 'Processing');
    tempPhotoLinks.clear();
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
      if (tempPhotoLinks.isNotEmpty) {
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
      print(tempPhotoLinks);
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

  addMemoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController memoryTitleController = TextEditingController();
        FocusNode focusNode = FocusNode();

        // Ensure the keyboard is displayed when the bottom sheet opens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });

        return StatefulBuilder(builder: ((context, setState) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                            color: AppColors.hintColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5)),
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
                        'Add Memory',
                        style: appTextStyle(
                          fm: interRegular,
                          fz: 20,
                          fw: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          titleController.text = memoryTitleController.text;
                          selectedTitle = memoryTitleController.text;
                          isMemoryTitleDropdownExpanded = true;

                          memoryImages = "";
                          if (!widget.isEdit) {
                            memoryId = "";
                          }
                          focusNode.unfocus();
                          viewRefersh();

                          Navigator.pop(context);
                        },
                        child: Text(
                          'Next',
                          style: appTextStyle(
                            fm: interRegular,
                            fz: 16,
                            color: memoryTitleController.text.isNotEmpty
                                ? AppColors.violetColor
                                : AppColors.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  Text(
                    'Memory',
                    style: appTextStyle(
                      fm: interRegular,
                      fz: 14,
                      fw: FontWeight.w400,
                      color: AppColors.violetColor,
                    ),
                  ).paddingOnly(left: 10, top: 8),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: memoryTitleController,
                    focusNode: focusNode,
                    showCursor: true,
                    cursorWidth: 2,
                    cursorHeight: 27,
                    cursorColor: AppColors.primaryColor,
                    onFieldSubmitted: (v) {
                      titleController.text = memoryTitleController.text;
                      selectedTitle = memoryTitleController.text;
                      isMemoryTitleDropdownExpanded = true;
                      memoryImages = "";
                      if (!widget.isEdit) {
                        memoryId = "";
                      }
                      focusNode.unfocus();
                      viewRefersh();

                      Navigator.pop(context);
                    },
                    onChanged: (c) {
                      setState(() {});
                    },
                    style: appTextStyle(
                      fm: interRegular,
                      fz: 21,
                      height: 1.3,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        border: InputBorder.none, // No underline border
                        enabledBorder:
                            InputBorder.none, // No underline when enabled
                        focusedBorder: InputBorder.none,
                        hintText: 'Enter your memory title',
                        hintStyle: appTextStyle(
                          fm: interRegular,
                          fz: 21,
                          height: 1.3,
                          color: AppColors.hintColor,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true),
                  ).paddingOnly(left: 8),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }));
      },
    );
  }

  addLableBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController memoryTitleController = TextEditingController();
        FocusNode focusNode = FocusNode();

        // Ensure the keyboard is displayed when the bottom sheet opens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24), color: Colors.white),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                              color: AppColors.hintColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5)),
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
                          'Add Tag',
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
                            labelController.text = memoryTitleController.text;
                            selectLabel = memoryTitleController.text;
                            isMemoryLabelDropDownExpanded = true;
                            subCategoryId = "";
                            focusNode.unfocus();
                            viewRefersh();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Next',
                            style: appTextStyle(
                              fm: interRegular,
                              fz: 16,
                              color: memoryTitleController.text.isNotEmpty
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
                      'Tag Title',
                      style: appTextStyle(
                        fm: interRegular,
                        fz: 14,
                        fw: FontWeight.w400,
                        color: AppColors.violetColor,
                      ),
                    ).paddingOnly(left: 8, top: 8),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: memoryTitleController,
                      focusNode: focusNode,
                      showCursor: true,
                      cursorWidth: 2,
                      cursorHeight: 27,
                      cursorColor: AppColors.primaryColor,
                      onFieldSubmitted: (v) {
                        labelController.text = memoryTitleController.text;
                        selectLabel = memoryTitleController.text;
                        isMemoryLabelDropDownExpanded = true;
                        subCategoryId = "";
                        focusNode.unfocus();
                        viewRefersh();
                        Navigator.pop(context);
                      },
                      style: appTextStyle(
                        fm: interRegular,
                        fz: 21,
                        height: 1.3,
                        color: Colors.black,
                      ),
                      onChanged: (c) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          hintText: 'Enter your label title',
                          border: InputBorder.none, // No underline border
                          enabledBorder:
                              InputBorder.none, // No underline when enabled
                          focusedBorder: InputBorder.none,
                          hintStyle: appTextStyle(
                            fm: interRegular,
                            fz: 21,
                            height: 1.3,
                            color: AppColors.hintColor,
                          ),
                          contentPadding: EdgeInsets.zero,
                          isDense: true),
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
  }
}
