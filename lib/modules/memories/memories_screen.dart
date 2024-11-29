import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:stasht/modules/memories/model/category_memory_model.dart';
import 'package:stasht/modules/memories/model/category_model.dart';
import 'package:stasht/modules/memories/model/memories_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/shimmer_widget.dart';

// ignore: must_be_immutable
class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen>
    implements ApiCallback {
  //final MemoriesController controller = Get.put(MemoriesController());
  CategoryModel categoryModel = CategoryModel();
  MemoriesModel memoriesModel = MemoriesModel();
  CategoryMemoryModel categoryMemoryModel = CategoryMemoryModel();
  int selectedId = 0; // Default selected ID
  int selectedIndex = 0;
  bool isAll = false;
  @override
  void initState() {
    super.initState();
    ApiCall.category(api: ApiUrl.categories, callack: this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        categoryModel.categories == null
            ? Container()
            : Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 35,
                      padding: const EdgeInsets.only(left: 15),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              openAddPillBottomSheet('', '');
                            },
                            child: Container(
                                height: 35,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.black),
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
                                  border:
                                      Border.all(color: AppColors.whiteColor),
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
                          Expanded(
                            child: ListView.builder(
                              itemCount: categoryModel.categories!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    selectedCategory(index);
                                  },
                                  onLongPressStart: (details) {
                                    if (categoryModel.categories![index].name !=
                                            "Personal" &&
                                        categoryModel.categories![index].name !=
                                            "Shared" &&
                                        categoryModel.categories![index].name !=
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
                                      title:
                                          categoryModel.categories![index].name,
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
                    const SizedBox(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
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
          border: Border.all(color: AppColors.whiteColor),
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
          categoryMemoryModel.data!.data==null
              ? Container()
              : myMemoriesUI();
    }
  }

  bool anyValueSelected() {
    bool isAnySelected =
        categoryModel.categories!.any((category) => category.isSelected);
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
        callack: this);
  }

  allCategory() {
    for (int i = 0; i < categoryModel.categories!.length; i++) {
      categoryModel.categories![i].isSelected = false;
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
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                            if(memoriesModel.data![index].memorisCount == 0)
                                 Column(
                                    children: [
                                      Image.asset(
                                        noMemoriesPlaceholder,
                                        height: 230,
                                      ),
                                      const SizedBox(height: 16),

                                      // No memory text
                                      const Text(
                                        "You haven't created a memory yet!",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      const SizedBox(height: 20),

                                    
                                    ],
                                  ),
                                
                                                         if (memoriesModel.data!.length == 1)
 
                                 Container(child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [  // Add category title view
                                      _addCategoryTitleView(),
                                      const SizedBox(height: 20),],),)

                          /*   listView(controller
                                                  .modelList[index].memoryList),*/
                        ],
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
                              "Shared",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                            Text(
                              " (0)",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    /*   listView(controller
                                                  .modelList[index].memoryList),*/
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
                              " (0)",
                              style: appTextStyle(
                                color: AppColors.monthColor,
                                fm: robotoRegular,
                                fz: 22,
                                height: 28 / 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    /*   listView(controller
                                                  .modelList[index].memoryList),*/
                  ],
                ),
              )
            ],
          );
  }

  myMemoriesUI() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: Column(
        children: [
          Container(
            height: 49,
            margin: const EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.textfieldFillColor)),
              gradient: LinearGradient(
                colors: [
                  AppColors.selectedTabColor, // Start color
                  Colors.white, // End color
                ],
                begin: Alignment.topCenter,
                // Starting point of the gradient
                end: Alignment.bottomCenter, // Ending point of the gradient
              ),
            ),
            child: ListView.builder(
              itemCount: categoryMemoryModel.subCategories!
                  .where(
                      (element) => element.name != "" && element.name != null)
                  .length,
              itemBuilder: (context, index) {
                var title = categoryMemoryModel.subCategories!
                    .where(
                        (element) => element.name != "" && element.name != null)
                    .toList();
                return GestureDetector(
                  onTap: () {},
                  onLongPressStart: (details) {},
                  child: Align(
                    alignment: Alignment.center, // Center each subTitle
                    child: subTitle(
                        title: title[index].name,
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
          Expanded(
            child: SingleChildScrollView(
              child: categoryMemoryModel.data!.data!.isEmpty
                  ? Container()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      itemCount: categoryMemoryModel.data!.data!.length,
                      shrinkWrap: true,
                      primary: false,
                      addAutomaticKeepAlives: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {},
                            child: Container(
                              height: 90,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              width: MediaQuery.of(Get.context!).size.width,
                              decoration: const BoxDecoration(
                                  border: Border(
                                      // top: BorderSide(
                                      //     color: AppColors.textfieldFillColor),
                                      bottom: BorderSide(
                                          color:
                                              AppColors.textfieldFillColor))),
                              child: SizedBox(
                                height: 71,
                                child: Row(
                                  children: [],
                                ),
                              ),
                            ));
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }

  _addCategoryTitleView() {
    return GestureDetector(
      onTap: () {
        openAddPillBottomSheet('', '');
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

  @override
  void onFailure(String message) {
    Get.snackbar("Error", message, colorText: AppColors.redColor);
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);
    if (apiType == ApiUrl.categories) {
      categoryModel = CategoryModel.fromJson(jsonDecode(data));

      ApiCall.getMomories(api: ApiUrl.memories, callack: this);
    } else if (apiType == ApiUrl.memories) {
      memoriesModel = MemoriesModel.fromJson(jsonDecode(data));
    } else if (apiType == ApiUrl.createCategory) {
      EasyLoading.dismiss();
      ApiCall.category(api: ApiUrl.categories, callack: this);
    } else if (apiType == ApiUrl.deleteCategory) {
      EasyLoading.dismiss();
      ApiCall.category(api: ApiUrl.categories, callack: this);
    } else if (apiType == ApiUrl.updateCategory) {
      EasyLoading.dismiss();
      ApiCall.category(api: ApiUrl.categories, callack: this);
    } else if (apiType == ApiUrl.memoryByCategory) {
      EasyLoading.dismiss();
      categoryMemoryModel = CategoryMemoryModel.fromJson(jsonDecode(data));
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
      FocusScope.of(Get.context!).requestFocus(titleFocusNode);
    });
    titleController.text = name;
    Get.bottomSheet(
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          // Starting size (fraction of the screen height)
          minChildSize: 0.2,
          // Minimum size
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
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
                                titleController.clear();
                                Get.back();
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
                                Get.back();
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
                          color: AppColors.textfieldFillColor.withOpacity(.75)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          focusNode: titleFocusNode,
                          controller: titleController,
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
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
        barrierColor: AppColors.transparentColor,
        isScrollControlled: true,
        elevation: 6);
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
        Overlay.of(Get.context!).context.findRenderObject() as RenderBox;

    // Calculate the position for the popup menu
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        details.globalPosition,
        details.globalPosition,
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<String>(
      context: Get.context!,
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
        openAddPillBottomSheet(name, id);
      } else {
        EasyLoading.show();
        ApiCall.deleteCategory(
            api: ApiUrl.deleteCategory, id: id, callack: this);
      }
    });
  }
}
