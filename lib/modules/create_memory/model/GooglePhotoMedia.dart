class GooglePhotoMedia {
  List<MediaItems>? mediaItems;
  String? nextPageToken;

  GooglePhotoMedia({this.mediaItems,this.nextPageToken});

  GooglePhotoMedia.fromJson(Map<String, dynamic> json) {
    if (json['mediaItems'] != null) {
      mediaItems = <MediaItems>[];
      json['mediaItems'].forEach((v) {
        mediaItems!.add(new MediaItems.fromJson(v));
      });
    }
    if(json['nextPageToken']==null){
        nextPageToken = "";

    }else{
        nextPageToken = json['nextPageToken'];

    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mediaItems != null) {
      data['mediaItems'] = this.mediaItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaItems {
  String? id;
  String? productUrl;
  String? baseUrl;
  String? mimeType;
  String? filename;
  int? height;
  int? width;
  String? nextPageToken;
 MediaMetadata? mediaMetadata;

  MediaItems(
      {this.id,
      this.productUrl,
      this.baseUrl,
      this.mimeType,
      this.filename,
      this.height,
      this.width,
      this.nextPageToken,this.mediaMetadata
      });

  MediaItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productUrl = json['productUrl'];
    baseUrl = json['baseUrl'];
    mimeType = json['mimeType'];
    filename = json['filename'];
    height = json['height'];
    width = json['width'];
    nextPageToken=json['nextPageToken'];
    mediaMetadata = json['mediaMetadata'] != null
        ? new MediaMetadata.fromJson(json['mediaMetadata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productUrl'] = this.productUrl;
    data['baseUrl'] = this.baseUrl;
    data['mimeType'] = this.mimeType;
    data['filename'] = this.filename;
    data['height'] = this.height;
    data['width'] = this.width;
    if (this.mediaMetadata != null) {
      data['mediaMetadata'] = this.mediaMetadata!.toJson();
    }
    return data;
  }
}

class MediaMetadata {
  String? creationTime;
  

  MediaMetadata({this.creationTime});

  MediaMetadata.fromJson(Map<String, dynamic> json) {
    creationTime = json['creationTime'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['creationTime'] = this.creationTime;

    return data;
  }
}
