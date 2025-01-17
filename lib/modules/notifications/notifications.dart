import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/memory_details/memory_lane.dart';
import 'package:stasht/modules/memory_details/model/memory_detail_model.dart';
import 'package:stasht/modules/notifications/model/notification_model.dart';
import 'package:stasht/network/api_call.dart';
import 'package:stasht/network/api_callback.dart';
import 'package:stasht/network/api_url.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';

class NotificationScreen extends StatefulWidget{
  NotificationScreen({required this.photosList,required this.future});
    List<PhotoModel> photosList = [];
      List<Future<Uint8List?>> future = [];


  @override
  State<StatefulWidget> createState() {
  return NotificationState();
  }

}
class NotificationState extends State<NotificationScreen> implements ApiCallback{
  NotificationModel notificationModel=NotificationModel();
  String memoryId="";
  @override
  void initState() {
    EasyLoading.show();
    ApiCall.getNotifications(api: ApiUrl.notifications, callack: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
            appBar:AppBar(
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: 
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:const Icon(Icons.arrow_back),
                  ),
                 const SizedBox(width: 10,),
                 const Text("Notifications",
                    style: TextStyle(
                      fontSize: 22,
                      height: 28/22,
                      fontFamily: robotoRegular,
                    
                    ),),
                ],
              )
             
    
           
            ),
            body:   notificationModel.data!=null
                ?
            ListView.builder(
              itemCount: notificationModel.data!.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                        onTap: () {
                          memoryId=notificationModel.data![index].type!;
                          notificationModel.data![index].read=1;
                          setState(() {
                            
                          });
                         EasyLoading.show();
                         ApiCall.getNotifications(api: ApiUrl.readNotification+"?notification_id=${notificationModel.data![index].id}", callack: this);
                        },
                        child: Container(

                          decoration: BoxDecoration(
                              color:notificationModel.data![index].read==0?AppColors.textfieldFillColor:
                              Colors.white
                              ,
                             border: Border(
                               top: BorderSide(
                                 color: Color(0XFFD9DAFF).withOpacity(.75)
                               ),
                               bottom: BorderSide(
                                   color: Color(0XFFD9DAFF).withOpacity(.75)
                               ),
                             )
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(CommonWidgets.formatTimeAgo(DateTime.parse(notificationModel.data!
                                   [index].createdAt!) ),
                                style: TextStyle(
                                  color:Color(0XFF858484),
                                  fontSize: 13,
                                  height: 19.2/13
                                ),),
                              ),
                              Row(
                                children: [
                                  Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color:notificationModel.data![index].sendby==null?AppColors.unreadColor:  convertColor(color: notificationModel.data![index].sendby!.profileColor) ,
                      border: Border.all(color: Colors.grey, width: 0.3)),
                  height: 46,
                  width: 46,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child:notificationModel.data![index].sendby==null?
                     Text(
                            notificationModel.data![index].description![0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: robotoRegular),
                          ):
                    
                    notificationModel.data![index].sendby!.profileImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: notificationModel.data![index].sendby!.profileImage!,
                            fit: BoxFit.cover,
                            height: 46,
                            width: 46,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress))
                        : Text(
                            notificationModel.data![index].sendby!.name![0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: robotoRegular),
                          ),
                  ),
                ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  notificationModel.data![index].sendby==null?
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: notificationModel.data!
                                   [index].description,
                                        style: const TextStyle(
                                            fontFamily: interBold,
                                            color: AppColors.black,
                                            fontSize: 13,
                                            height: 19.2/13),
                                        children: <TextSpan>[
                                        ],
                                      ),
                                    ),
                                  ):
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: notificationModel.data![index].sendby!.name,
                                        style: const TextStyle(
                                                   fontFamily:robotoBold ,                                         fontWeight: FontWeight.bold,

                                            color: AppColors.black,
                                          
                                            fontSize: 14,
                                            height: 19.2/13),
                                        children: <TextSpan>[
                                         const TextSpan(
                                        text: " has accept your Invitation for memory\n",
                                        style:  TextStyle(
                                            color: AppColors.black,
                                            fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                   fontFamily:robotoRegular ,   

                                            ),
                                          ),
                                           TextSpan(
                                        text:notificationModel.data![index].memoryTitle==""?"": notificationModel.data![index].memoryTitle,
                                        style: const TextStyle(
                                                   fontFamily:robotoBold ,                                         fontWeight: FontWeight.bold,

                                            color: AppColors.black,
                                            fontSize: 14,
                                            height: 19.2/13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )),
                 /*   Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      color: AppColors.primaryColor,
                    )*/
                  ],
                );
              },
            ):
               Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'You have no notifications at this time.',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: robotoMedium),
                        ),
                      ));
  }
  
  @override
  void onFailure(String message) {
    EasyLoading.dismiss();
  }
  
  @override
  void onSuccess(String data, String apiType) {
    if(apiType==ApiUrl.notifications){
          EasyLoading.dismiss();

      notificationModel=NotificationModel.fromJson(json.decode(data));
      setState(() {
        
      });
    }else if(apiType.contains(ApiUrl.readNotification)){
      ApiCall.memoryDetails(api: ApiUrl.memoryDetail, id: memoryId, page: "page", callack: this);
    }
    else{
          EasyLoading.dismiss();

       MemoryDetailsModel details=MemoryDetailsModel.fromJson(json.decode(data));
    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MemoryDetailPage(
                                              memoryTtile: details.data![0].memory!.title!,
                                              memoryId: details.data![0].memory!.id.toString(),
                                              userName: details.data![0].user!.name!,
                                              sharedCount: "0",
                                              email: details.data![0].user!.id.toString(),
                                              imageLink: details.data![0].memory!.lastUpdateImg!,
                                              imageCaptions:
                                                  details.data![0].user!.profileImage,
                                              pubLished:
                                                  details.data![0].memory!.published.toString(),
                                              future: widget.future,
                                              photosList: widget.photosList,
                                              subId: details.data![0].memory!.subCategoryId.toString(),
                                              catId:
                                                  details.data![0].memory!.categoryId.toString(),
                                              selectionType:
                                                  "Personal",
                                            ))).then((value) {
                              
                                });
    }
  }
  
  @override
  void tokenExpired(String message) {
    // TODO: implement tokenExpired
  }

}