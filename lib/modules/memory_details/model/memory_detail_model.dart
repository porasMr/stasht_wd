class MemoryDetailsModel {
  int? status;
  String? message;
  List<MemoryListData>? data;

  MemoryDetailsModel({this.status, this.message, this.data});

  MemoryDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
 if (json['data'] != null) {
      data = <MemoryListData>[];
      json['data'].forEach((v) {
        data!.add( MemoryListData.fromJson(v));
      });
    }  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
     if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? currentPage;
  List<MemoryListData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data(
      {this.currentPage,
      this.data,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <MemoryListData>[];
      json['data'].forEach((v) {
        data!.add( MemoryListData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    
    nextPageUrl = json['next_page_url']??'';
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class MemoryListData {
  int? id;
  int? memoryId;
  String? imageLink;
  String? type;
  String? typeId;
  dynamic location;
  int? userId;
  String? captureDate;
  String? description;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  int? commentsCount;
  Memory? memory;
  User? user;

  MemoryListData(
      {this.id,
      this.memoryId,
      this.imageLink,
      this.type,
      this.typeId,
      this.location,
      this.userId,
      this.captureDate,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.commentsCount,
      this.memory,
      this.user});

  MemoryListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    memoryId = json['memory_id'];
    imageLink = json['image_link'];
    type = json['type'];
    typeId = json['type_id'];
    if(json['location']==null){
location="";
    }else{
    location = json['location'];

    }
    userId = json['user_id'];
    captureDate = json['capture_date'];
    if(json['description']==null){
description='';
    }else{
    description = json['description'];

    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    commentsCount = json['comments_count'];
    memory =
        json['memory'] != null ? new Memory.fromJson(json['memory']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['memory_id'] = this.memoryId;
    data['image_link'] = this.imageLink;
    data['type'] = this.type;
    data['type_id'] = this.typeId;
    data['location'] = this.location;
    data['user_id'] = this.userId;
    data['capture_date'] = this.captureDate;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['comments_count'] = this.commentsCount;
    if (this.memory != null) {
      data['memory'] = this.memory!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class Memory {
  int? id;
  int? categoryId;
  int? userId;
  String? title;
  int? subCategoryId;
  String? slug;
  dynamic published;
  int? commentsCount;
  dynamic inviteLink;
  String? minUploadedImgDate;
  String? maxUploadedImgDate;
  String? lastUpdateImg;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  Memory(
      {this.id,
      this.categoryId,
      this.userId,
      this.title,
      this.subCategoryId,
      this.slug,
      this.published,
      this.commentsCount,
      this.inviteLink,
      this.minUploadedImgDate,
      this.maxUploadedImgDate,
      this.lastUpdateImg,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Memory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    title = json['title'];
    subCategoryId = json['sub_category_id'];
    slug = json['slug'];
    published = json['published']??'';
    commentsCount = json['comments_count'];
    inviteLink = json['invite_link']??'';
    minUploadedImgDate = json['min_uploaded_img_date'];
    maxUploadedImgDate = json['max_uploaded_img_date'];
    lastUpdateImg = json['last_update_img'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['sub_category_id'] = this.subCategoryId;
    data['slug'] = this.slug;
    data['published'] = this.published;
    data['comments_count'] = this.commentsCount;
    data['invite_link'] = this.inviteLink;
    data['min_uploaded_img_date'] = this.minUploadedImgDate;
    data['max_uploaded_img_date'] = this.maxUploadedImgDate;
    data['last_update_img'] = this.lastUpdateImg;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  dynamic userName;
  int? status;
  dynamic profileImage;
  String? profileColor;
  int? notificationsCount;
  dynamic instagramSynced;
  int? facebookSynced;
  int? googleDriveSynced;
  dynamic deviceType;
  dynamic deviceToken;
  dynamic appVersion;
  String? googleId;
  dynamic appleId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  User(
      {this.id,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.userName,
      this.status,
      this.profileImage,
      this.profileColor,
      this.notificationsCount,
      this.instagramSynced,
      this.facebookSynced,
      this.googleDriveSynced,
      this.deviceType,
      this.deviceToken,
      this.appVersion,
      this.googleId,
      this.appleId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    userName = json['user_name'];
    status = json['status'];
    profileImage = json['profile_image']??"";
    profileColor = json['profile_color']??'';
    notificationsCount = json['notifications_count'];
    instagramSynced = json['instagram_synced']??0;
    facebookSynced = json['facebook_synced']??0;
    googleDriveSynced = json['google_drive_synced']??0;
    deviceType = json['device_type']??'';
    deviceToken = json['device_token']??'';
    appVersion = json['app_version']??'';
    googleId = json['google_id']??'';
    appleId = json['apple_id']??'';
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['user_name'] = this.userName;
    data['status'] = this.status;
    data['profile_image'] = this.profileImage;
    data['profile_color'] = this.profileColor;
    data['notifications_count'] = this.notificationsCount;
    data['instagram_synced'] = this.instagramSynced;
    data['facebook_synced'] = this.facebookSynced;
    data['google_drive_synced'] = this.googleDriveSynced;
    data['device_type'] = this.deviceType;
    data['device_token'] = this.deviceToken;
    data['app_version'] = this.appVersion;
    data['google_id'] = this.googleId;
    data['apple_id'] = this.appleId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}