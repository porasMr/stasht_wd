import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stasht/modules/login_signup/domain/user_model.dart';
import 'package:stasht/modules/memory_details/model/get_comments_response_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:stasht/utils/pref_utils.dart';

class Comments extends StatefulWidget {
  Comments({super.key, this.memoryId, this.imagePath,this.imageId});
  String? memoryId = '';
    String? imageId = '';

  String? imagePath = '';
  


  @override
  State<Comments> createState() => CommentsState();
}

class CommentsState extends State<Comments> implements ApiCallback {
  TextEditingController commentController = TextEditingController();
  GetCommentsResponseModel commentModel = GetCommentsResponseModel();
ScrollController _scrollController =  ScrollController();
  List<CommentData>? commentData=[];
UserModel model=UserModel();

  @override
  void initState() {
    super.initState();
     PrefUtils.instance.getUserFromPrefs().then((value) {
      model = value!;
      
      setState(() {});
    });
    EasyLoading.show();
    ApiCall.getComments(api: ApiUrl.getComments+"?memory_id=${widget.memoryId}&image_id=${widget.imageId}", callack: this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(
              fontSize: 20, fontFamily: robotoMedium, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
       
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.imagePath!),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: commentModel.data!=null?
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color:Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))),
          
                      child: Column(
                        mainAxisSize:MainAxisSize.min,
                        children: [
                                  Container(padding: EdgeInsets.all(16),child:  Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                            color: AppColors.hintColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5)),
                      ) ,),
                       Container(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        
                        Text(
                           AppStrings.comment,
                          style: appTextStyle(
                              fm: robotoBold,
                              height: 25 / 20,
                              fz: 20,
                              color: AppColors.black),
                        ),
                       
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                          Container(
                                                         constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width, // 80% of screen width
                            maxHeight: MediaQuery.of(context).size.height/2-200, // 50% of screen height
                          ),                        child: ListView.builder(
                                padding: EdgeInsets.zero,
                                controller: _scrollController,
                                reverse: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                   
                                      
                                      Container(
                                        margin:
                                            const EdgeInsets.symmetric(horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              margin: const EdgeInsets.only(right: 5),
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle),
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(30)),
                                                child: commentData![index].user!.profileImage !=""? 
                                                CachedNetworkImage(
                                                        imageUrl: commentData![index].user!.profileImage!,
                                                        height: 40,
                                                        width: 40,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: 40,
                                                        width: 40,
                                                        alignment: Alignment.center,
                                                        decoration:  BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: convertColor(color:commentData![index].user!.profileColor!),
                                                        ),
                                                        child: Text(
                                                         commentData![index].user!.name.toString()[0].toUpperCase(),
                                                          style: const TextStyle(
                                                              fontSize: 22,
                                                              color: Colors.black,
                                                              fontFamily:
                                                                  robotoRegular),
                                                        ),
                                                      ),
                              
                                                /* Image.asset(
                                                                userIcon,
                                                                fit: BoxFit.fill,
                                                                color: Colors.white,
                                                              ),*/
                                              ),
                                            ),
                                                                                                SizedBox(width: 3,),
          
                                            Expanded(
                                                child: Container(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        commentData![index].user!.name!+" • ",
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.black, 
                                                            fontFamily: robotoBold),
                                                      ),
                                                      Container(
                                              child: Text(
          CommonWidgets.formatTimeAgo(DateTime.parse(commentData![index].createdAt!)),                                                  style: const TextStyle(
                                                    fontSize: 11.0,
                                                    fontStyle: FontStyle.italic,
                                                    color: AppColors.hintColor),
                                              ),
                                            )
                                                    ],
                                                  ),
                                                  SizedBox(height: 3,),
                                                  Text(
                                                    commentData![index].description!,
                                                    style: const TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black),
                                                  )
                                                ],
                                              ),
                                            )),
                                            
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left:16.0,right:16.0),
                                        child: Container(
                                          height: 0.5,
                                          color: Colors.grey.withOpacity(0.2),
                                          margin: const EdgeInsets.symmetric(vertical: 7),
                                        ),
                                      )
                                    ],
                                  );
                                },
                                itemCount: commentData!.length,
                                shrinkWrap: true,
                                
                              ),
                          ),
                        ],
                      ),
                    ):Container( 
                      padding: EdgeInsets.all(5),
                      child: Column(mainAxisSize: MainAxisSize.min,
                        children: [  Container(padding: EdgeInsets.all(16),child:  Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                            color: AppColors.hintColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5)),
                      ) ,),
                       Container(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        
                        Text(
                           AppStrings.comment,
                          style: appTextStyle(
                              fm: robotoBold,
                              height: 25 / 20,
                              fz: 20,
                              color: AppColors.black),
                        ),
                       
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    color: Colors.grey.withOpacity(0.5),
                  ),],),
                      decoration: BoxDecoration(color:Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))))),
              ),
              Container(color: Colors.white,
                child: Row(
                  children: [
                                                                  SizedBox(width: 16,),
          
                     Container(
                                              height: 55,
                                              width: 55,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle),
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(30)),
                                                child: model.user!.profileImage !=""? 
                                                CachedNetworkImage(
                                                        imageUrl: model.user!.profileImage!,
                                                        height: 55,
                                                        width: 55,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: 55,
                                                        width: 55,
                                                        alignment: Alignment.center,
                                                        decoration:  BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: convertColor(color:model.user!.profileColor),
                                                        ),
                                                        child: Text(
                                                         model.user!.name.toString()[0].toUpperCase(),
                                                          style: const TextStyle(
                                                              fontSize: 22,
                                                              color: Colors.black,
                                                              fontFamily:
                                                                  robotoRegular),
                                                        ),
                                                      ),
                              
                                                /* Image.asset(
                                                                userIcon,
                                                                fit: BoxFit.fill,
                                                                color: Colors.white,
                                                              ),*/
                                              ),
                                            ),
                  
                    Expanded(
                      child: Container(
                        decoration:  BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(24)),
                        border: Border.all(width: 1, color: const Color.fromARGB(255, 52, 9, 9)), // Corrected from 'height' to 'width'
                      ),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Row(children: [
                           Expanded(
                              child: TextField(
                            onTap: () {},
                            controller: commentController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Add a comment',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                hintStyle:
                                    TextStyle(fontSize: 16.0, color: Colors.grey)),
                                      onSubmitted: (v){
                                        if (commentController.text.trim().isNotEmpty) {
                                    EasyLoading.show();
                                    ApiCall.addComment(
                                              api: ApiUrl.addComment,
                                              callack: this,
                                              imageId: widget.imageId!,
                                              memoryID: widget.memoryId!,
                                              comment: commentController.text.trim());
                                                                            commentController.text='';
                      
                                  }
                                    },
                            onChanged: (commentText) {
                              setState(() {
                                
                              });
                            },
                            style:
                                const TextStyle(fontSize: 16.0, color: Colors.black),
                          )),
                          if (commentController.text.trim().isNotEmpty)
                            IconButton(
                                onPressed: () {
                                  if (commentController.text.trim().isNotEmpty) {
                                    EasyLoading.show();
                                    ApiCall.addComment(
                                              api: ApiUrl.addComment,
                                              callack: this,
                                              imageId: widget.imageId!,
                                              memoryID: widget.memoryId!,
                                              comment: commentController.text.trim());
                                                                            commentController.text='';
                      
                                  }
                                },
                                icon: const Icon(Icons.arrow_circle_right_outlined,
                                    color: Colors.black))
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  @override
  void onFailure(String message) {
    // TODO: implement onFailure
  }

  @override
  void onSuccess(String data, String apiType) {
    print(data);
    EasyLoading.dismiss();
    if (apiType.contains(ApiUrl.getComments)) {
      commentModel = GetCommentsResponseModel.fromJson(json.decode(data));
      commentData=commentModel.data!.reversed.toList();
      print(commentData!.length);
       WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
    }else if(apiType==ApiUrl.addComment){
    ApiCall.getComments(api: ApiUrl.getComments+"?memory_id=${widget.memoryId}&image_id=${widget.imageId}", callack: this);

    }
    setState(() {
      
    });
  }

  @override
  void tokenExpired(String message) {
    // TODO: implement tokenExpired
  }
}
