class UserModel {
  String? message;
  String? token;
  User? user;
  int? hasMemory;

  UserModel({this.message, this.token, this.user});

  UserModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    token = json['token'];
    hasMemory=json['has_memroy']??0;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? userName;
  int? status;
  String? profileImage;
  String? profileColor;
  int? notificationsCount;
  int? instagramSynced;
  int? facebookSynced;
  int? googleDriveSynced;
  String? deviceType;
  String? deviceToken;
  String? appVersion;
  String? googleId;
  String? appleId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

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
    emailVerifiedAt = json['email_verified_at']??'';
    userName = json['user_name']??'';
    status = json['status'];
    profileImage = json['profile_image']??'';
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
    createdAt = json['created_at']??'';
    updatedAt = json['updated_at']??'';
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