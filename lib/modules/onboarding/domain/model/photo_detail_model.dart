import 'dart:convert'; // Import this for base64Encode and base64Decode
import 'dart:io';
import 'dart:typed_data';

class PhotoDetailModel {
  dynamic id;
  String? webLink;
  DateTime? createdTime;
  DateTime? modifiedTime;
  bool isSelected;
  bool isEdit;
  Uint8List? thumbdata;
  Uint8List? originalThumbdata;
  File? file;
  String? type;
  String? location;
  String? thumbnailPath;

  PhotoDetailModel({
    this.webLink,
    this.createdTime,
    this.modifiedTime,
    this.isSelected = false,
    this.isEdit = false,
    this.thumbdata,
    this.id,
    this.file,
    this.type,
    this.location,
    this.originalThumbdata,
    this.thumbnailPath,
  });

  // Convert a PhotoDetail object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "location":location,
      'webLink': webLink,
      'isEdit': isEdit,
      'createdTime': createdTime?.toIso8601String(),
      'modifiedTime': modifiedTime?.toIso8601String(),
      'isSelected': isSelected,
      'thumbdata': thumbdata != null ? base64Encode(thumbdata!) : null,
      'originalThumbdata': originalThumbdata != null ? base64Encode(originalThumbdata!) : null,
      'file': file?.path, // Store the file path, not the file itself
      'type': type,
      'thumbnailPath': thumbnailPath,
    };
  }

  // Create a PhotoDetail object from a JSON map
  factory PhotoDetailModel.fromJson(Map<String, dynamic> json) {
    return PhotoDetailModel(
      id: json['id'],
      location: json['location'],
      isEdit: json['isEdit'],
      webLink: json['webLink'],
      createdTime: json['createdTime'] != null ? DateTime.parse(json['createdTime']) : null,
      modifiedTime: json['modifiedTime'] != null ? DateTime.parse(json['modifiedTime']) : null,
      isSelected: json['isSelected'] ?? false,
      thumbdata: json['thumbdata'] != null ? base64Decode(json['thumbdata']) : null,
      originalThumbdata: json['originalThumbdata'] != null ? base64Decode(json['originalThumbdata']) : null,
      file: json['file'] != null ? File(json['file']) : null, // Convert file path back to File object
      type: json['type'],
      thumbnailPath: json['thumbnailPath'],
    );
  }
}
