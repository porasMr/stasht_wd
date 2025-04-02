class DrivePhotoModel {
  List<Files>? files;
  String? nextPageToken;

  DrivePhotoModel({this.files, this.nextPageToken});

  DrivePhotoModel.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files!.add(new Files.fromJson(v));
      });
    }
    nextPageToken = json['nextPageToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    data['nextPageToken'] = this.nextPageToken;
    return data;
  }
}

class Files {
  String? id;
  String? name;
  String? mimeType;
  String? webViewLink;
  String? thumbnailLink;
  String? createdTime;
  String? webContentLink;

  Files(
      {this.id,
      this.name,
      this.mimeType,
      this.webViewLink,
      this.thumbnailLink,this.createdTime,this.webContentLink});

  Files.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mimeType = json['mimeType'];
    webViewLink = json['webViewLink'];
    thumbnailLink = json['thumbnailLink'];
    createdTime=json['createdTime'];
    webContentLink=json['webContentLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mimeType'] = this.mimeType;
    data['webViewLink'] = this.webViewLink;
    data['thumbnailLink'] = this.thumbnailLink;
    data['createdTime']=this.createdTime;
    data['webContentLink']=this.webContentLink;
    return data;
  }
}