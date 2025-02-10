import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stasht/bottom_bar_visibility_provider.dart';
import 'package:stasht/image_preview_widget.dart';
import 'package:stasht/modules/create_memory/create_memory_copy.dart';
import 'package:stasht/modules/create_memory/model/group_modle.dart';
import 'package:stasht/modules/create_memory/new_memory.dart';
import 'package:stasht/modules/invite_collaborator/invite_collaborator_screen.dart';

import 'package:stasht/modules/media/model/CombinedPhotoModel.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
import 'package:stasht/modules/onboarding/domain/model/all_photo_model.dart';
import 'package:stasht/modules/onboarding/domain/model/favebook_photo.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';
import 'package:stasht/modules/onboarding/domain/model/photo_group_model.dart';
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
import 'package:stasht/utils/web_image_preview.dart';
import '../create_memory/model/sub_category_model.dart';
import 'model/phot_mdoel.dart';

// ignore: must_be_immutable

class MediaScreen extends StatefulWidget {
  MediaScreen(
      {super.key,
      required this.future,
      required this.photosList,
      required this.isFromSignUp,
      required this.type});
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];
  List<PhotoModel> isFrom = [];
  bool isFromSignUp;
  String type;

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> implements ApiCallback {
   List<Map<String, dynamic>> tabListItem = [
    
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
  ScrollController driveController = ScrollController();
  List<AllPhotoModel> selectedPhoto = [];

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

  //-------------Drive group model-------
//--------------_Drive group model================
  List<GroupedPhotoModel> driveGroupModel = [];
  List<GroupedPhotoModel> instaGroupModel = [];
  List<GroupedPhotoModel> fbGroupModel = [];
  List<PhotoGroupModel> photoGroupModel = [];

  List<CombinedPhotoModel> allPhotoGroupModel = [];
  String selectedTitle="";
  bool isOneSelect=false;

  @override
  void dispose() {
    titleFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tabListItem=CommonWidgets.syncTab();
    photoGroupModel = CommonWidgets.groupGalleryPhotosByDate(
        widget.photosList, widget.future);

    PrefUtils.instance.getDrivePrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      driveModel = value;
      driveGroupModel = CommonWidgets.groupPhotosByDate(driveModel);

      changeTab();
    });
    PrefUtils.instance.getFacebookPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      print(value.length);
      fbModel = value;
      fbGroupModel = CommonWidgets.groupPhotosForFBAndINSTAByDate(fbModel);

      changeTab();
    });
    PrefUtils.instance.getInstaPrefs().then((value) {
      for (var photoList in value) {
        photoList.isSelected = false;
      }
      instaModel = value;
      instaGroupModel =
          CommonWidgets.groupPhotosForFBAndINSTAByDate(instaModel);

     changeTab();
    });
    openDialogFirstTime();
    deselectAll();
    EasyLoading.show();
    ApiCall.category(api: ApiUrl.categories, callack: this);
    driveController.addListener(_onScrollEnd);
  }

  
  openDialogFirstTime() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (widget.isFromSignUp) {
        showFirstMemoryDialog(context);
      }
    });
  }

  changeTab() {
    allPhotoGroupModel = CommonWidgets.allPhotoGroup(
        driveGroupModel, instaGroupModel, fbGroupModel, photoGroupModel);
    if (widget.isFromSignUp) {
      //  Future.delayed(const Duration(milliseconds: 500), () async {
      print(widget.type);

      if (PrefUtils.instance.getSelectedtype() == 'instagram_synced') {
        selectedIndex = 2;
        setState(() {});
      } else if (PrefUtils.instance.getSelectedtype() == 'facebook_synced') {
        selectedIndex = 2;
        setState(() {});
      } else if (PrefUtils.instance.getSelectedtype() == 'google_drive_synced') {
        selectedIndex = 2;
        setState(() {});
      }
       else {
        selectedIndex = 0;
        setState(() {});
      }
      //   });
    }
            setState(() {});

  }
  

  void deselectAll() {
    selectedMemoryId = "";
    for (var photoGropupList in photoGroupModel) {
      for (var photoList in photoGropupList.photos) {
        photoList.selectedValue = false;
        photoList.isEditmemory = false;
      }
    }
    if (driveGroupModel.isNotEmpty) {
      for (var groupPhoto in driveGroupModel) {
        for (var photoList in groupPhoto.photos) {
          photoList.isSelected = false;
          photoList.isEdit = false;
        }
      }
    }
    if (fbGroupModel.isNotEmpty) {
      for (var groupPhoto in fbGroupModel) {
        for (var photoList in groupPhoto.photos) {
          photoList.isSelected = false;
          photoList.isEdit = false;
        }
      }
    }
    if (instaGroupModel.isNotEmpty) {
      for (var groupPhoto in instaGroupModel) {
        for (var photoList in groupPhoto.photos) {
          photoList.isSelected = false;
          photoList.isEdit = false;
        }
      }
    }
    allPhotoGroupModel = CommonWidgets.allPhotoGroup(
        driveGroupModel, instaGroupModel, fbGroupModel, photoGroupModel);
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
                                      data:CommonWidgets.textScale(context),

      child: Scaffold(
        backgroundColor: Colors.white,
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
                        if(isOneSelect){
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
                        }else{
      
                        
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => PhotosView(
                                      photosList: widget.photosList,
                                      isSkip: false,
                                    )));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          isOneSelect?AppStrings.next:
                          AppStrings.skip,
                          style: appTextStyle(
                              fz: 17,
                              fm: interMedium,
                              color:isOneSelect?AppColors.primaryColor: AppColors.hintColor),
                        ),
                      ))
                ],
                title: Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      isOneSelect?"Add Memory (${selectedPhoto.length})":
                      "Photos",
                      style: appTextStyle(
                          fz: 20,
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
            if(isOneSelect)
            Column(mainAxisSize: MainAxisSize.min,
              children: [ const Divider(
              color: AppColors.textfieldFillColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5,),
                       Text(
                          "Memory",
                            style: appTextStyle(
                                fz: 14,
                                color: AppColors.black,
                                fw:FontWeight.w500,
                                
                          
                                fm: robotoBold,
                                
                              ),
                        ),
                          
                        Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 5,),
                          Row(
                            children: [
                          
                                Row(
                                  children: [
                                    Container(
                                      height: 27,
                                      width: 29,
                                      padding: const EdgeInsets.only(right: 0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.skeltonBorderColor),
                                        borderRadius: BorderRadius.circular(10),
                                      
                                        color:  Colors.white,
                                      ),
                                      child: selectedPhoto[0].type == "image"
                              ? FutureBuilder<Uint8List?>(
                                  future: selectedPhoto[0].thumbData,
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
                                            
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                               height: 27,
                                                                                width: 29,
                                                child: Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                ),
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
                                    
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 27,
                                        width: 29,
                                      child: CachedNetworkImage(
                                          imageUrl: selectedPhoto[0].type ==
                                                  "drive"
                                              ? selectedPhoto[0].drivethumbNail!
                                              : selectedPhoto[0].webLink!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>const SizedBox(
                                                height: 27,
                                      width: 29,
                                                child:  Center(
                                                  child: CircularProgressIndicator(
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                              )),
                                    ),
                                  ),
                                ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              GestureDetector(onTap: (){
                                                           addMemoryBottomSheet(context,titleController.text);

                              },
                                child: Text(
                                  titleController.text,
                                  style: appTextStyle(
                                    fm: robotoRegular,
                                    fz: 16,
                                    fw: FontWeight.w400,
                                    color: AppColors.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                       const SizedBox(
                      height: 10,
                    ),
                        ],
                      ),
                     
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                          onTap: () {
                           addMemoryBottomSheet(context,titleController.text);
                          },
                          child: const Icon(Icons.close,
                              size: 24, color: AppColors.primaryColor))


                ],
              ),
            ),
             Container(height: 1,width: MediaQuery.of(context).size.width,
              color: AppColors.textfieldFillColor,
            ),],),
             if (selectedPhoto.isNotEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                      placeholder: (context, url) =>const SizedBox(
                                            height: 60,
                                            width: 60,
                                            child:  Center(
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
            Container(height: 1,width: MediaQuery.of(context).size.width,
              color: AppColors.textfieldFillColor,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 16),
              child: tab(),
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left:16.0,right: 16,bottom:8,top: 16),
                    child: selectedtabView(context))),
          ],
        ),
      ),
    );
  }

  selectedtabView(BuildContext context) {
    if (tabListItem[selectedIndex]['label']  == "All") {
      debugPrint("Index is 0");
      return CommonWidgets.allAlbumView(allPhotoGroupModel, viewRefersh,
          selectedCountNotifier: selectedCountNotifier
          );
    } else if (tabListItem[selectedIndex]['label']  == "Camera Roll") {
      return CommonWidgets.albumView(photoGroupModel, viewRefershOtherTab,
          selectedCountNotifier: selectedCountNotifier);
    } else if (tabListItem[selectedIndex]['label']  == "Drive") {
      if (driveGroupModel.isEmpty) {
        return CommonWidgets.driveView(context, getDriveView);
      } else {
        return CommonWidgets.drivePhtotView(driveGroupModel, viewRefershOtherTab,
            selectedCountNotifier: selectedCountNotifier,
            controller: driveController);
      }
    } else if (tabListItem[selectedIndex]['label']  == "Facebook") {
      if (fbGroupModel.isEmpty) {
        return CommonWidgets.fbView(context, getFacebbokPhoto);
      } else {
        return CommonWidgets.fbPhtotView(fbGroupModel, viewRefershOtherTab,
            selectedCountNotifier: selectedCountNotifier);
      }
    } else if (tabListItem[selectedIndex]['label']  == "Photos") {
      if (instaGroupModel.isEmpty) {
        return CommonWidgets.photoView(context, getInstaView);
      } else {
        return CommonWidgets.instaPhtotView(instaGroupModel, viewRefershOtherTab,
            selectedCountNotifier: selectedCountNotifier);
      }
    }
  }

  addMemoryBottomSheet(BuildContext context,selectedTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController memoryTitleController = TextEditingController(text:selectedTitle);
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
                          fw: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                                                     titleController.text = memoryTitleController.text;
                      selectedTitle = memoryTitleController.text;
                      memoryId = "";
                      isOneSelect=true;
                      focusNode.unfocus();
                      viewRefersh();

                      Navigator.pop(context);

                        },
                        child: Text(
                          'Next',
                          style: appTextStyle(
                            fm: interRegular,
                            fz: 15,
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
                      memoryId = "";
                                            isOneSelect=true;

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
        // behavior: SnackBarBehavior.floating,

        content: const Text("Loading another 30 images"),
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

  viewRefershOtherTab() {
    allPhotoGroupModel = CommonWidgets.allPhotoGroup(
        driveGroupModel, instaGroupModel, fbGroupModel, photoGroupModel);
    viewRefersh();
  }

  viewRefersh() {
selectedPhoto=[];
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
if(isOneSelect==false){
  addMemoryBottomSheet(context, "");
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


  // viewRefersh() {
  //   setState(() {
      
  //   });
    //setState(() {});
  //   int selectedCount = 0;
  //   int gridItemCount=0;
  //   if (selectedIndex == 1) {
  //     for (int j = 0; j < photoGroupModel.length; j++) {
  //       for (int i = 0; i < photoGroupModel[j].photos.length; i++) {
  //         if (photoGroupModel[j].photos[i].selectedValue) {
  // selectedCount = j;
  //           gridItemCount=i;          }
  //       }
  //     }
  //   } else {
  //     for (int j = 0; j < allPhotoGroupModel.length; j++) {
  //       for (int i = 0; i < allPhotoGroupModel[j].photos.length; i++) {
  //         if (allPhotoGroupModel[j].photos[i].isSelected) {
  //           selectedCount = j;
  //           gridItemCount=i;
  //         } 
  //       }
  //     }
  //   }
  //   if (widget.isFromSignUp) {
  //     print(widget.type);
  //     Navigator.push(
  //       context,
  //       PageRouteBuilder(
  //         transitionDuration:
  //             Duration(milliseconds: 800), // Adjust animation duration
  //         pageBuilder: (context, animation, secondaryAnimation) =>
  //             NewMemoryScreen(
  //           photosList: widget.photosList,
  //           future: widget.future,
  //           driveGroupModel: driveGroupModel,
  //           instaGroupModel: instaGroupModel,
  //           fbGroupModel: fbGroupModel,
  //           selectedIndexTab: selectedIndex,
  //           selectedCount: selectedCount,
  //                                                           gridItemCount: gridItemCount,

  //           photoGroupModel: photoGroupModel,
  //           allPhotoGroupModel: allPhotoGroupModel,
  //         ),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           const begin = Offset(0.0, 1.0); // Start at the bottom
  //           const end = Offset.zero; // End at the center
  //           const curve = Curves.easeInOut;

  //           var tween =
  //               Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //           var offsetAnimation = animation.drive(tween);

  //           return SlideTransition(
  //             position: offsetAnimation,
  //             child: child,
  //           );
  //         },
  //       ),
  //     ).then((value) {
  //       deselectAll();
  //       widget.type = "";
  //       setState(() {});
  //     });
  //     debugPrint("This One Invoekd");
  //   } else {
    
  //     debugPrint("Total Selected photos are $selectedCount");
  //     Navigator.push(
  //       context,
  //       PageRouteBuilder(
  //         transitionDuration:
  //             Duration(milliseconds: 800), // Adjust animation duration
  //         pageBuilder: (context, animation, secondaryAnimation) =>
  //             CreateMemoryCopyScreen(
  //           photosList: widget.photosList,
  //           future: widget.future,
  //           isBack: true,
  //           fromMediaScreen: true,
  //           driveGroupModel: driveGroupModel,
  //           instaGroupModel: instaGroupModel,
  //           fbGroupModel: fbGroupModel,
  //           photoGroupModel: photoGroupModel,
  //                       selectedCount: selectedCount,
  //                                               gridItemCount: gridItemCount,


  //           selectedIndexTab: selectedIndex,
  //           allPhotoGroupModel: allPhotoGroupModel,
  //         ),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           const begin = Offset(0.0, 1.0); // Start at the bottom
  //           const end = Offset.zero; // End at the center
  //           const curve = Curves.easeInOut;

  //           var tween =
  //               Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //           var offsetAnimation = animation.drive(tween);

  //           return SlideTransition(
  //             position: offsetAnimation,
  //             child: child,
  //           );
  //         },
  //       ),
  //     ).then((value) {
  //       deselectAll();
  //       widget.type = "";
  //       for (var photo in widget.photosList) {
  //         photo.selectedValue = false;
  //       }
  //       setState(() {});
  //     });
  //   }
 // }

  //------------Tab function---------------
  tab() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(width: 16,);
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
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.only(left: 10, right: 10),
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
      EasyLoading.dismiss();
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

      setState(() {});
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

      CommonWidgets.successDialog(context, json.decode(data)['message']);
      setState(() {});
    } else if (apiType == ApiUrl.syncAccount) {
      setState(() {});
    } else if (apiType == ApiUrl.createSubCategory) {
      SubCategoryResModel subCategoryResModel =
          SubCategoryResModel.fromJson(json.decode(data));
      uploadData(
          selectedCategoryId(), subCategoryResModel.categories!.id.toString());
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



  String getSelectedCategory() {
    for (var category in categoryModel.categories!) {
      if (category.isSelected) {
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
                      height: MediaQuery.of(context).size.height / 2,
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
                                                uploadData(selectedCategoryId(),
                                                    selectedSubCategory());
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
                                        height: categoryMemoryModelWithoutPage
                                                .data!.isEmpty
                                            ? 50
                                            : 100,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                                    progressIndicatorBuilder: (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        CircularProgressIndicator(
                                                                            value:
                                                                                downloadProgress.progress))),
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
                                        child: Container(
                                          height: 40,
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
                      height: MediaQuery.of(context).size.height / 2,
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
                                        height:
                                            isTitleFocused ? 19.2 / 21 : null,
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
        List<PhotoDetailModel> tempPhotoLinks = [];

        // requestStoragePermission();
        await Future.forEach(data["data"], (dynamic element) async {
          if (element["media_type"] == "IMAGE") {
            tempPhotoLinks.add(PhotoDetailModel(
                createdTime: convertTimeStampIntoDateTime(element["timestamp"]),
                isSelected: false,
                isEdit: false,
                type: "insta",
                id: element["id"],
                webLink: element["media_url"],
                captureDate: DateFormat('MMM yyyy').format(
                    convertTimeStampIntoDateTime(element["timestamp"]))));
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

  clossProgressDialog(String type, List<PhotoDetailModel> tempPhotoLinks) {
    if ((progressbarValue * 100).toStringAsFixed(0) == '100') {
      Navigator.pop(context);
      progressbarValue = 0.0;
      uploadCount = 0;
      if (type == "google_drive_synced") {
       // photoLinks = tempPhotoLinks;
        if (driveModel.isEmpty) {
          driveModel = tempPhotoLinks;
        } else {
          driveModel.addAll(tempPhotoLinks);
        }
        PrefUtils.instance.saveDrivePhotoLinks(driveModel);
       // if (driveGroupModel.isEmpty) {
          driveGroupModel = CommonWidgets.groupPhotosByDate(driveModel);
        // } else {
        //   driveGroupModel.addAll(CommonWidgets.groupPhotosByDate(driveModel));

        //  // driveGroupModel=CommonWidgets.combinedGroupPhotosByDate(photoLinks,driveGroupModel);
        // }
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == 'facebook_synced') {
        fbModel = tempPhotoLinks;

        fbGroupModel = CommonWidgets.groupPhotosForFBAndINSTAByDate(fbModel);

        PrefUtils.instance.saveFacebookPhotoLinks(fbModel);
        ApiCall.syncAccount(
            api: ApiUrl.syncAccount, type: type, status: "1", callack: this);
      } else if (type == "instagram_synced") {
        instaModel = tempPhotoLinks;
        instaGroupModel =
            CommonWidgets.groupPhotosForFBAndINSTAByDate(instaModel);

        PrefUtils.instance.saveInstaPhotoLinks(instaModel);
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
        print('Error fetching files: $e');

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
    tempPhotoLinks.clear();
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

  ///Fetch facebook url by photo id
  List<PhotoDetailModel> tempPhotoLinks = [];

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

      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
      clossProgressDialog('facebook_synced', tempPhotoLinks);
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
