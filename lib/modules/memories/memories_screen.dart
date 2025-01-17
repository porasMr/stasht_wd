import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stasht/modules/create_memory/edit_memory.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memories/model/category_memory_model.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/memories_model.dart';
import 'package:stasht/modules/memory_details/memory_lane.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/shimmer_widget.dart';

import '../create_memory/create_memory.dart';

class MemoriesScreen extends StatefulWidget {
  MemoriesScreen({super.key, required this.isSkip, required this.photosList,required this.categorySelectedIndex});
  VoidCallback isSkip;
  List<PhotoModel> photosList = [];
    int categorySelectedIndex=0;


  @override
  MemoriesScreenState createState() => MemoriesScreenState();
}

class MemoriesScreenState extends State<MemoriesScreen> implements ApiCallback {
  //final MemoriesController controller = Get.put(MemoriesController());
  CategoryModel categoryModel = CategoryModel();
  MemoriesModel memoriesModel = MemoriesModel();
  CategoryMemoryModel categoryMemoryModel = CategoryMemoryModel();
  int selectedId = 0; // Default selected ID
  int selectedIndex = 0;
  bool isAll = false;
  int? subIdIndex;
  int _currentPage = 1;

  bool _isLoading = false;
  bool _hasMore = false;
  String subCategoriesId = '';
  final ScrollController _scrollController = ScrollController();
  List<Future<Uint8List?>> future = [];
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    refrehScreen();
    for (int i = 0; i < widget.photosList.length; i++) {
      future.add(widget.photosList[i].assetEntity
          .thumbnailDataWithSize(ThumbnailSize(300, 300)));
      // _compressAsset(allAssets[i]).then((value) =>imagePath.add(value!.path) );
    }
  }

  refrehScreen() {
    ApiCall.category(api: ApiUrl.categories, callack: this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMore) {
          _isLoading = true;
          _currentPage = _currentPage + 1;
          _hasMore = false;
          setState(() {});
          if (subIdIndex == null) {
            nextPageSubCategory('');
          } else {
            nextPageSubCategory(subCategoriesId);
          }
        }
      }
    });
       
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        categoryModel.categories == null
            ? Container(
                height: 35,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 15),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            child: shimmerWidget(35, 30)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            child: shimmerWidget(35, 100)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            child: shimmerWidget(35, 100)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            child: shimmerWidget(35, 100)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            child: shimmerWidget(35, 100)),
                      ),
                    ),
                  ],
                ),
              )
            : Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 35,
                      padding: const EdgeInsets.only(left: 15),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                addLableBottomSheet(context, '', '');
                              },
                              child: Container(
                                  height: 35,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.black),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.whiteColor),
                                  child: const Icon(
                                    Icons.add,
                                  )),
                            ),
                            GestureDetector(
                              onTap: () {
                                allCategory();
                              },
                              child: Container(
                                height: 35,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: !anyValueSelected()
                                        ? AppColors.black
                                        : AppColors.selectedTabColor),
                                child: Center(
                                  child: Text(
                                    "All",
                                    style: appTextStyle(
                                        fm: interMedium,
                                        height: 27 / 14,
                                        fz: 14,
                                        color: !anyValueSelected()
                                            ? AppColors.whiteColor
                                            : AppColors.black),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: categoryModel.categories!.length * 120,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: categoryModel.categories!.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedCategory(index);
                                      subIdIndex = null;
                                    },
                                    onLongPressStart: (details) {
                                      if (categoryModel
                                                  .categories![index].name !=
                                              "Personal" &&
                                          categoryModel
                                                  .categories![index].name !=
                                              "Shared" &&
                                          categoryModel
                                                  .categories![index].name !=
                                              "Published") {
                                        showPopupMenu(
                                            details,
                                            categoryModel.categories![index].id
                                                .toString(),
                                            categoryModel
                                                .categories![index].name!);
                                      }
                                    },
                                    child: tabTitle(
                                        title: categoryModel
                                            .categories![index].name,
                                        index: index),
                                  );
                                },
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: 
                        _mainScrollController,
                        child: Column(
                          children: [selectedtabView()],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ],
    );
  }

  tabTitle({String? title, int? index}) {
    return Container(
      height: 35,
      margin: const EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: categoryModel.categories![index!].isSelected
              ? AppColors.black
              : AppColors.selectedTabColor),
      child: Center(
        child: Text(
          title ?? "",
          style: appTextStyle(
              fm: interMedium,
              height: 27 / 14,
              fz: 14,
              color: categoryModel.categories![index].isSelected
                  ? AppColors.whiteColor
                  : AppColors.black),
        ),
      ),
    );
  }

  selectedtabView() {
    if (!anyValueSelected()) {
      return _allView();
    } else {
      return
          // Call fetchTabs first, and then return the UI
          categoryMemoryModel.subCategories == null
              ? Container()
              : myMemoriesUI();
    }
  }

  bool anyValueSelected() {
    bool isAnySelected =
        categoryModel.categories!.any((category) => category.isSelected);
    return isAnySelected;
  }

  bool anySubValueSelected() {
    bool isAnySelected = categoryMemoryModel.subCategories!
        .any((category) => category.isSelected);
    return isAnySelected;
  }

  selectedCategory(int index) {
    print(index);
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      if (i == index) {
        categoryModel.categories![index].isSelected = true;
      } else {
        categoryModel.categories![i].isSelected = false;
      }
    }
    setState(() {});
    EasyLoading.show();
    ApiCall.memoryByCategory(
        api: ApiUrl.memoryByCategory,
        id: categoryModel.categories![index].id.toString(),
        sub_category_id: '',
        type: '',
        page: '1',
        callack: this);
  }

  refershSubCategory(String subId) {
    print(subId);
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      if (categoryModel.categories![i].isSelected) {
        setState(() {});
        EasyLoading.show();
        ApiCall.memoryByCategory(
            api: ApiUrl.memoryByCategory,
            id: categoryModel.categories![i].id.toString(),
            sub_category_id: subId,
            type: '',
            page: "$_currentPage",
            callack: this);
      }
      break;
    }
  }

  nextPageSubCategory(String subId) {
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      if (categoryModel.categories![i].isSelected) {
        setState(() {});
        ApiCall.memoryByCategory(
            api: ApiUrl.memoryByCategory,
            id: categoryModel.categories![i].id.toString(),
            sub_category_id: subId,
            type: '',
            page: "$_currentPage",
            callack: this);
      }
      break;
    }
  }

  allCategory() {
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      categoryModel.categories![i].isSelected = false;
    }
    setState(() {});
  }

  allSubCategory() {
    for (int i = 0; i < categoryMemoryModel.subCategories!.length; i++) {
      categoryMemoryModel.subCategories![i].isSelected = false;
    }
    setState(() {});
  }

  _allView() {
    return memoriesModel.data == null
        ? Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shimmerWidget(30, 150),
                    shimmerWidget(20, 20),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    child: shimmerWidget(180, 200)),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shimmerWidget(30, 150),
                    shimmerWidget(20, 20),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Enable horizontal scrolling
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        child: shimmerWidget(180, 200),
                      ),
                      const SizedBox(
                          width: 20), // Add spacing between the items
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        child: shimmerWidget(180, 200),
                      ),
                      const SizedBox(width: 20),
                      // You can add more items here if needed
                    ],
                  ),
                )
              ],
            ),
          )
        : Column(
            children: [
              ListView.builder(

                  padding: const EdgeInsets.only(top: 15),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memoriesModel.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: GestureDetector(
                        onTap: () {},
                        onLongPress: () {},
                        onLongPressStart: (details) {
                          if (memoriesModel.data![index].name != "Personal") {
                            showPopupMenu(
                                details,
                                memoriesModel.data![index].id.toString(),
                                memoriesModel.data![index].name!);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      memoriesModel.data![index].name!,
                                      style: appTextStyle(
                                        color: AppColors.monthColor,
                                        fm: robotoRegular,
                                        fz: 22,
                                        height: 28 / 22,
                                      ),
                                    ),
                                    Text(
                                      " (${memoriesModel.data![index].memorisCount!})",
                                      style: appTextStyle(
                                        color: AppColors.monthColor,
                                        fm: robotoRegular,
                                        fz: 22,
                                        height: 28 / 22,
                                      ),
                                    ),
                                  ],
                                ),
                                if (memoriesModel.data![index].memorisCount! >
                                    0)
                                  GestureDetector(
                                      onTap: () {
                                        categoryModel.categories![index]
                                            .isSelected = true;
                                        _currentPage = 1;
                                        selectedCategory(index);
                                        subIdIndex = null;
                                      },
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                        size: 25,
                                      ))
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            (getMemoryIndex() == 0 &&
                                    index == 0 &&
                                    memoriesModel.published!.isEmpty &&
                                    memoriesModel.shared!.isEmpty)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        noMemoriesPlaceholder,
                                        height: 230,
                                      ),
                                      const SizedBox(height: 16),

                                      // No memory text
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "You haven't created a memory yet!",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                                : listView(memoriesModel.data![index].memoris!,
                                    memoriesModel.data![index].name!),
                            if (memoriesModel.data!.length == 1)
                              Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Add category title view
                                    _addCategoryTitleView(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Shared With",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                            Text(
                              memoriesModel.shared!.isNotEmpty
                                  ? " (${memoriesModel.shared![0].memorisCount})"
                                  : " (0)",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                          ],
                        ),
                        if (memoriesModel.shared!.isNotEmpty)
                          if (memoriesModel.shared![0].memorisCount! > 0)
                            GestureDetector(
                                onTap: () {
                                  categoryModel
                                      .categories![
                                          categoryModel.categories!.length - 2]
                                      .isSelected = true;
                                  _currentPage = 1;
                                  selectedCategory(
                                      categoryModel.categories!.length - 2);
                                  subIdIndex = null;
                                },
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 25,
                                ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (memoriesModel.shared!.isNotEmpty)
                      listView(memoriesModel.shared![0].memoris!, "Shared"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Published",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                            Text(
                              memoriesModel.published!.isNotEmpty
                                  ? " (${memoriesModel.published![0].memorisCount})"
                                  : " (0)",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                          ],
                        ),
                        if (memoriesModel.published!.isNotEmpty)
                          if (memoriesModel.published![0].memorisCount! > 0)
                            GestureDetector(
                                onTap: () {
                                  categoryModel
                                      .categories![
                                          categoryModel.categories!.length - 1]
                                      .isSelected = true;
                                  _currentPage = 1;
                                  selectedCategory(
                                      categoryModel.categories!.length - 1);
                                  subIdIndex = null;
                                },
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 25,
                                ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (memoriesModel.published!.isNotEmpty)
                      listView(
                          memoriesModel.published![0].memoris!, "Published"),
                  ],
                ),
              )
            ],
          );
  }

 int getMemoryIndex(){
    int i=0;
    for(int k=0;k<memoriesModel.data!.length;k++){
i=i+memoriesModel.data![k].memorisCount!;
    }
    print(i);
return i;
  }

  myMemoriesUI() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: Column(
        children: [
          (getSelectedCategory() == 'Shared' ||
                        getSelectedCategory() == 'Published')?SizedBox(height: 16,):
          Container(
            height: 49,
            margin: const EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                (getSelectedCategory() == 'Shared' ||
                        getSelectedCategory() == 'Published')
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          _currentPage = 1;
                          subIdIndex = null;

                          allSubCategory();
                          refershSubCategory('');
                        },
                        onLongPressStart: (details) {},
                        child: Align(
                          alignment: Alignment.center, // Center each subTitle
                          child: Container(
                            alignment: Alignment.center,
                            width: 40,
                            height: 27,
                            // Reduced height
                            margin: const EdgeInsets.only(right: 8),
                            // Reduced margin
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            // Reduced padding
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: anySubValueSelected()
                                    ? AppColors.black
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(13),
                              // Slightly reduced border radius
                              color: anySubValueSelected()
                                  ? Colors.white
                                  : AppColors.subTitleColor,
                            ),
                            child: Text(
                              "All",
                              style: appTextStyle(
                                fm: interMedium,
                                height: 24 / 14, // Adjusted line height
                                fz: 12, // Reduced font size
                                color: AppColors.black,
                              ),
                            ),
                          ), // Call the subTitle method
                        ),
                      ),
                categoryMemoryModel.subCategories == null
                    ? Container()
                    : Expanded(
                        child: Container(
                          child: ListView.builder(
                            itemCount:
                                categoryMemoryModel.subCategories!.length,

                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  for (int i = 0;
                                      i <
                                          categoryMemoryModel
                                              .subCategories!.length;
                                      i++) {
                                    if (i == index) {
                                      categoryMemoryModel.subCategories![index]
                                          .isSelected = true;
                                    } else {
                                      categoryMemoryModel
                                          .subCategories![i].isSelected = false;
                                    }
                                  }
                                  subIdIndex = index;
                                  setState(() {});
                                  _currentPage = 1;
                                  subCategoriesId = categoryMemoryModel
                                      .subCategories![index].id
                                      .toString();
                                  refershSubCategory(subCategoriesId);
                                },
                                onLongPressStart: (details) {},
                                child: Align(
                                  alignment:
                                      Alignment.center, // Center each subTitle
                                  child: subTitle(
                                      title: categoryMemoryModel
                                          .subCategories![index].name,
                                      index: index), // Call the subTitle method
                                ),
                              );
                            },
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics:
                                const BouncingScrollPhysics(), // Optional: adds bounce effect on scroll
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            child: categoryMemoryModel.data!.data!.isEmpty
                ? Container()
                : ListView(
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      ...categoryMemoryModel.data!.data!
                          .map((memory) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MemoryDetailPage(
                                              memoryTtile: memory.title!,
                                              memoryId: memory.id.toString(),
                                              userName: memory.user!.name!,
                                              sharedCount: "0",
                                              email: memory.user!.id.toString(),
                                              imageLink: memory.lastUpdateImg!,
                                              imageCaptions:
                                                  memory.user!.profileImage,
                                              pubLished:
                                                  memory.published.toString(),
                                              future: future,
                                              photosList: widget.photosList,
                                              subId: memory.subCategoryId,
                                              catId:
                                                  memory.categoryId.toString(),
                                              selectionType:
                                                  getSelectedCategory(),
                                            ))).then((value) {
                                  refrehScreen();
                                  allCategory();
                               
                                });
                              },
                              child: Container(
                                height: 90,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        // top: BorderSide(
                                        //     color: AppColors.textfieldFillColor),
                                        bottom: BorderSide(
                                            color:
                                                AppColors.textfieldFillColor))),
                                child: SizedBox(
                                  height: 91,
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            height: 71,
                                            width: 97,
                                            child: Container(
                                              height: 71,
                                              width: 77,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: memory
                                                                .lastUpdateImg !=
                                                            ''
                                                        ? AppColors
                                                            .skeltonBorderColor
                                                        : Colors.transparent),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: memory.lastUpdateImg ==
                                                        ''
                                                    ? Image.asset(
                                                        "assets/images/placeHolder.png")
                                                    : CachedNetworkImage(
                                                        imageUrl: memory
                                                            .lastUpdateImg!,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              height: 38,
                                              width: 38,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white),
                                                  shape: BoxShape.circle,
                                                  color: convertColor(
                                                      color: memory.user!
                                                          .profileColor!)),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 0.3)),
                                                  height: 46,
                                                  width: 46,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    child: memory.user!
                                                                .profileImage !=
                                                            ''
                                                        ? CachedNetworkImage(
                                                            imageUrl: memory
                                                                .user!
                                                                .profileImage,
                                                            fit: BoxFit.cover,
                                                            height: 30,
                                                            width: 30,
                                                            progressIndicatorBuilder: (context,
                                                                    url,
                                                                    downloadProgress) =>
                                                                CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress))
                                                        : Center(
                                                            child: Text(
                                                              memory.user!
                                                                  .name![0]
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      robotoRegular),
                                                            ),
                                                          ),
                                                  ))),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  memory.user!.name!,
                                                  style: appTextStyle(
                                                    fm: robotoRegular,
                                                    fz: 12,
                                                    color: AppColors.black,
                                                    height: 19.2 / 12,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      memory.title!.length > 20
                                                          ? memory.title!
                                                                  .substring(
                                                                      0, 20) +
                                                              "...."
                                                          : memory.title!,
                                                      style: appTextStyle(
                                                        fm: robotoMedium,
                                                        fz: 16,
                                                        color: AppColors.black,
                                                        height: 19 / 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "${CommonWidgets.dateRetrun(memory.minUploadedImgDate!)}-${CommonWidgets.maxDateRetrun(memory.maxUploadedImgDate!)}",
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          fontFamily:
                                                              robotoRegular,
                                                          height: 17.2 / 13,
                                                          fontSize: 10),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                height: 32,
                                                width: 43,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18)),
                                                child: Text(
                                                  '${memory.postsCount}',
                                                  style: appTextStyle(
                                                    fm: interMedium,
                                                    fz: 12,
                                                    color: AppColors.black,
                                                    height: 26.2 / 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )))
                          .toList(),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      SizedBox(
                        height: _isLoading ? 150 : 107,
                      )
                    ],
                  ),
          )
        ],
      ),
    );
  }

  _addCategoryTitleView() {
    return GestureDetector(
      onTap: () {
        addLableBottomSheet(context, '', '');
      },
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        child: Row(
          children: [
            // Icon inside a rounded box
            Image.asset(
              "assets/images/addPill.png",
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 12),
            // Category title text
            Text(
              "Add Category Title",
              style: TextStyle(
                color: const Color(0XFF9FA0C4).withOpacity(.75),
                fontSize: 23,
                fontFamily: robotoRegular,
                height: 27 / 23,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
scrollToSelectedPosition(int index){
   WidgetsBinding.instance.addPostFrameCallback((_) {
     double deviceHeight = MediaQuery.of(context).size.height;
         final double offset = index * deviceHeight *.237; // Assuming each item has a height of 50.0
    _mainScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  });
  setState(() {
    
  });
}
  @override
  void onFailure(String message) {
    EasyLoading.dismiss();
    CommonWidgets.errorDialog(context, message);
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);
    if (apiType == ApiUrl.categories) {
      categoryModel = CategoryModel.fromJson(jsonDecode(data));

      ApiCall.getMomories(api: ApiUrl.memories, callack: this);
    } else if (apiType == ApiUrl.memories) {
      memoriesModel = MemoriesModel.fromJson(jsonDecode(data));
      if (memoriesModel.data!.isEmpty) {
        widget.isSkip();
      }
      scrollToSelectedPosition(widget.categorySelectedIndex);
     
    } else if (apiType == ApiUrl.createCategory) {
      CommonWidgets.successDialog(context, json.decode(data)['message']);

      EasyLoading.dismiss();
      ApiCall.category(api: ApiUrl.categories, callack: this);
    } else if (apiType == ApiUrl.deleteCategory) {
      CommonWidgets.successDialog(context, json.decode(data)['message']);

      EasyLoading.dismiss();
      ApiCall.category(api: ApiUrl.categories, callack: this);
    } else if (apiType == ApiUrl.updateCategory) {
      CommonWidgets.successDialog(context, json.decode(data)['message']);

      EasyLoading.dismiss();
      ApiCall.category(api: ApiUrl.categories, callack: this);
    } else if (apiType == ApiUrl.memoryByCategory) {
      EasyLoading.dismiss();

      if (_isLoading) {
        CategoryMemoryModel nextMemoryModel =
            CategoryMemoryModel.fromJson(jsonDecode(data));
        _isLoading = false;
        categoryMemoryModel.data!.data!.addAll(nextMemoryModel.data!.data!);
      } else {
        categoryMemoryModel = CategoryMemoryModel.fromJson(jsonDecode(data));
        if (categoryMemoryModel.data!.nextPageUrl != null) {
          _hasMore = true;
        }
      }

      if (subIdIndex != null) {
        categoryMemoryModel.subCategories![subIdIndex!].isSelected = true;
      }
    }
    setState(() {});
  }

  @override
  void tokenExpired(String message) {}

//--------------Bottom sheet for create category---------------
  final FocusNode titleFocusNode = FocusNode();
  final titleController = TextEditingController();
  bool isLabelEdited = false;
  bool isCategoryEdited = false;

  void openAddPillBottomSheet(String name, String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(titleFocusNode);
    });
    titleController.text = name;
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
              initialChildSize: 0.6,
              // Starting size (fraction of the screen height)
              minChildSize: 0.4,
              // Minimum size
              maxChildSize: 0.9,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25)),
                        color: AppColors.whiteColor),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 5,
                              width: 36,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: AppColors.dragColor),
                            ),
                          ),
                          const SizedBox(height: 13),
                          Container(
                            height: 48,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);

                                    titleController.clear();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  name == ''
                                      ? AppStrings.addCategory
                                      : AppStrings.editCategory,
                                  style: appTextStyle(
                                      fm: robotoBold,
                                      height: 25 / 20,
                                      fz: 20,
                                      color: AppColors.black),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    EasyLoading.show();
                                    if (name == '') {
                                      ApiCall.createCategory(
                                          api: ApiUrl.createCategory,
                                          name: titleController.text,
                                          callack: this);
                                    } else {
                                      ApiCall.ediCategory(
                                          api: ApiUrl.updateCategory,
                                          id: id,
                                          name: titleController.text,
                                          callack: this);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(AppStrings.done,
                                        style: appTextStyle(
                                            fm: interRegular,
                                            fz: 17,
                                            color: AppColors.primaryColor)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 13),
                          Divider(
                              color: AppColors.textfieldFillColor
                                  .withOpacity(.75)),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              AppStrings.categoryTitle,
                              style: appTextStyle(
                                  fm: interRegular,
                                  fz: 14,
                                  height: 19.2 / 14,
                                  color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              focusNode: titleFocusNode,
                              controller: titleController,
                              maxLines: 2,
                              cursorColor: AppColors.primaryColor,
                              textInputAction: TextInputAction.done,

                              showCursor: true,
                              style: appTextStyle(
                                  fm: robotoRegular,
                                  fz: 21,
                                  height: 27 / 21,
                                  color: AppColors.black),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Add Category title here",
                                  hintStyle: appTextStyle(
                                      fm: robotoRegular,
                                      fz: 21,
                                      height: 27 / 21,
                                      color: AppColors.hintColor)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
      },
    );

    // Get.bottomSheet(
    //     DraggableScrollableSheet(
    //       initialChildSize: 0.4,
    //       // Starting size (fraction of the screen height)
    //       minChildSize: 0.2,
    //       // Minimum size
    //       maxChildSize: 0.9,
    //       builder: (BuildContext context, ScrollController scrollController) {
    //         return Container(
    //           decoration: BoxDecoration(
    //             borderRadius: const BorderRadius.only(
    //                 topRight: Radius.circular(25),
    //                 topLeft: Radius.circular(25)),
    //             boxShadow: [
    //               BoxShadow(
    //                 color: AppColors.black.withOpacity(0.2),
    //                 spreadRadius: 2,
    //                 blurRadius: 10,
    //                 offset: const Offset(0, 3),
    //               ),
    //             ],
    //           ),
    //           child: Container(
    //             decoration: const BoxDecoration(
    //                 borderRadius: BorderRadius.only(
    //                     topRight: Radius.circular(25),
    //                     topLeft: Radius.circular(25)),
    //                 color: AppColors.whiteColor),
    //             child: SingleChildScrollView(
    //               controller: scrollController,
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   const SizedBox(height: 8),
    //                   Align(
    //                     alignment: Alignment.center,
    //                     child: Container(
    //                       height: 5,
    //                       width: 36,
    //                       decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(100),
    //                           color: AppColors.dragColor),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 13),
    //                   Container(
    //                     height: 48,
    //                     child: Row(
    //                       children: [
    //                         GestureDetector(
    //                           onTap: () {
    //                             titleController.clear();
    //                             Get.back();
    //                           },
    //                           child: const Padding(
    //                             padding: EdgeInsets.only(left: 20.0),
    //                             child: Align(
    //                               alignment: Alignment.centerLeft,
    //                               child: Icon(Icons.close),
    //                             ),
    //                           ),
    //                         ),
    //                         const SizedBox(width: 5),
    //                         Text(
    //                           name == ''
    //                               ? AppStrings.addCategory
    //                               : AppStrings.editCategory,
    //                           style: appTextStyle(
    //                               fm: robotoBold,
    //                               height: 25 / 20,
    //                               fz: 20,
    //                               color: AppColors.black),
    //                         ),
    //                         const Spacer(),
    //                         GestureDetector(
    //                           onTap: () async {
    //                             Get.back();
    //                             EasyLoading.show();
    //                             if (name == '') {
    //                               ApiCall.createCategory(
    //                                   api: ApiUrl.createCategory,
    //                                   name: titleController.text,
    //                                   callack: this);
    //                             } else {
    //                               ApiCall.ediCategory(
    //                                   api: ApiUrl.updateCategory,
    //                                   id: id,
    //                                   name: titleController.text,
    //                                   callack: this);
    //                             }
    //                           },
    //                           child: Padding(
    //                             padding: const EdgeInsets.only(right: 20.0),
    //                             child: Text(AppStrings.done,
    //                                 style: appTextStyle(
    //                                     fm: interRegular,
    //                                     fz: 17,
    //                                     color: AppColors.primaryColor)),
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                   const SizedBox(height: 13),
    //                   Divider(
    //                       color: AppColors.textfieldFillColor.withOpacity(.75)),
    //                   const SizedBox(height: 16),
    //                   Padding(
    //                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                     child: Text(
    //                       AppStrings.categoryTitle,
    //                       style: appTextStyle(
    //                           fm: interRegular,
    //                           fz: 14,
    //                           height: 19.2 / 14,
    //                           color: AppColors.primaryColor),
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                     child: TextFormField(
    //                       focusNode: titleFocusNode,
    //                       controller: titleController,
    //                       maxLines: 2,
    //                       textInputAction: TextInputAction.done,
    //                       style: appTextStyle(
    //                           fm: robotoRegular,
    //                           fz: 21,
    //                           height: 27 / 21,
    //                           color: AppColors.black),
    //                       decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           hintText: "Add Category title here",
    //                           hintStyle: appTextStyle(
    //                               fm: robotoRegular,
    //                               fz: 21,
    //                               height: 27 / 21,
    //                               color: AppColors.hintColor)),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 5),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         );
    //       },
    //     ),
    //     barrierColor: AppColors.transparentColor,
    //     isScrollControlled: true,
    //     elevation: 6);
  }

  Widget subTitle({String? title, int? index}) {
    return Container(
      alignment: Alignment.center,
      height: 27,
      // Reduced height
      margin: const EdgeInsets.only(right: 8),
      // Reduced margin
      padding: EdgeInsets.symmetric(horizontal: index == 0 ? 8 : 12),
      // Reduced padding
      decoration: BoxDecoration(
        border: Border.all(
          color: categoryMemoryModel.subCategories![index!].isSelected == false
              ? AppColors.black
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(13),
        // Slightly reduced border radius
        color: categoryMemoryModel.subCategories![index].isSelected == false
            ? Colors.white
            : AppColors.subTitleColor,
      ),
      child: Text(
        title ?? "",
        style: appTextStyle(
          fm: interMedium,
          height: 24 / 14, // Adjusted line height
          fz: 12, // Reduced font size
          color: AppColors.black,
        ),
      ),
    );
  }

  showPopupMenu(details, String id, String name) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Calculate the position for the popup menu
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        details.globalPosition,
        details.globalPosition,
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<String>(
      context: context,
      color: AppColors.whiteColor,
      surfaceTintColor: Color(0XFFF9F9F9),
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'Edit',
          height: 39.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Edit',
              style: appTextStyle(fm: interRegular, fz: 17),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Delete',
          height: 39.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Delete',
              style: appTextStyle(fm: interRegular, fz: 17),
            ),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    ).then((value) {
      if (value == 'Edit') {
        addLableBottomSheet(context, name, id);
      } else if (value == 'Delete') {
        EasyLoading.show();
        ApiCall.deleteCategory(
            api: ApiUrl.deleteCategory, id: id, callack: this);
      }
    });
  }

  //------------memory view------------
  listView(List<Memoris> memoriesList, String type) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return memoriesList.isEmpty
        ? const IgnorePointer()
        : SizedBox(
            height: deviceHeight * .237,
            child: ListView.builder(
                itemCount: memoriesList.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MemoryDetailPage(
                                    memoryTtile: memoriesList[index].title!,
                                    memoryId: memoriesList[index].id.toString(),
                                    userName: memoriesList[index].user!.name!,
                                    sharedCount: "0",
                                    email:
                                        memoriesList[index].user!.id.toString(),
                                    imageLink:
                                        memoriesList[index].lastUpdateImg!,
                                    imageCaptions:
                                        memoriesList[index].user!.profileImage,
                                    pubLished: memoriesList[index]
                                        .published
                                        .toString(),
                                    future: future,
                                    photosList: widget.photosList,
                                    subId: memoriesList[index].subCategoryId,
                                    catId: memoriesList[index]
                                        .categoryId
                                        .toString(),
                                    selectionType: type,
                                  ))).then((value) {
                        refrehScreen();
                        allCategory();
                        
                      });
                    },
                    child: SizedBox(
                      height: deviceHeight * .237,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Stack(
                            children: [
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        height: deviceHeight * .2,
                                        width: deviceWidth * .43,
                                        margin: const EdgeInsets.only(right: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  AppColors.skeltonBorderColor),
                                          borderRadius:
                                              BorderRadius.circular(46),
                                          image: memoriesList[index]
                                                      .lastUpdateImg ==
                                                  ''
                                              ? const DecorationImage(
                                                  image: AssetImage(
                                                    "assets/images/placeHolder.png",
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : memoriesList[index]
                                                          .lastUpdateImg !=
                                                      ''
                                                  ? 
                                                  
                                                  DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        memoriesList[index]
                                                            .lastUpdateImg!,
                                                            
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                          color: memoriesList[index]
                                                      .lastUpdateImg !=
                                                  ''
                                              ? null
                                              : Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(46),
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          Container(
                                            height: deviceHeight * .18,
                                            width: deviceWidth * .43,
                                            margin: EdgeInsets.only(
                                                right: 20,
                                                bottom: deviceHeight * .037),
                                            alignment: Alignment.bottomCenter,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(46),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 10.0, sigmaY: 10.0),
                                                child: Container(
                                                  height: deviceHeight * .1,
                                                  width: deviceWidth * .43,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      border: Border.all(
                                                          color: AppColors
                                                              .skeltonBorderColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              46)),
                                                  child: Row(
                                                    children: [
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              userProfileColor,
                                                          builder: (BuildContext
                                                                  context,
                                                              value,
                                                              Widget? child) {
                                                            return Container(
                                                              height: 50,
                                                              width: 50,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: convertColor(
                                                                    color: memoriesList[
                                                                            index]
                                                                        .user!
                                                                        .profileColor!),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                                child: memoriesList[index]
                                                                            .user!
                                                                            .profileImage !=
                                                                        ''
                                                                    ? CachedNetworkImage(
                                                                        imageUrl: memoriesList[index]
                                                                            .user!
                                                                            .profileImage,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            50,
                                                                        width:
                                                                            50,
                                                                        progressIndicatorBuilder: (context,
                                                                                url,
                                                                                downloadProgress) =>
                                                                            CircularProgressIndicator(value: downloadProgress.progress),
                                                                      )
                                                                    : Text(
                                                                        memoriesList[index]
                                                                            .user!
                                                                            .name![0]
                                                                            .toUpperCase(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                24,
                                                                            color:
                                                                                Colors.white,
                                                                            fontFamily: robotoRegular),
                                                                      ),
                                                              ),
                                                            );
                                                          }),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (type ==
                                                                    'Shared' ||
                                                                type ==
                                                                    'Published')
                                                              Text(
                                                                memoriesList[
                                                                        index]
                                                                    .user!
                                                                    .name!,
                                                                style: const TextStyle(
                                                                    color: AppColors
                                                                        .black,
                                                                    fontFamily:
                                                                        robotoRegular,
                                                                    height:
                                                                        17.2 /
                                                                            13,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            Text(
                                                              memoriesList
                                                                      .isNotEmpty
                                                                  ? memoriesList[
                                                                          index]
                                                                      .title!
                                                                  : "",
                                                              style: const TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                  fontFamily:
                                                                      robotoBold,
                                                                  height:
                                                                      17.2 / 15,
                                                                  fontSize: 15),
                                                              maxLines: 2,
                                                            ),
                                                            if (memoriesList[
                                                                        index]
                                                                    .minUploadedImgDate!
                                                                    .isNotEmpty &&
                                                                memoriesList[
                                                                        index]
                                                                    .maxUploadedImgDate!
                                                                    .isNotEmpty)
                                                              (type == 'Shared' ||
                                                                      type ==
                                                                          'Published')
                                                                  ? Container()
                                                                  : Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(height: 3,),
                                                                      Text(
                                                                          "${CommonWidgets.dateRetrun(memoriesList[index].minUploadedImgDate!)}-${CommonWidgets.maxDateRetrun(memoriesList[index].maxUploadedImgDate!)}",
                                                                          style: const TextStyle(
                                                                            fontStyle: FontStyle.italic,
                                                                              color: AppColors
                                                                                  .black,
                                                                              fontFamily:
                                                                                  robotoRegular,
                                                                              height: 17.2 /
                                                                                  13,
                                                                              fontSize:
                                                                                  10),
                                                                        ),
                                                                    ],
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (memoriesList[index].subCategoryId != '')
                                Positioned(
                                  top: deviceHeight * .085,
                                  child: Container(
                                    width: deviceWidth * .43,
                                    alignment: Alignment.center,
                                    child: Container(
                                        height: 27,
                                        // margin: const EdgeInsets.only(
                                        //     left: 16, right: 16, top: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            color: AppColors.subTitleColor),
                                        child: Text(
                                          memoriesList[index]
                                              .subCategory!
                                              .name!,
                                          style: appTextStyle(
                                              fm: robotoMedium,
                                              height: 27 / 14,
                                              fz: 14,
                                              color: AppColors.black),
                                        )),
                                  ),
                                )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: deviceHeight * .016, left: 18),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 32,
                                    width: 77,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border:
                                            Border.all(color: AppColors.black),
                                        borderRadius:
                                            BorderRadius.circular(26)),
                                    child: Text(
                                      memoriesList[index].postsCount!>1?'${memoriesList[index].postsCount!} Posts':'${memoriesList[index].postsCount!} Post',
                                      style: appTextStyle(
                                          fz: 12,
                                          color: AppColors.black,
                                          height: 24 / 12,
                                          fm: interMedium),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                       Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MemoryDetailPage(
                                              memoryTtile: memoriesList[index].title!,
                                              memoryId: memoriesList[index].id.toString(),
                                              userName: memoriesList[index].user!.name!,
                                              sharedCount: "0",
                                              email: memoriesList[index].user!.id.toString(),
                                              imageLink: memoriesList[index].lastUpdateImg!,
                                              imageCaptions:
                                                  memoriesList[index].user!.profileImage,
                                              pubLished:
                                                  memoriesList[index].published.toString(),
                                              future: future,
                                              photosList: widget.photosList,
                                              subId: memoriesList[index].subCategoryId,
                                              catId:
                                                  memoriesList[index].categoryId.toString(),
                                              selectionType:
                                                  getSelectedCategory(),
                                                  jump: "yes",
                                            ))).then((value) {
                                  refrehScreen();
                                  allCategory();
                               
                                });
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (BuildContext context) =>
                                      //         EditMemoryScreen(
                                      //       photosList: widget.photosList,
                                      //       future: future,
                                      //       isAddPhoto: true,
                                      //       fromEdit: false,
                                      //       title: memoriesList[index].title,
                                      //       memoryId: memoriesList[index]
                                      //           .id
                                      //           .toString(),
                                      //       subId: memoriesList[index]
                                      //           .subCategoryId,
                                      //       cateId: memoriesList[index]
                                      //           .categoryId
                                      //           .toString(),
                                      //       memoryListData: [],
                                      //     ),
                                      //   ),
                                      // ).then((value) {
                                      //   if (value != null) {
                                      //     refrehScreen();
                                      //     allCategory();
                                      //   }
                                      // });
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        height: 32,
                                        width: 39,
                                        decoration: BoxDecoration(
                                            color: AppColors.black,
                                            borderRadius:
                                                BorderRadius.circular(26)),
                                        child: Image.asset(
                                          add,
                                          height: 9,
                                          width: 9,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          );
  }

  String getSelectedCategory() {
    for (var category in categoryModel.categories!) {
      if (category.isSelected) {
        print(category.name!);
        return category.name!;
      }
    }
    return '';
  }

  addLableBottomSheet(BuildContext context, String name, String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController memoryTitleController =
            TextEditingController(text: name);
        FocusNode focusNode1 = FocusNode();

        // Ensure the keyboard is displayed when the bottom sheet opens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode1.requestFocus();
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
                    Container(
                      height: 48,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              titleController.clear();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 1.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.close),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            name == ''
                                ? AppStrings.addCategory
                                : AppStrings.editCategory,
                            style: appTextStyle(
                                fm: robotoBold,
                                height: 25 / 20,
                                fz: 20,
                                color: AppColors.black),
                          ),
                          const Spacer(),
                          GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                EasyLoading.show();
                                if (name == '') {
                                  ApiCall.createCategory(
                                      api: ApiUrl.createCategory,
                                      name: memoryTitleController.text,
                                      callack: this);
                                } else {
                                  ApiCall.ediCategory(
                                      api: ApiUrl.updateCategory,
                                      id: id,
                                      name: memoryTitleController.text,
                                      callack: this);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Text(
                                  AppStrings.next,
                                  style: appTextStyle(
                                      fm: interRegular,
                                      fz: 17,
                                      color:
                                          memoryTitleController.text.isNotEmpty
                                              ? AppColors.primaryColor
                                              : AppColors.hintColor),
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    Text(
                      AppStrings.categoryTitle,
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
                      focusNode: focusNode1,
                      textInputAction: TextInputAction.done,
cursorWidth: 2,cursorHeight: 27,
                              
                    cursorColor: AppColors.primaryColor,
                              
                      onFieldSubmitted: (v) {
                        Navigator.pop(context);
                        EasyLoading.show();
                        if (name == '') {
                          ApiCall.createCategory(
                              api: ApiUrl.createCategory,
                              name: memoryTitleController.text,
                              callack: this);
                        } else {
                          ApiCall.ediCategory(
                              api: ApiUrl.updateCategory,
                              id: id,
                              name: memoryTitleController.text,
                              callack: this);
                        }
                      },
                      style: appTextStyle(
                        fm: interRegular,
                        fz: 21,
                            height: 1.3, // Line height for proper text alignment

                        color: Colors.black,
                      ),
                      onChanged: (c) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        
                        border: InputBorder.none, // No underline border
                        enabledBorder:
                            InputBorder.none, // No underline when enabled
                        focusedBorder: InputBorder.none,
                        hintText: 'Add Category title here',
                        hintStyle: appTextStyle(
                          fm: interRegular,
                          fz: 21,
    height: 1.3, // Line height for proper text alignment
                          color: AppColors.hintColor,
                        ),
                        contentPadding: EdgeInsets.zero, // Ensure no additional padding
    isDense: true,
                      ),
                    ).paddingOnly(left:10),
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
