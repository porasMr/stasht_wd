// ignore_for_file: unnecessary_new, prefer_const_constructors

import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stasht/modules/comment_screen/comment_screen.dart';
import 'package:stasht/modules/create_memory/change_memory_screen.dart';
import 'package:stasht/modules/create_memory/create_memory.dart';
import 'package:stasht/modules/create_memory/edit_memory.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memory_details/add_caption.dart';
import 'package:stasht/modules/memory_details/model/CollaboratorList.dart';
import 'package:stasht/modules/memory_details/model/add_comment_response_model.dart';
import 'package:stasht/modules/memory_details/model/get_comments_response_model.dart';
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
import 'package:share_plus/share_plus.dart';

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
      required this.photosList,
      required this.selectionType,
      this.subId,
      this.catId,this.jump});
  String memoryTtile = '';
  String userName = '';
  String memoryId = '';
  String sharedCount = '';
  String email = '';
  String imageCaptions = '';
  String pubLished = '0';
  String imageLink;
  String? jump;
  String selectionType;
  List<Future<Uint8List?>> future = [];
  List<PhotoModel> photosList = [];
  String? subId = '';
  String? catId = '';


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

  GetCommentsResponseModel getCommentsResponseModel =
      GetCommentsResponseModel();
  AddCommentResponseModel addCommentResponseModel = AddCommentResponseModel();
  String photoId="";

  bool openCommentLoader = false;
  bool addPostCommentLoader = false;
  var memoryIdComment;
  var imageIdComment;
  CollaboratorList collaBoratorList=new CollaboratorList();
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
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return memoriesModel.data == null
        ? MediaQuery(
                       data:CommonWidgets.textScale(context),

          child: Container(
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
              )),
        )
        : MediaQuery(
                       data:CommonWidgets.textScale(context),

          child: Container(
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
                          widget.selectionType == "Shared"
                              ? Container()
                              : GestureDetector(
                                  onTap: ()  {
                                    if(collaBoratorList.data!=null){
                                   collaboratorBottomSheet();
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
                                          height: 10,
                                        ),
                                        Text(
                                          "COLLABORATORS",
                                          style: appTextStyle(
                                              fz: 10,
                                              fw: FontWeight.w600,
                                              fm: interMedium,
                                              color: widget.email !=
                                                          model.user!.id
                                                              .toString() &&
                                                      widget.pubLished == "0"
                                                  ? Colors.grey
                                                  : null,
                                              height: 20 / 10),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                          // Image.asset(home,height:63),
                          widget.selectionType == "Shared"
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    if (widget.selectionType != "Published") {
                                      publishMemoryBottomSheet(context);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, right: 20),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/images/publish.png",
                                          height: 40,
                                          color: widget.selectionType == "Published"
                                              ? Colors.grey
                                              : null,
                                        ),
                                         const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "PUBLISH",
                                          style: appTextStyle(
                                              fz: 10,
                                              fw: FontWeight.w600,
                                              fm: interMedium,
                                              color: widget.selectionType == "Published"
                                                  ? Colors.grey
                                                  : null,
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
                      child:Padding(
                        padding: const EdgeInsets.only(left:16.0),
                        child: const Icon(Icons.arrow_back,size: 30,),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.memoryTtile,
                          style: appTextStyle(
                              fm: robotoRegular,
                              fz: 20,
                              height: 28 / 22,
                              color: AppColors.monthColor),
                        ),
                        Text(
                          widget.sharedCount=="0"?"${widget.userName}":
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
                            right: widget.selectionType!="Shared"
                                ? 20
                                : 0.0),
                        child: GestureDetector(
                          onTap: () {
                            isSelected = !isSelected;
                            // controller.isSelected.value =
                            //     !controller.isSelected.value;
                            // controller.update();
                            if (isSelected) {
                              memoriesModel.data!.sort((a, b) {
                                return b.captureDate!.compareTo(a.captureDate!);
                              });
                            } else {
                              memoriesModel.data!.sort((a, b) {
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
                     widget.selectionType!="Shared"
                          ? GestureDetector(
                              onTapDown: (details) {
                                showPopupMenu(context, true, details)
                                    .then((value) {
                                  if (value != null && value == "Delete") {
                                    deleteMemoryDialog(context);
                                  } else if (value != null && value == "Edit") {
                                    debugPrint("Edit2");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ChangeCreateMemoryScreen(
                                          photosList: widget.photosList,
                                          future: widget.future,
                                          isAddPhoto: true,
                                          fromEdit:false,
                                          title: widget.memoryTtile,
                                          memoryId: widget.memoryId,
                                          subId: widget.subId,
                                          cateId: widget.catId,
                                          memoryListData:
                                              memoriesModel.data!, isEdit: true,
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        photoId=value;
                                        _currentPage = 1;
          
                                        ApiCall.memoryDetails(
                                            api: ApiUrl.memoryDetail,
                                            id: widget.memoryId,
                                            page: _currentPage.toString(),
                                            callack: this);
                                      }
                                    });
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
                                    debugPrint(""
                                        "Edit1");
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
                                        ChangeCreateMemoryScreen(
                                      photosList: widget.photosList,
                                      future: widget.future,
                                      isAddPhoto: false,
                                                                              fromEdit:false,
          
                                      title: widget.memoryTtile,
                                      memoryId: widget.memoryId,
                                      subId: widget.subId,
                                      cateId: widget.catId,
                                      memoryListData: memoriesModel.data!,
                                      isEdit: true,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                                                          photoId=value;
          
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
                                    height: 90,
                                  ),
                                  Image.asset("assets/images/addFabIcon.png",
                                      height: 23),
                                ],
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  body: memoriesModel.data!.isEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChangeCreateMemoryScreen(
                                  photosList: widget.photosList,
                                  future: widget.future,
                                  isAddPhoto: true,
                                                                          fromEdit:false,
                                                                          isEdit: true,
          
                                  title: widget.memoryTtile,
                                  memoryId: widget.memoryId,
                                  subId: widget.subId,
                                  cateId: widget.catId,
                                  memoryListData: memoriesModel.data!,
                                ),
                              ),
                            ).then((value) {
                              if (value != null) {
                                                                      photoId=value;
          
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
                      : Stack(
                          children: [
                            SingleChildScrollView(
                                                            controller: _scrollController,
          
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                key: const PageStorageKey(
                                    'detailList'), // Key for persistent scroll state
                                addAutomaticKeepAlives: true,
                                padding:
                                    EdgeInsets.only(left: 20, right: 20, top: 5),
                                itemCount: memoriesModel.data!.length,
                                reverse: false,
                                shrinkWrap: true,
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
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  imageUrl: memoriesModel.data!
                                                      [index].imageLink!,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) {
                                                    return Shimmer.fromColors(
                                                      baseColor: Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        height: 304,
                                                        width:
                                                            MediaQuery.of(context)
                                                                .size
                                                                .width,
                                                        color: Colors.grey[300],
                                                      ),
                                                    );
                                                  },
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child:
                                                          Icon(Icons.error_outline),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            memoriesModel
                                                        .data![index].user!.id
                                                        .toString() ==
                                                    model.user!.id.toString()
                                                ? GestureDetector(
                                                    onTapDown: (details) {
                                                      showPopupMenu(context, true,
                                                              details)
                                                          .then((value) {
                                                        if (value != null &&
                                                            value.isNotEmpty &&
                                                            value == "Delete") {
                                                          deletePostDialog(
                                                              context,
                                                              memoriesModel.data!
                                                                  [index].id
                                                                  .toString());
                                                        } else if (value != null &&
                                                            value.isNotEmpty &&
                                                            value == "Edit") {
                                                          debugPrint("Edit3");
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
                                                                               [index],
                                                                      ))).then(
                                                              (value) {
                                                            if (value != null) {
                                                              memoriesModel
                                                                      .data!
                                                                      [index]
                                                                      .description =
                                                                  value;
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
                                                              BorderRadius.circular(
                                                                  20),
                                                          color: Colors.white
                                                              .withOpacity(.4)),
                                                      child: Icon(Icons.more_vert),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTapDown: (details) {
                                                      showPopupMenu(context, false,
                                                              details)
                                                          .then((value) {
                                                        if (value != null &&
                                                            value.isNotEmpty &&
                                                            value == "Delete") {
                                                          deletePostDialog(
                                                              context,
                                                              memoriesModel.data!
                                                                 [index].id
                                                                  .toString());
                                                        } else if (value != null &&
                                                            value.isNotEmpty &&
                                                            value == "Edit") {
                                                          debugPrint("Edit4");
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
                                                              BorderRadius.circular(
                                                                  20),
                                                          color: Colors.white
                                                              .withOpacity(.4)),
                                                      child: Icon(Icons.more_vert),
                                                    ),
                                                  )
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 16,
                                              bottom: 24),
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 4,
                                                    offset: Offset(0, 4),
                                                    color: AppColors
                                                        .textfieldFillColor
                                                        .withOpacity(.25))
                                              ],
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(35),
                                                bottomLeft: Radius.circular(35),
                                              ),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: AppColors
                                                      .textfieldFillColor)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  memoriesModel.data![index]
                                                              .user!.profileImage !=
                                                          ""
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  35),
                                                          child: CachedNetworkImage(
                                                            height: 50,
                                                            width: 50,
                                                            imageUrl: memoriesModel
                                                                .data!
                                                                [index]
                                                                .user!
                                                                .profileImage,
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (context, url) {
                                                              return Image.asset(
                                                                  userIcon);
                                                            },
                                                            errorWidget: (context,
                                                                url, error) {
                                                              return Image.asset(
                                                                  userIcon);
                                                            },
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 50,
                                                          width: 50,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: convertColor(
                                                                color: memoriesModel
                                                                    .data!
                                                                    [index]
                                                                    .user!
                                                                    .profileColor!), /*??
                                                                          AppColors.primaryColor,*/
                                                          ),
                                                          child: Text(
                                                            memoriesModel
                                                                .data!
                                                                [index]
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
                                                          memoriesModel
                                                              .data!
                                                              [index]
                                                              .user!
                                                              .name!,
                                                          style: appTextStyle(
                                                              fm: robotoRegular,
                                                              fz: 14,
                                                              height: 19.2 / 13,
fw:FontWeight.w600,
                                                              color: AppColors
                                                                  .memoeylaneColor),
                                                        ),
                                                        if (memoriesModel
                                                                .data!
                                                                [index]
                                                                .location !=
                                                            "")
                                                          Text(
                                                            memoriesModel
                                                                .data!
                                                                [index]
                                                                .location,
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
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  Comments(
                                                                    memoryId: widget
                                                                        .memoryId,
                                                                    imagePath:
                                                                        memoriesModel
                                                                            .data!
                                                                            [
                                                                                index]
                                                                            .imageLink!,
                                                                    imageId: memoriesModel
                                                                        .data!
                                                                        [
                                                                            index]
                                                                        .id
                                                                        .toString(),
                                                                  ))).then((value) {
                                                        _currentPage = 0;
                                                        ApiCall.memoryDetails(
                                                            api:
                                                                ApiUrl.memoryDetail,
                                                            id: widget.memoryId,
                                                            page: _currentPage
                                                                .toString(),
                                                            callack: this);
                                                      });
                                                    },
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
                                                                const EdgeInsets
                                                                    .only(top: 3.0),
                                                            child: Text(
                                                              memoriesModel
                                                                  .data!
                                                                  [index]
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
                                              RichText(
                                                      text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "${CommonWidgets
                                                              .dateFormatRetrun(
                                                                  memoriesModel
                                                                      .data!
                                                                      [index]
                                                                      .captureDate!)} • ",
                                                          style: TextStyle(fontFamily: robotoRegular,fontStyle: FontStyle.italic,fontSize: 14,color: AppColors.black,)
                                                        
                                                          // Customize the text style as needed
                                                        ),
                                                        TextSpan(
                                                          text: memoriesModel.data![index]
                                                          .description ==
                                                      '' ?" + Add a description":
                                                              memoriesModel.data![index]
                                                          .description , 
                                                          style: TextStyle(
                                                            letterSpacing: 0.2,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            fontFamily:
                                                                robotoRegular,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400,
                                                            height: 19.2 / 14,
                                                            color:memoriesModel.data![index]
                                                          .description == "" ?AppColors.hintColor: AppColors.black,
                                                          ),
                                                          
                                                        ),
                                                      ],
                                                    ))
                                                   
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                          ],
                        ))),
        );
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
                    
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
        if (widget.email != model.user!.id.toString())
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

  String type = 'Web Link';
  var linksName = ["Web Link",
   //"Socials"
   ];
  var images = [
    "assets/images/attach.png",
   // "assets/images/share.png",
  ];
  var linksDescription = [
    "Embed a link in your blog, or share a link with friends, family or colleagues. No app required!",
    //"Memories were meant to be shared. Post a link back to your favorite social media sites.",
  ];

  _publishView() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
          itemCount: linksName.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                type = linksName[index];
                Navigator.pop(context);
                EasyLoading.show();
                ApiCall.memoryPublished(
                    api: ApiUrl.memoryPublished,
                    status: "1",
                    id: widget.memoryId,
                    callack: this);
              },
              child: Container(
                height: 122,
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
    EasyLoading.dismiss();
    CommonWidgets.errorDialog(context, message);
  }
void scrollToPosition(int index) {
    double itemHeight = 390.0; // Approximate height of each ListTile
    double targetOffset = index * itemHeight; // Calculate target offset

    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onSuccess(String data, String apiType) {
    if (apiType == ApiUrl.memoryDetail) {
      
        print(data);

        memoriesModel = MemoryDetailsModel.fromJson(json.decode(data));
        if (memoriesModel.data!.isNotEmpty) {
          widget.memoryTtile = memoriesModel.data![0].memory!.title!;
        }
       int index=0;
       for(int i=0;i<memoriesModel.data!.length;i++){
        if(memoriesModel.data![i].typeId==photoId){
          index=i;
        }
       }
       scrollToPosition(index);

      
      ApiCall.collaboratorList(api: ApiUrl.collabortor,memoryID: widget.memoryId,callack:this);
      setState(() {});
      if(widget.jump!=null&&widget.jump!.isNotEmpty){
           Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ChangeCreateMemoryScreen(
                                    photosList: widget.photosList,
                                    future: widget.future,
                                    isAddPhoto: false,
                                    isEdit: true,
                                                                            fromEdit:false,

                                    title: widget.memoryTtile,
                                    memoryId: widget.memoryId,
                                    subId: widget.subId,
                                    cateId: widget.catId,
                                    memoryListData: memoriesModel.data!,
                                  ),
                                ),
                              ).then((value) {
                                if (value != null) {
                                  _currentPage = 1;
                                                                        photoId=value;

                                  widget.jump="";
                                  ApiCall.memoryDetails(
                                      api: ApiUrl.memoryDetail,
                                      id: widget.memoryId,
                                      page: _currentPage.toString(),
                                      callack: this);
                                }
                              });

      }
    } else if (apiType == ApiUrl.memoryPublished) {
      var url = json.decode(data);
     
        print('${url['link']}');
        Share.share('${url['link']}').then((value) {
          CommonWidgets.successDialog(
              context, "Memory web link published successfully!");
        });
      

      setState(() {});
    } else if (apiType == ApiUrl.deleteMemory) {
      CommonWidgets.successDialog(context, json.decode(data)['message']);

      Navigator.pop(context);
    } else if (apiType == ApiUrl.deleteMemoryFile) {
      CommonWidgets.successDialog(context, json.decode(data)['message']);

      _currentPage = 0;
      ApiCall.memoryDetails(
          api: ApiUrl.memoryDetail,
          id: widget.memoryId,
          page: _currentPage.toString(),
          callack: this);
    } else if (apiType.startsWith(ApiUrl.getComments)) {
      try {
        final responseJson = json.decode(data);
        if (responseJson['data'] != null) {
          Future<GetCommentsResponseModel> commentsFuture = Future.value(
            GetCommentsResponseModel.fromJson(responseJson),
          );
          debugPrint("Comments Data: $data");
          setState(() {
            openCommentLoader = false;
          });
          //_openBottomSheet(context, commentsFuture);
        } else {
          debugPrint("No comments found.");
        }
      } catch (e) {
        debugPrint("Error parsing response: $e");
      }
      setState(() {});
    } else if (apiType == ApiUrl.addComment) {
      final responseJson = json.decode(data);
      try {
        if (responseJson['data'] != null) {
          ApiCall.memoryDetails(
              api: ApiUrl.memoryDetail,
              id: widget.memoryId,
              page: _currentPage.toString(),
              callack: this);
          addCommentResponseModel =
              AddCommentResponseModel.fromJson(responseJson);
          debugPrint("Add Comment Data is : ${addCommentResponseModel.status}");
          setState(() {
            addPostCommentLoader = false;
          });
        }
      } catch (e) {
        debugPrint("Exception is $e");
      }
    }else if(apiType == ApiUrl.collabortor){
collaBoratorList=CollaboratorList.fromJson(json.decode(data));
print(collaBoratorList.data!.length);
setState(() {
  
});
    }else if(apiType==ApiUrl.removeCollaborator){
CommonWidgets.successDialog(context, json.decode(data)['message']);
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

  deleteMemoryDialog(
    BuildContext context,
  ) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
        );
      },
    );
  }

  deletePostDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
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
                                api: ApiUrl.deleteMemoryFile,
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
        );
      },
    );
  }

  collaboratorBottomSheet(){
     showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                               

                                return  StatefulBuilder(builder: ( (context, setState) {
                                  return  Container(
                                                                        
decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),color: Colors.white,),
                                    child: SingleChildScrollView(
                                                  // controller: controller.scrollController1,
                                                  child: Column(
                                                    children: [
                                                     
                                                      const SizedBox(height: 16),
                                                      SizedBox(
                                                        height: 40,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                    Navigator.pop(context);                          },
                                                              child: const Padding(
                                                                padding: EdgeInsets.only(left: 20.0),
                                                                child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Icon(Icons.close),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 10.0),
                                                              child: Row(children: [
                                                                Text(
                                                                  AppStrings.collab,
                                                                  style: appTextStyle(
                                                                      fm: robotoBold,
                                                                      fz: 20,
                                                                      color: Colors.black,
                                                                      height: 25 / 20),
                                                                ),
                                                               
                                                              ]),
                                                            ),
                                                            SizedBox()
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Divider(color: AppColors.textfieldFillColor.withOpacity(.75)),
                                                      // const SizedBox(
                                                      //   height: 20,
                                                      // ),
                                                      GestureDetector(
                                                        onTap: () async{
                                                          debugPrint(
                                      "The Memory Id is ${widget.memoryId}");
                                                                      String memoryId = widget.memoryId;
                                                                      String title = widget.memoryTtile;
                                                                      String fullImageUrl = widget.imageLink;
                                                                      String userName = widget.userName;
                                                                      String userProfileImage =
                                      widget.imageCaptions;
                                                                      debugPrint("UserName is ${widget.userName}");
                                                                      debugPrint(
                                      "UserProfileImage is ${widget.imageCaptions}");
                                                                      String baseUrl =
                                      "https://stasht-data.s3.us-east-2.amazonaws.com/images/";
                                                                      String imageIdentifier =
                                      fullImageUrl.replaceFirst(baseUrl, "");
                                                                      String link =
                                      await CommonWidgets.createDynamicLink(
                                          memoryId,
                                          title,
                                          imageIdentifier,
                                          userName,
                                          userProfileImage);
                                                                      if (link.isNotEmpty) {
                                    try {
                                      await Share.share(link).then((value) {
                                        if (value.status.name == 'success') {
                                          CommonWidgets.successDialog(context,
                                              "Shared collaborator link successfully!");
                                        }
                                        Navigator.pop(context);
                                      });
                                    } catch (error) {
                                      debugPrint("Error sharing link: $error");
                                    }
                                                                      } else {
                                    debugPrint(
                                        "Error: Link generation failed.");
                                                                      }
                                                                      
                                                                      
                                                        },
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Container(
                                                            height: 55,
                                                            width: MediaQuery.of(context).size.width,
                                                            padding:
                                                                const EdgeInsets.only(left: 15, right: 15, top: 18),
                                                            child: Text(
                                                              "+ Invite New",
                                                              textAlign: TextAlign.left,
                                                              style: appTextStyle(
                                                                  fm: robotoRegular, fz: 17, height: 18 / 17),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // const SizedBox(
                                                      //   height: 20,
                                                      // ),
                                                      const SizedBox(height: 5),
                                                      Divider(
                                                        color: AppColors.textfieldFillColor.withOpacity(.75),
                                                        endIndent: 0,
                                                        height: 0,
                                                        indent: 0,
                                                      ),
                                                      _collabView(),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      if (collaBoratorList.data!.isEmpty)
                                                        SizedBox(
                                                          height: 40,
                                                        )
                                                    ],
                                                  ),
                                                ),
                                  );
                                }))
                               ;
                              },
                            );
  }
   _collabView() {
    return 
     ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: collaBoratorList.data!.length,
          shrinkWrap: true,
          primary: true,
          itemBuilder: (BuildContext context, int index) {
            return



                 Column(
                  children: [
                    SwipeActionCell(
                      key: UniqueKey(),
                      trailingActions: <SwipeAction>[
                        SwipeAction(
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Container(
                              color: AppColors.redTrashColor,
                              child: Image.asset(
                                deleteIcon,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          onTap: (CompletionHandler handler) async {
                            Navigator.pop(context);
                            showFirstMemoryDialog(context, index);
                          },
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1)),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                child:  collaBoratorList.data![index].user!.profileImage!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: collaBoratorList.data![index].user!.profileImage!,fit: BoxFit.cover, height: 40,
                              width: 40, )
                                    : Center(
                                        child: Text(
                                          collaBoratorList.data![index].user!.name![0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontFamily: robotoRegular),
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                collaBoratorList.data![index].user!.name!,
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 18 / 17,
                                  fontFamily: robotoRegular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: AppColors.textfieldFillColor.withOpacity(.75),
                      height: 1,
                      thickness: 1.3,
                    ),
                  ],
                );
              
          },
        );
  }

   showFirstMemoryDialog(BuildContext context, int index) {
    showDialog(

      barrierColor: Colors.transparent, context: context, builder: (BuildContext context) { 
return  Dialog(
        backgroundColor: AppColors.textfieldFillColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: 312,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          height: 250,
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
                height: 25,
              ),
              Text(
                AppStrings.deleteCollaborator,
                style: appTextStyle(
                  fz: 24,
                  height: 32 / 24,
                  fm: robotoRegular,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16), // Add spacing between elements
              Text(
                "By tapping “Delete”, you are choosing to delete this user permanently from your memory including photos and comments.",
                style: appTextStyle(
                  fz: 14,
                  height: 20 / 14,
                  fm: robotoRegular,
                  color: AppColors.dialogMiddleFontColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30), // Add spacing before the close button
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
                  SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                       Navigator.pop(context);
                       EasyLoading.show();
                       ApiCall.removeCollaborator(api: ApiUrl.removeCollaborator, memoryID: widget.memoryId, collaboratorId: collaBoratorList.data![index].id.toString(), callack: this);
                         collaBoratorList.data!.removeAt(index);
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
      );

       },
    
    );
  }
}
