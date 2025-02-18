import 'dart:convert'; // Import this for base64Encode and base64Decode
import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class AllPhotoModel {
  dynamic id;
  String? webLink;
    String? drivethumbNail;

  
  bool isSelected;
  bool isEdit;
    bool isFirst;

 
  String? type;
    AssetEntity? assetEntity;
    Future<Uint8List?>? thumbData;
    DateTime? createdDate;

 


  AllPhotoModel({
    this.webLink,
   
    this.isSelected = false,
    this.isEdit = false,
    this.isFirst=true,
    this.id,
    this.type,
    this.assetEntity,
     this.thumbData,this.drivethumbNail,this.createdDate

  
  });

  // Convert a PhotoDetail object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webLink': webLink,
      'isEdit': isEdit,
     
      'isSelected': isSelected,
     
      'type': type,
      "assetEntity":assetEntity,
      "thumbData":thumbData,
      "drivethumbNail":drivethumbNail,
      "createdDate":createdDate
      
    };
  }

  // Create a PhotoDetail object from a JSON map
  factory AllPhotoModel.fromJson(Map<String, dynamic> json) {
    return AllPhotoModel(
      id: json['id'],
      isEdit: json['isEdit'],
      webLink: json['webLink'],
      isSelected: json['isSelected'] ?? false,
      type: json['type'],
      assetEntity:json['assetEntity'],
      thumbData:json['thumbData'],
      drivethumbNail:json['drivethumbNail'],
      createdDate:json['createdDate']
    );
  }
}
