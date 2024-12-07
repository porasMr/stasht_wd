// ignore_for_file: unnecessary_new, prefer_const_constructors

import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stasht/modules/create_memory/create_memory.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memory_details/add_caption.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';

import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/file_path.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:stasht/utils/shimmer_widget.dart';

import '../../utils/app_strings.dart';
import 'package:timeago/timeago.dart' as timeago;

class MemoryDetailPage extends StatefulWidget {
  MemoryDetailPage(
      {super.key,
      required this.memoryTtile,
      required this.userName,
      required this.memoryId,
      required this.sharedCount,
      required this.email,
      required this.imageCaptions,
      required this.imageLink,
      required this.pubLished,
      required this.future,
      required this.photosList});
  String memoryTtile = '';
  String userName = '';
  String memoryId = '';
  String sharedCount = '';
  String email = '';
  String imageCaptions = '';
  String pubLished = '0';
  String imageLink;
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage>
    implements ApiCallback {
  // int? mainIndex;
  MemoryDetailsModel memoriesModel = MemoryDetailsModel();

  UserModel model = UserModel();
  int _currentPage = 1;
  bool isSelected = false;
  bool _isLoading = false;
  bool _hasMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      print("${widget.email} ${model.user!.id}");
      setState(() {});
    });
    
    ApiCall.memoryDetails(
        api: ApiUrl.memoryDetail,
        id: widget.memoryId,
        page: _currentPage.toString(),
        callack: this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMore) {
          _isLoading = true;
          _currentPage = _currentPage + 1;
          _hasMore = false;
          ApiCall.memoryDetails(
              api: ApiUrl.memoryDetail,
              id: widget.memoryId,
              page: _currentPage.toString(),
              callack: this);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return memoriesModel.data == null
        ? Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 35, left: 30),
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      shimmerWidget(43, 43),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shimmerWidget(12, 150),
                          SizedBox(
                            height: 10,
                          ),
                          shimmerWidget(12, 63),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(35),
                                    topRight: Radius.circular(35),
                                  ),
                                  child: shimmerWidget(
                                      303, MediaQuery.of(context).size.width)),
                              Container(
                                height: 143,
                                padding: EdgeInsets.only(
                                    top: 16, left: 16, right: 16, bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.textfieldFillColor
                                        .withOpacity(.75),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(35),
                                    // Applied the bottom radius
                                    bottomRight: Radius.circular(35),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(999)),
                                          child: shimmerWidget(43, 43),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(999)),
                                              child: shimmerWidget(12, 120),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(999)),
                                              child: shimmerWidget(13, 138),
                                            ),
                                          ],
                                        ),
                                        shimmerWidget(21, 23),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    shimmerWidget(12, 295),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    shimmerWidget(12, 295),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    shimmerWidget(12, 111),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ))
        : Container(
            color: Colors.white,
            child: Scaffold(
                bottomNavigationBar: /*controller.detailMemoryModel!.sharedWith!.isNotEmpty?IgnorePointer():*/
                    BottomAppBar(
                  height: 107,
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            String memoryId = widget.memoryId;
                            String title = widget.memoryTtile;
                            String fullImageUrl = widget.imageLink;
                            String baseUrl =
                                "https://stasht-data.s3.us-east-2.amazonaws.com/images/";
                            String imageIdentifier =
                                fullImageUrl.replaceFirst(baseUrl, "");

                            String link = await CommonWidgets.createDynamicLink(
                                memoryId, title, imageIdentifier);

                            if (link.isNotEmpty) {
                              try {
                                // await Share.share(link);
                              } catch (error) {
                                debugPrint("Error sharing link: $error");
                              }
                            } else {
                              debugPrint("Error: Link generation failed.");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  collab,
                                  height: 30,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "COLLABORATORS",
                                  style: appTextStyle(
                                      fz: 10,
                                      fw: FontWeight.w600,
                                      fm: interMedium,
                                      height: 20 / 10),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Image.asset(home,height:63),
                        GestureDetector(
                          onTap: () {
                            publishMemoryBottomSheet(context);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, right: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/publish.png",
                                  height: 40,
                                ),
                                Text(
                                  "PUBLISH",
                                  style: appTextStyle(
                                      fz: 10,
                                      fw: FontWeight.w600,
                                      fm: interMedium,
                                      height: 20 / 10),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                appBar: AppBar(
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  leadingWidth: 45,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 22.0, bottom: 8),
                      child: Image.asset("assets/images/left_arrow.png"),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.memoryTtile,
                        style: appTextStyle(
                            fm: robotoRegular,
                            fz: 22,
                            height: 28 / 22,
                            color: AppColors.monthColor),
                      ),
                      Text(
                        "${widget.userName} ${widget.sharedCount}",
                        style: appTextStyle(
                            fm: robotoRegular,
                            fz: 12,
                            height: 19.2 / 12,
                            color: AppColors.black),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: widget.email == model.user!.id.toString() ? 20 : 0.0),
                      child: GestureDetector(
                        onTap: () {
                          isSelected = !isSelected;
                          // controller.isSelected.value =
                          //     !controller.isSelected.value;
                          // controller.update();
                          if (isSelected) {
                            memoriesModel.data!.data!.sort((a, b) {
                              return b.captureDate!.compareTo(a.captureDate!);
                            });
                          } else {
                            memoriesModel.data!.data!.sort((a, b) {
                              return a.captureDate!.compareTo(b.captureDate!);
                            });
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: isSelected
                            ? Image.asset(
                                filterAbove,
                                height: 16,
                              )
                            : Image.asset(
                                filter,
                                height: 16,
                              ),
                      ),
                    ),
                    widget.email == model.user!.id.toString() 
                        ? GestureDetector(
                            onTapDown: (details) {
                              showPopupMenu(context, true, details)
                                  .then((value) {
                                if (value != null && value == "Delete") {
                                  deleteMemoryDialog(context);

                                  
                                  
                                } else if (value != null && value == "Edit") {
                                } else {
                                  //  Get.back();
                                }
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 15.0, bottom: 3),
                              child: Icon(Icons.more_vert,
                                  size: 33, color: Colors.black),
                            ),
                          )
                        : GestureDetector(
                            onTapDown: (details) {
                              showPopupMenu(context, false, details)
                                  .then((value) {
                                if (value != null && value == "Delete") {
                                                                   deleteMemoryDialog(context);

                                } else if (value != null && value == "Edit") {
                                } else {
                                  //  Get.back();
                                }
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 15.0, bottom: 3),
                              child: Icon(Icons.more_vert,
                                  size: 33, color: Colors.black),
                            ),
                          )
                  ],
                ),
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                floatingActionButton: /*controller.detailMemoryModel!.sharedWith!.isNotEmpty?IgnorePointer(): */
                    Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      bottom: 20,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                               Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CreateMemoryScreen(
                                photosList: widget.photosList,
                                future: widget.future,
                                isBack: true,
                                isEdit: true,
                                memoryListData: memoriesModel.data!.data!,
                              ),
                            ),
                          ).then((value) {
                            if (value != null) {
                              _currentPage = 1;
                              ApiCall.memoryDetails(
                                  api: ApiUrl.memoryDetail,
                                  id: widget.memoryId,
                                  page: _currentPage.toString(),
                                  callack: this);
                            }
                          });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/fabIcon.png",
                                  height: 67,
                                ),
                                Image.asset("assets/images/addFabIcon.png",
                                    height: 23),
                              ],
                            ),
                          ),
                          Text(
                            "ADD",
                            style: appTextStyle(
                                fz: 14,
                                fm: interBold,
                                height: 29 / 14,
                                color: AppColors.black),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                body: memoriesModel.data!.data!.isEmpty
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CreateMemoryScreen(
                                photosList: widget.photosList,
                                future: widget.future,
                                isBack: true,
                                isEdit: true,
                                memoryListData: [],
                              ),
                            ),
                          ).then((value) {
                            if (value != null) {
                              _currentPage = 1;
                              ApiCall.memoryDetails(
                                  api: ApiUrl.memoryDetail,
                                  id: widget.memoryId,
                                  page: _currentPage.toString(),
                                  callack: this);
                            }
                          });
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * .6,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                    fontFamily: robotoRegular,
                                    color: Colors.black,
                                    fontSize: 12,
                                    height: 19.2 / 12),
                              ),
                              const Text(
                                "Add  media to your memory now",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontFamily: robotoRegular,
                                    color: AppColors.primaryColor,
                                    fontSize: 12,
                                    height: 19.2 / 12),
                              ),
                            ],
                          )),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 5),
                        itemCount: memoriesModel.data!.data!.length,
                        reverse: false,
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(35),
                                        topRight: Radius.circular(35),
                                      ),
                                      child: Container(
                                        color: Colors.white,
                                        child: CachedNetworkImage(
                                          height: 304,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          imageUrl: memoriesModel
                                              .data!.data![index].imageLink!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 304,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.grey[300],
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) {
                                            return SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Icon(Icons.error_outline),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    widget.email == model.user!.id.toString() 
                                        ? GestureDetector(
                                            onTapDown: (details) {
                                              showPopupMenu(
                                                      context, true, details)
                                                  .then((value) {
                                                if (value != null &&
                                                    value.isNotEmpty &&
                                                    value == "Delete") {
                                                      deletePostDialog(context ,memoriesModel
                                                          .data!.data![index].id
                                                          .toString());
                                                  
                                                } else if (value != null &&
                                                    value.isNotEmpty &&
                                                    value == "Edit") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AddCaption(
                                                                id: widget
                                                                    .memoryId,
                                                                memoriesModel:
                                                                    memoriesModel
                                                                            .data!
                                                                            .data![
                                                                        index],
                                                              ))).then((value) {
                                                    if (value) {
                                                      memoriesModel
                                                          .data!
                                                          .data![index]
                                                          .description = value;
                                                      setState(() {});
                                                    }
                                                  });
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 17, top: 20),
                                              height: 31,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.white
                                                      .withOpacity(.4)),
                                              child: Icon(Icons.more_vert),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTapDown: (details) {
                                              showPopupMenu(
                                                      context, false, details)
                                                  .then((value) {
                                                if (value != null &&
                                                    value.isNotEmpty &&
                                                    value == "Delete") {
                                                      deletePostDialog(context ,memoriesModel
                                                          .data!.data![index].id
                                                          .toString());
                                                  
                                                } else if (value != null &&
                                                    value.isNotEmpty &&
                                                    value == "Edit") {}
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 17, top: 20),
                                              height: 31,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.white
                                                      .withOpacity(.4)),
                                              child: Icon(Icons.more_vert),
                                            ),
                                          )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, top: 16, bottom: 24),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                            color: AppColors.textfieldFillColor
                                                .withOpacity(.25))
                                      ],
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(35),
                                        bottomLeft: Radius.circular(35),
                                      ),
                                      color: Colors.white,
                                      border: Border.all(
                                          color: AppColors.textfieldFillColor)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          memoriesModel.data!.data![index].user!
                                                      .profileImage !=
                                                  ""
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(35),
                                                  child: CachedNetworkImage(
                                                    height: 43,
                                                    width: 43,
                                                    imageUrl: memoriesModel
                                                        .data!
                                                        .data![index]
                                                        .user!
                                                        .profileImage,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) {
                                                      return Image.asset(
                                                          userIcon);
                                                    },
                                                    errorWidget:
                                                        (context, url, error) {
                                                      return Image.asset(
                                                          userIcon);
                                                    },
                                                  ),
                                                )
                                              : Container(
                                                  height: 43,
                                                  width: 43,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors
                                                          .primaryColor /*??
                                                                  AppColors.primaryColor,*/
                                                      ),
                                                  child: Text(
                                                    memoriesModel
                                                        .data!
                                                        .data![index]
                                                        .user!
                                                        .name![0]
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        color: Colors.white,
                                                        fontFamily:
                                                            robotoRegular),
                                                  ),
                                                ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  memoriesModel.data!
                                                      .data![index].user!.name!,
                                                  style: appTextStyle(
                                                      fm: robotoRegular,
                                                      fz: 13,
                                                      height: 19.2 / 13,
                                                      color: AppColors
                                                          .memoeylaneColor),
                                                ),
                                                if (memoriesModel
                                                        .data!
                                                        .data![index]
                                                        .location !=
                                                    "")
                                                  Text(
                                                    memoriesModel.data!
                                                        .data![index].location,
                                                    style: appTextStyle(
                                                        fm: robotoRegular,
                                                        fz: 12,
                                                        height: 19.2 / 12,
                                                        color: AppColors
                                                            .hintColor),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Spacer(),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Image.asset(
                                                    comment,
                                                    height: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3.0),
                                                    child: Text(
                                                      memoriesModel
                                                          .data!
                                                          .data![index]
                                                          .commentsCount
                                                          .toString(),
                                                      style: appTextStyle(
                                                          fm: robotoRegular,
                                                          fz: 20,
                                                          height: 28 / 19),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      memoriesModel.data!.data![index]
                                                  .description !=
                                              ''
                                          ? RichText(
                                              text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Image.asset(
                                                    time,
                                                    height: 20,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: CommonWidgets
                                                      .dateFormatRetrun(
                                                          memoriesModel
                                                              .data!
                                                              .data![index]
                                                              .captureDate!),

                                                  style: appTextStyle(
                                                    fm: robotoItalic,
                                                    fz: 14,
                                                    height: 19.2 / 14,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  // Customize the text style as needed
                                                ),
                                                TextSpan(
                                                  text:
                                                      "  ${memoriesModel.data!.data![index].description}",
                                                  style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily: robotoRegular,
                                                    fontSize: 14,
                                                    height: 19.2 / 14,
                                                    color: AppColors.black,
                                                  ), // Hashtag style (e.g., blue color)
                                                ),
                                              ],
                                            ))
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Image.asset(
                                                  time,
                                                  height: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  CommonWidgets
                                                      .dateFormatRetrun(
                                                          memoriesModel
                                                              .data!
                                                              .data![index]
                                                              .captureDate!),
                                                  style: appTextStyle(
                                                    fm: robotoItalic,
                                                    fz: 14,
                                                    height: 19.2 / 14,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                // Add some spacing between the timestamp and caption
                                                if (widget.email ==
                                                   model.user!.id.toString() )
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  AddCaption(
                                                                    id: widget
                                                                        .memoryId,
                                                                    memoriesModel:
                                                                        memoriesModel
                                                                            .data!
                                                                            .data![index],
                                                                  ))).then(
                                                          (value) {
                                                        if (value) {
                                                          memoriesModel
                                                                  .data!
                                                                  .data![index]
                                                                  .description =
                                                              value;
                                                          setState(() {});
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      "+ Add a description",
                                                      style: appTextStyle(
                                                        fm: robotoRegular,
                                                        fz: 14,
                                                        height: 19.2 / 14,
                                                        color:
                                                            AppColors.hintColor,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )));
  }

  void publishMemoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25), topLeft: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25)),
                  color: Colors.white),
              child: SingleChildScrollView(
                // controller: controller.scrollController1,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 5,
                      width: 36,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.dragColor),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.close),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Text(
                              AppStrings.publish,
                              style: appTextStyle(
                                  fm: robotoBold,
                                  height: 25 / 20,
                                  fz: 20,
                                  color: AppColors.black),
                            ),
                          ),
                          SizedBox()
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75)),
                    // const SizedBox(height: 5),
                    _publishView(),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        barrierColor: Colors.transparent,
        elevation: 6,
        context: context);

    /*showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                color: Colors.white),
            // height: 220,
            // padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          "Would you like to publish your memory",
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                              fontFamily: robotoBold),
                        )),
                  ),
                  Container(
                    height: 1,
                    color: AppColors.viewColor,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          controller.publishMemory(
                              controller.detailMemoryModel!,
                              controller.detailMemoryModel!.memoryId!);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: AppColors.hintTextColor),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryColor,
                                fontFamily: robotoBold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: AppColors.hintTextColor),
                          child: const Text(
                            'No',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryColor,
                                fontFamily: robotoBold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
          );
        });*/
  }

  String formatTimestamp(timestamp) {
    // Create a DateFormat instance for the desired format
    DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('MMM d, yyyy');

    // Format the timestamp
    return "\t${formatter.format(dateTime)}";
  }

  showDeleteBottomSheet(BuildContext context, String memoryId, int index,
      {double? currentScrollPosition}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                color: Colors.white),
            height: 200,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    'Are you sure you want to delete?',
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.darkColor,
                        fontFamily: robotoBold),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        CommonWidgets.successDialog(
                            context, "The photo has been successfully deleted");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: AppColors.hintTextColor),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primaryColor,
                              fontFamily: robotoBold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: AppColors.hintTextColor),
                        child: const Text(
                          'No',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primaryColor,
                              fontFamily: robotoBold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void showReportBottomSheet(
    BuildContext context,
    String memoryId,
    int index,
  ) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.3,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                color: Colors.white),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    'Enter your concern and report.',
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.darkColor,
                        fontFamily: robotoBold),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            Colors.grey, //                   <--- border color
                        width: 2.0,
                      ),
                    ),
                    child: TextFormField(
                      validator: (v) {
                        if (v!.isEmpty || v.length < 2) {
                          return 'Enter valid message!';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      minLines: 1,
                      maxLines: 10,
                      cursorColor: AppColors.primaryColor,
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Enter message.."),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: MaterialButton(
                    onPressed: () {},
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    color: AppColors.primaryColor,
                    child: const Text('Submit',
                        style: TextStyle(fontSize: 14.0, color: Colors.white)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }

  Widget moreButton(
    BuildContext context,
    String memoryId,
    int index,
  ) {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        // popupmenu item 1
        PopupMenuItem(
          value: 1,
          // row has two child icon and text.
          child: Row(
            children: const [
              Icon(Icons.delete),
              // SizedBox(
              //   // sized box with width 10
              //   width: 10,
              // ),
              Text("Delete")
            ],
          ),
        ),
        if (widget.email != model.user!.id.toString() )
          PopupMenuItem(
            value: 2,
            // row has two child icon and text.
            child: Row(
              children: const [
                Icon(Icons.report),
                SizedBox(
                  // sized box with width 10
                  width: 10,
                ),
                Text("Report")
              ],
            ),
          ),
      ],
      offset: const Offset(-10, 40),
      color: Colors.white,
      splashRadius: 5,
      elevation: 2,
      // position: RelativeRect.fromLTRB(100, 100, 100, 100),
      icon: const Icon(Icons.more_vert, color: Colors.black),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      onSelected: (value) {
        print(value);
        // if (value == 1) {
        //   showDeleteBottomSheet(context, memoriesModel.memoryId!, index,
        //       controller, memoriesModel, memoriesModel.imagesCaption![index]);
        // } else {
        //   controller.reportController.value.text = '';
        //   showReportBottomSheet(context, memoriesModel.memoryId!, index,
        //       controller, memoriesModel, memoriesModel.imagesCaption![index]);
        // }
      },
    );
  }

  var linksName = ["Web Link"];
  var images = [
    "assets/images/attach.png",
  ];
  var linksDescription = [
    "Embed a link in your blog, or share a link with friends, family or colleagues. No app required!",
  ];

  _publishView() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          itemCount: linksName.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                EasyLoading.show();
                ApiCall.memoryPublished(
                    api: ApiUrl.memoryPublished,
                    status: widget.pubLished,
                    id: widget.memoryId,
                    callack: this);
              },
              child: Container(
                height: 118,
                margin: EdgeInsets.only(bottom: 15, left: 20, right: 20),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.textfieldFillColor.withOpacity(.75)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(linksName[index],
                              style: appTextStyle(
                                  fm: robotoMedium, height: 25 / 17, fz: 17)),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0, bottom: 3),
                            child: Image.asset(
                              images[index],
                              height: index == 0 ? 30 : 20,
                            ),
                          )
                        ]),
                    SizedBox(height: 4),
                    Text(linksDescription[index],
                        style: appTextStyle(
                            fm: robotoRegular, height: 19 / 14, fz: 14)),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void socialLinkMemoryBottomSheet(String link) {
    print(link);
    showModalBottomSheet(
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25), topLeft: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
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
                  color: Colors.white),
              child: SingleChildScrollView(
                // controller: controller.scrollController1,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      height: 4,
                      width: 32,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.dragColor),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(Icons.close),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Text(
                            AppStrings.socailLink,
                            style: appTextStyle(
                                fm: robotoBold,
                                height: 25 / 20,
                                fz: 20,
                                color: AppColors.black),
                          ),
                        ),
                        const SizedBox()
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                        color: AppColors.textfieldFillColor.withOpacity(.75)),
                    //const SizedBox(height: 20),
                    // GestureDetector(
                    //     onTap: () async {
                    //       final result =
                    //           await Share.share('check out my memory $link');

                    //       if (result.status == ShareResultStatus.success) {
                    //         print('Thank you for sharing!');
                    //       }
                    //     },
                    //     child: CommonWidgets.buttonForShareLink(
                    //         color: AppColors.primaryColor,
                    //         title: "Share",
                    //         context)),
                    const SizedBox(height: 20),
                    GestureDetector(
                        onTap: () async {
                          CommonWidgets.loginWithFacebook()!.then((value) {
                            print(value);
                            FilePath.postImageToFacebook(
                                link, value!.tokenString, (message) {
                              print(message);
                            });
                          });
                        },
                        child: CommonWidgets.buttonForShareLink(
                            color: const Color(0XFF1877F2),
                            title: "Facebook",
                            context)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // detailMemoryModel!.imagesCaption!.forEach((element) {
                        //   shareOnSocial(element.image, "insta");
                        // });
                      },
                      child: CommonWidgets.buttonForShareLink(
                        color: Color(0XFF3CD3F87),
                        title: "Instagram",
                        context,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
        barrierColor: Colors.transparent,
        elevation: 6,
        context: context);
  }

  String _formatTimeAgo(DateTime dateTime) {
    String timeAgo = timeago.format(dateTime, locale: 'en_short');

    // Check if the result is "now" and capitalize the "n"
    if (timeAgo == 'now') {
      return 'Now';
    }

    return timeAgo;
  }

  @override
  void onFailure(String message) {
    CommonWidgets.errorDialog(context, message);
  }

  @override
  void onSuccess(String data, String apiType) {
    if (apiType == ApiUrl.memoryDetail) {
      if (_isLoading) {
        MemoryDetailsModel nextMemoryModel =
            MemoryDetailsModel.fromJson(json.decode(data));

        _isLoading = false;
        memoriesModel.data!.data!.addAll(nextMemoryModel.data!.data!);
      } else {
        print(data);

        memoriesModel = MemoryDetailsModel.fromJson(json.decode(data));
        print('${memoriesModel.data!.nextPageUrl}');
        if (memoriesModel.data!.nextPageUrl != '') {
          _hasMore = true;
        }
      }
      setState(() {});
    } else if (apiType == ApiUrl.memoryPublished) {
      var url = json.decode(data);
      socialLinkMemoryBottomSheet(url['link'].toString());
      setState(() {});
    } else if (apiType == ApiUrl.deleteMemory) {
      Navigator.pop(context);
    } else if (apiType == ApiUrl.deleteMemoryFile) {
      _currentPage = 0;
      ApiCall.memoryDetails(
          api: ApiUrl.memoryDetail,
          id: widget.memoryId,
          page: _currentPage.toString(),
          callack: this);
    }
    EasyLoading.dismiss();
  }

  @override
  void tokenExpired(String message) {}

  Future<String?> showPopupMenu(BuildContext context, bool isEditShow, details,
      {bool fromList = false}) async {
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

    final selectedItem = await showMenu<String>(
      context: context,
      color: Colors.white,
      surfaceTintColor: Color(0XFFF9F9F9),
      position: position,
      items: [
        if (isEditShow)
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
        if (!fromList)
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
      return value;
    });

    if (selectedItem != null) {
      return selectedItem;
    }
    return null;
  }

   deleteMemoryDialog(BuildContext context,) {
    showDialog(
      barrierColor: Colors.transparent,
       context: context, builder: (BuildContext context) { return Dialog(
        backgroundColor: AppColors.textfieldFillColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: 312,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          height: 280,
          // Add padding for spacing
          decoration: BoxDecoration(
            color: AppColors.textfieldFillColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Center content vertically
              children: [
                const SizedBox(
                  height: 25,
                ),
                Text(
                  AppStrings.deleteMemory,
                  style: appTextStyle(
                    fz: 24,
                    height: 32 / 24,
                    fm: robotoRegular,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 16),
                // Add spacing between elements
                Text(
                  "By tapping “Delete”, you are choosing to delete this memory permanently including photos and comments.",
                  style: appTextStyle(
                    fz: 14,
                    height: 20 / 14,
                    fm: robotoRegular,
                    color: AppColors.dialogMiddleFontColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 40),
                // Add spacing before the close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
Navigator.pop(context);                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppStrings.cancel,
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
                    SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                         EasyLoading.show();
                                  ApiCall.deleteMemory(
                                      api: ApiUrl.deleteMemory,
                                      id: widget.memoryId,
                                      callack: this);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppStrings.delete,
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
              ],
            ),
          ),
        ),
      ); },
    );
  }

  deletePostDialog(
      BuildContext context,
      String id
     ) {
    showDialog(
      context:context,
      barrierColor: Colors.transparent, builder: (BuildContext context) { return Dialog(
        backgroundColor: AppColors.textfieldFillColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: 312,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          height: 280,
          // Add padding for spacing
          decoration: BoxDecoration(
            color: AppColors.textfieldFillColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Center content vertically
              children: [
                const SizedBox(
                  height: 25,
                ),
                Text(
                  AppStrings.deletePost,
                  style: appTextStyle(
                    fz: 24,
                    height: 32 / 24,
                    fm: robotoRegular,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 16),
                // Add spacing between elements
                Text(
                  "By tapping “Delete”, you are choosing to delete this post permanently including comments.",
                  style: appTextStyle(
                    fz: 14,
                    height: 20 / 14,
                    fm: robotoRegular,
                    color: AppColors.dialogMiddleFontColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 40),
                // Add spacing before the close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppStrings.cancel,
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
                    const SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () async {
                                                   Navigator.pop(context);

EasyLoading.show();
                                                  ApiCall.deleteMemoryFile(
                                                      api: ApiUrl
                                                          .deleteMemoryFile,
                                                      id: widget.memoryId,
                                                      fileId: id,
                                                      callack: this);
                        
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppStrings.delete,
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
              ],
            ),
          ),
        ),
      ); },
      
    );
  }
}
