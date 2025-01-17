class NotificationModel {
  int? status;
  String? message;
  List<Data>? data;

  NotificationModel({this.status, this.message, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  int? id;
  int? userId;
  int? senderId;
  int? read;
  String? type;
  String? description;
  String? createdAt;
  String? updatedAt;
  Sendby? sendby;
  String? memoryTitle;

  Data(
      {this.id,
      this.userId,
      this.senderId,
      this.read,
      this.type,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.sendby,this.memoryTitle});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    senderId = json['sender_id'];
    read = json['read'];
    type = json['type'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    memoryTitle=json['memory_title']??'';
    sendby =
        json['sendby'] != null ? new Sendby.fromJson(json['sendby']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['sender_id'] = this.senderId;
    data['read'] = this.read;
    data['type'] = this.type;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.sendby != null) {
      data['sendby'] = this.sendby!.toJson();
    }
    return data;
  }
}

class Sendby {
  int? id;
  String? role;
  String? name;
  String? email;

  int? status;
  String? profileImage;
  String? profileColor;
 

  Sendby(
      {this.id,
      this.role,
      this.name,
      this.email,
      
      this.status,
      this.profileImage,
      this.profileColor,
     });

  Sendby.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
   
    status = json['status'];
    profileImage = json['profile_image']??'';
    profileColor = json['profile_color']??'';
   
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
   
    data['status'] = this.status;
    data['profile_image'] = this.profileImage;
    data['profile_color'] = this.profileColor;
   
    return data;
  }
}