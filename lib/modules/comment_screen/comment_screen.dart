import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stasht/modules/memory_details/model/get_comments_response_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    EasyLoading.show();
    ApiCall.getComments(api: ApiUrl.getComments+"?memory_id=${widget.memoryId}&image_id=${widget.imageId}", callack: this);
  }

  @override
  Widget build(BuildContext context) {
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
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.49)),
            child: Column(
              children: [
                Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: commentModel.data!=null?
                      Container(
                        height: MediaQuery.of(context).size.height/2,
                        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
                          child: ListView.builder(
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
                                          height: 35,
                                          width: 35,
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
                                                    height: 30,
                                                    width: 30,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    height: 43,
                                                    width: 43,
                                                    alignment: Alignment.center,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.primaryColor,
                                                    ),
                                                    child: Text(
                                                     commentData![index].user!.name.toString()[0].toUpperCase(),
                                                      style: const TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.white,
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
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                commentData![index].user!.name!,
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.white,
                                                    fontFamily: robotoBold),
                                              ),
                                              Text(
                                                commentData![index].description!,
                                                style: const TextStyle(
                                                    fontSize: 13.0,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        )),
                                        Container(
                                          child: Text(
                                            CommonWidgets.dateFormatRetrun(commentData![index].createdAt!),
                                            style: const TextStyle(
                                                fontSize: 11.0,
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 0.7,
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(vertical: 7),
                                  )
                                ],
                              );
                            },
                            itemCount: commentData!.length,
                            shrinkWrap: true,
                            
                          ),
                        ),
                      ):Container()),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black,
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
                              TextStyle(fontSize: 16.0, color: Colors.white)),
                      onChanged: (commentText) {
                        setState(() {
                          
                        });
                      },
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.white),
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
                              color: Colors.white))
                  ]),
                ),
              ],
            ),
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
