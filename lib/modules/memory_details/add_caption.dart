import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';

import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
class AddCaption extends StatefulWidget {
  AddCaption(
      {super.key,
      required this.memoriesModel,
      required this.id,
      });
      final String id;
 final MemoryListData memoriesModel;

  @override
  State<AddCaption> createState() => _AddCaptionState();
}

class _AddCaptionState extends State<AddCaption> implements ApiCallback{

  TextEditingController captionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
  
    captionController.text =
        widget.memoriesModel.description!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
Navigator.pop(context);
        },
            icon: const Icon(
              Icons.close,
              color: AppColors.darkColor,
            )),
        elevation: 0,
        actions: [
          InkWell(
            onTap: () {
            if(captionController.text.isNotEmpty)  {
               EasyLoading.show();
               ApiCall.saveFileDescription(api: ApiUrl.saveFileDescription, fileId: widget.memoriesModel.id.toString(), id: widget.id, description: captionController.text, callack: this);
              }
            else{
              CommonWidgets.errorDialog(context, "Please enter the caption");
              
            }
            },
            child: const Row(
              children: [
                Text(
                  'Done',
                  style: TextStyle(
                      fontFamily: robotoBold,
                      fontSize: 16,
                      color: AppColors.darkColor),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.darkColor,
                  size: 15,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 0.5,
            color: AppColors.primaryColor,
          ),
          TextFormField(
            controller: captionController,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            maxLength: 350,
            decoration: const InputDecoration(
                counterText: '',
                hintText: 'Add Caption to this post..',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textColor),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0)),
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          Expanded(
            child: CachedNetworkImage(
                progressIndicatorBuilder: (context, url, progress) => Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    ),
                fit: BoxFit.cover,
                imageUrl: widget.memoriesModel.imageLink!),
          )
        ],
      ),
    );
  }
  
  @override
  void onFailure(String message) {
        EasyLoading.dismiss();

CommonWidgets.errorDialog(context, message);
  }
  
  @override
  void onSuccess(String data, String apiType) {
    print(data);
    EasyLoading.dismiss();
    Navigator.pop(context,captionController.text);
  }
  
  @override
  void tokenExpired(String message) {
  }
}
