class CollaboratorList {
  int? status;
  String? message;
  List<Data>? data;

  CollaboratorList({this.status, this.message, this.data});

  CollaboratorList.fromJson(Map<String, dynamic> json) {
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
  int? memoryId;
  int? userId;
  int? status;
  String? createdAt;
  String? updatedAt;
  User? user;

  Data(
      {this.id,
      this.memoryId,
      this.userId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.user});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    memoryId = json['memory_id'];
    userId = json['user_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ?  User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = this.id;
    data['memory_id'] = this.memoryId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
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
 
  String? profileImage;
  String? profileColor;
  

  User(
      {this.id,
      this.role,
      this.name,
      this.email,
     
      this.profileImage,
      this.profileColor,
     });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
   
    profileImage = json['profile_image']??'';
    profileColor = json['profile_color']??'';
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
   
    data['profile_image'] = this.profileImage;
    data['profile_color'] = this.profileColor;
    
    return data;
  }
}