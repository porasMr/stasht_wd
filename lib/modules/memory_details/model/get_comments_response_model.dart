class GetCommentsResponseModel {
  int? status;
  String? message;
  List<CommentData>? data;

  GetCommentsResponseModel({this.status, this.message, this.data});

  GetCommentsResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CommentData>[];
      json['data'].forEach((v) {
        data!.add(new CommentData.fromJson(v));
      });
    }
  }

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

class CommentData {
  int? id;
  int? userId;
  dynamic commentId;
  int? memoryId;
  int? imageId;
  String? description;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  User? user;

  CommentData(
      {this.id,
      this.userId,
      this.commentId,
      this.memoryId,
      this.imageId,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.user});

  CommentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    commentId = json['comment_id'];
    memoryId = json['memory_id'];
    imageId = json['image_id'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['comment_id'] = this.commentId;
    data['memory_id'] = this.memoryId;
    data['image_id'] = this.imageId;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? role;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  dynamic userName;
  int? status;
  String? profileImage;
  dynamic profileColor;
  int? notificationsCount;
  dynamic instagramSynced;
  dynamic facebookSynced;
  dynamic googleDriveSynced;
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
      this.role,
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
    role = json['role'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    userName = json['user_name'];
    status = json['status'];
    profileImage = json['profile_image']??'';
    profileColor = json['profile_color'];
    notificationsCount = json['notifications_count'];
    instagramSynced = json['instagram_synced'];
    facebookSynced = json['facebook_synced'];
    googleDriveSynced = json['google_drive_synced'];
    deviceType = json['device_type'];
    deviceToken = json['device_token'];
    appVersion = json['app_version'];
    googleId = json['google_id'];
    appleId = json['apple_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
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