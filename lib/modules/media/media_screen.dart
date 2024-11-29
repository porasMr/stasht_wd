import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stasht/modules/media/image_grid.dart';
import 'package:stasht/modules/media/model/category_memory_model_withoutpage.dart';
import 'package:stasht/modules/media/model/create_memory_model.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/subcategory.dart';
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

import 'model/phot_mdoel.dart';



// ignore: must_be_immutable
class MediaScreen extends StatefulWidget {
   MediaScreen({super.key,required this.future,required this.photosList});
List<Future<Uint8List?>> future=[];
   List<PhotoModel> photosList = [];


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
  bool isExpandedDrop = false;
  bool isLableAvailable = false;

  CategoryMemoryModelWithoutPage categoryMemoryModelWithoutPage =
      CategoryMemoryModelWithoutPage();
  bool isTitleFocused = false;
  bool addLable = false;

  //----------bottom sheet variable------------
 
  double _bottomSheetHeight = 0;
  double initialChildSize = 0.47;
  List<String> thumbnails = []; // Cache for thumbnail data
  double _progress = 0.0;
int _currentIndex=1;

  @override
  void initState() {
    super.initState();
    ApiCall.category(api: ApiUrl.categories, callack: this);

    // CommonWidgets.requestStoragePermission(((allAssets) {
    //   for (int i = 0; i < allAssets.length; i++) {
    //     photosList
    //         .add(PhotoModel(assetEntity: allAssets[i], selectedValue: false));
    //         future.add(allAssets[i].thumbnailDataWithSize(ThumbnailSize(300, 300)));
    //        // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
    //   }
    //   if (mounted) {
    //     setState(() {
    //       // Update your widget's state
    //     });
    //   }
    // }));
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
              child:
               Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: 
                  selectedtabView(context))),
        ],
      ),
    );
  }

  selectedtabView(BuildContext context) {
    if (selectedIndex == 0) {
      return albumView();
    } else if (selectedIndex == 1) {
      return albumView();
    } else if (selectedIndex == 2) {
      return CommonWidgets.fbView(context);
    } else if (selectedIndex == 3) {
      return CommonWidgets.instaView(context);
    } else if (selectedIndex == 4) {
      return CommonWidgets.driveView(context);
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
  Widget albumView() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 2, // Aspect ratio of each grid item
      ),
      itemCount: widget.photosList.length,
       addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
           
            setState(() {
               widget.photosList[index].selectedValue = !widget.photosList[index].selectedValue;
            _bottomSheetHeight = 230;
            initialChildSize = 0.6;
            });

            // update();
            if (countSelectedPhotos() > 4) {
              openAddPillBottomSheet(context);
            }
          },
          child: 
          
          Stack(
            children: [
            MyGridItem(widget.future[index])
                      ,
             
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: widget.photosList[index].selectedValue
                        ? AppColors.primaryColor.withOpacity(.65)
                        : null),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Padding(
                  padding: EdgeInsets.only(top: 4, right: 4),
                  child: PhysicalModel(
                    borderRadius: BorderRadius.circular(8),
                    elevation: 4,
                    color: Colors.transparent,
                    child: Container(
                      height: 21.87,
                      width: 30.07,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(.5), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                          color: widget.photosList[index].selectedValue
                              ? Colors.white
                              : Colors.black.withOpacity(.3)),
                      child: widget.photosList[index].selectedValue
                          ? Image.asset(
                              correct,
                              height: 12,
                              width: 12,
                            )
                          : const IgnorePointer(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void onFailure(String message) {
    Get.snackbar("Error", message, colorText: AppColors.redColor);
  }

  @override
  void onSuccess(String data, String apiType) {
    if (apiType == ApiUrl.categories) {
      categoryModel = CategoryModel.fromJson(jsonDecode(data));
      categoryModel.categories![0].isSelected = true;

      ApiCall.memoryByCategory(
          api: ApiUrl.memoryByCategory,
          id: categoryModel.categories![0].id.toString(),
          sub_category_id: '',
          type: 'no_page',
          callack: this);
    } else if (apiType == ApiUrl.memoryByCategory) {
      categoryMemoryModelWithoutPage =
          CategoryMemoryModelWithoutPage.fromJson(jsonDecode(data));
     
          setState(() {
             if (categoryMemoryModelWithoutPage.subCategories!.isEmpty) {
        addLable = true;
      }
          });

    }else if(apiType == ApiUrl.uploadImageTomemory){
      String count=data.split("=")[1]; 
      print(json.decode(data.split("=")[0])['file'].toString());

                  print(int.parse(count));

                _progress = (_currentIndex++ / countSelectedPhotos()).clamp(0.0, 1.0);

                print(_progress);
createModel.images![int.parse(count)].link=json.decode(data.split("=")[0])['file'].toString();
      setState(() {
                          progressDialog(_progress);

      });
    }
  }

  @override
  void tokenExpired(String message) {}

  //-----------------bottom sheet-------------------------
  int countSelectedPhotos() {
    return widget.photosList.where((photo) => photo.selectedValue).length;
  }

  String selectedCategory() {
    for (var category in categoryModel.categories!) {
      if (category.isSelected) {
        return category.name!;
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
        return category.name!;
      }
    }
    return '';
  }

  void openAddPillBottomSheet(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(Get.context!).requestFocus(titleFocusNode);
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Optional for transparent background
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            top: true,
            bottom: false,
            child: DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              minChildSize: 0.1,
              maxChildSize: 0.9,
              builder: (context, scrollController) => PhysicalModel(
                color: Colors.white,
                elevation: 10,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                shadowColor: Colors.black.withOpacity(0.5),
                child: Container(
                  height: _bottomSheetHeight,
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
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context)
                          .viewInsets
                          .bottom, // Avoid keyboard overlap
                    ),
                    child: ListView(
                      controller: scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                          .onDrag, // Dismiss on scroll

                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 5,
                              width: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 48,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      child: const Icon(Icons.close),
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        titleController.clear();
                                        // Trigger state update to close the sheet
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
                                    if (countSelectedPhotos() > 0)
                                      Text(
                                        "(${countSelectedPhotos()})",
                                        style: appTextStyle(
                                          fm: robotoBold,
                                          fz: 20,
                                          color: Colors.black,
                                          height: 25 / 20,
                                        ),
                                      ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (titleController.text.isNotEmpty) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
Navigator.pop(context);
uploadData(selectedCategoryId(),"");

                                    } else {
                                      Get.snackbar(
                                          "Error", "Please enter memory title",
                                          colorText: Colors.red);
                                    }
                                  },
                                  child: Text(
                                    AppStrings.done,
                                    style: appTextStyle(
                                      fm: robotoRegular,
                                      fz: 17,
                                      color:titleController.text.isNotEmpty?AppColors.black: const Color(0XFF858484),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Divider(
                          color: AppColors.textfieldFillColor.withOpacity(.75),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Row(
                            children: [
                              if (categoryModel.categories!.length > 1)
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
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
                                            categoryModel.categories![index]
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
                                                    .categories![index].id
                                                    .toString(),
                                            callack: this);
                                      },
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth:
                                              90, // Ensure the min width is 90
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: selectedCategory() ==
                                                  categoryModel
                                                      .categories![index].name
                                              ? AppColors.subTitleColor
                                              : Colors.grey.withOpacity(.2),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        child: Center(
                                          child: Text(
                                            categoryModel
                                                .categories![index].name!,
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
                        const SizedBox(height: 10),
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
                              categoryMemoryModelWithoutPage.data == null
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
                                            //  labelFocusNode.unfocus();

                                            // }
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
                        categoryMemoryModelWithoutPage.data != null
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                                    labelStyle: appTextStyle(
                                      fz: isTitleFocused ? 14 : 21,
                                      height: isTitleFocused ? 19.2 / 21 : null,
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
                              (categoryMemoryModelWithoutPage.subCategories ==
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ListView.builder(
                                  itemCount: categoryMemoryModelWithoutPage
                                      .subCategories!.length,
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
                                        constraints: const BoxConstraints(
                                          minWidth:
                                              90, // Ensure the min width is 90
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: categoryMemoryModelWithoutPage
                                                  .subCategories![index]
                                                  .isselected
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
                ),
              ),
            ),
          );
        });
      },
    );
  }
  CreateMoemoryModel createModel=CreateMoemoryModel();

uploadData(String categoryId,String subCategoryId){
  createModel.categoryId=categoryId;
    createModel.categoryId=categoryId;
    createModel.title=titleController.text;
    List<ImagesFile> imageFile=[];

for(int i=0;i<widget.photosList.length;i++){
  if(widget.photosList[i].selectedValue){
        ImagesFile imp=ImagesFile();

    imp.type="image";
    imp.captureDate=_getFormattedDateTime(widget.photosList[i].assetEntity);
    imp.description='';
      imp.link='';
    
    imp.location='';
    imageFile.add(imp);
   
    
  }
}
  createModel.images=imageFile;

                  _progress = (_currentIndex++ / countSelectedPhotos()).clamp(0.0, 1.0);

  progressDialog(_progress);

  for(int i=0;i<widget.photosList.length;i++){
    if(widget.photosList[i].selectedValue){
       getFile(widget.photosList[i].assetEntity).then((value){

     ApiCall.uploadImageIntoMemory(api: ApiUrl.uploadImageTomemory, path: value!.path, callack: this,count:i.toString());
    });
    }
  }

print(createModel.images!.length);
}

String _getFormattedDateTime(AssetEntity asset) {
    final DateTime creationDate = asset.createDateTime;  // Get the creation date of the asset
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');  // Define the format
    return formatter.format(creationDate);  // Format the date as a string
  }
  Future<String?> _getFilePath(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file != null) {
      return file.path; // Return the file path
    }
    return null;
  }

  Future<File?> getFile(AssetEntity assets)async{
    
    final File? file = await assets.file;
    if (file != null) {
      return file; // Return the file path
    }
    return null;
  }

 progressDialog(double p){
  
    EasyLoading.showProgress(
      p,
       // Show percentage
    );

    if (p >=0.9 ) {
      _progress=0.0;
      _currentIndex=0;
      EasyLoading.dismiss(); // Dismiss the dialog
    }
 
  

  }

}


