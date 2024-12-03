class MemoriesModel {
  int? status;
  String? message;
  List<Data>? data;
  List<Data>? shared;
  List<Data>? published;

  MemoriesModel(
      {this.status, this.message, this.data, this.shared, this.published});

  MemoriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    if (json['shared'] != null) {
      shared = <Data>[];
      json['shared'].forEach((v) {
        shared!.add( Data.fromJson(v));
      });
    }
    if (json['published'] != null) {
      published = <Data>[];
      json['published'].forEach((v) {
        published!.add( Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.shared != null) {
      data['shared'] = this.shared!.map((v) => v.toJson()).toList();
    }
    if (this.published != null) {
      data['published'] = this.published!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  int? userId;
  int? isDefualt;
  int? orderNo;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  int? memorisCount;
    List<Memoris>? memoris;


  Data(
      {this.id,
      this.name,
      this.userId,
      this.isDefualt,
      this.orderNo,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.memorisCount,
      this.memoris
      });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    userId = json['user_id'];
    isDefualt = json['is_defualt'];
    orderNo = json['order_no']??0;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at']??'';
    memorisCount = json['memoris_count'];
     if (json['memoris'] != null) {
      memoris = <Memoris>[];
      json['memoris'].forEach((v) {
        memoris!.add( Memoris.fromJson(v));
      });
    }
   
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['user_id'] = this.userId;
    data['is_defualt'] = this.isDefualt;
    data['order_no'] = this.orderNo;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['memoris_count'] = this.memorisCount;
     if (this.memoris != null) {
      data['memoris'] = this.memoris!.map((v) => v.toJson()).toList();
    }
    
    return data;
  }
}

class Memoris {
  int? id;
  int? categoryId;
  int? userId;
  String? title;
  String? subCategoryId;
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
  int? postsCount;
    SubCategory? subCategory;

  User? user;

  Memoris(
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
      this.deletedAt,
      this.postsCount,
      this.subCategory,
      this.user});

  Memoris.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    title = json['title'];
    if(json['sub_category_id']==null){
      subCategoryId='';
    }else{
subCategoryId = json['sub_category_id'].toString();
    }
    slug = json['slug'];
    published = json['published'];
    commentsCount = json['comments_count'];
    inviteLink = json['invite_link'];
    minUploadedImgDate = json['min_uploaded_img_date'];
    maxUploadedImgDate = json['max_uploaded_img_date'];
    lastUpdateImg = json['last_update_img']??'';
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at']??'';
    postsCount = json['posts_count'];
subCategory = json['sub_category'] != null
        ?  SubCategory.fromJson(json['sub_category'])
        : null;    user = json['user'] != null ?  User.fromJson(json['user']) : null;
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
    data['posts_count'] = this.postsCount;
    if (this.subCategory != null) {
      data['sub_category'] = this.subCategory!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  dynamic profileImage;

  User({this.id, this.name, this.profileImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profileImage = json['profile_image']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile_image'] = this.profileImage;
    return data;
  }
}
class SubCategory {
  int? id;
  String? name;
  int? userId;
  int? categoryId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  SubCategory(
      {this.id,
      this.name,
      this.userId,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}