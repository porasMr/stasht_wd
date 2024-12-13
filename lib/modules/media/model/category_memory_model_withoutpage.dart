class CategoryMemoryModelWithoutPage {
  int? status;
  String? message;
  List<Data>? data;
  List<SubCategories>? subCategories;

  CategoryMemoryModelWithoutPage(
      {this.status, this.message, this.data, this.subCategories});

  CategoryMemoryModelWithoutPage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    if (json['subCategories'] != null) {
      subCategories = <SubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(new SubCategories.fromJson(v));
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
    if (this.subCategories != null) {
      data['subCategories'] =
          this.subCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
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
  int? collaboratorCount;
  User? user;
  dynamic signleCooaborator;

  Data(
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
      this.collaboratorCount,
      this.user,
      this.signleCooaborator});

  Data.fromJson(Map<String, dynamic> json) {
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
    lastUpdateImg = json['last_update_img'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    postsCount = json['posts_count'];
    collaboratorCount = json['collaborator_count'];
   
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    signleCooaborator = json['signle_cooaborator'];
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
    data['collaborator_count'] = this.collaboratorCount;
    
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['signle_cooaborator'] = this.signleCooaborator;
    return data;
  }
}


class SubCategories {
  int? id;
  String? name;
  int? userId;
  int? categoryId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  bool isselected=false;

  SubCategories(
      {this.id,
      this.name,
      this.userId,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  SubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
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
class User {
  int? id;
  String? name;
  String? profileImage;
  String? email;

  User({this.id, this.name, this.profileImage, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profileImage = json['profile_image']??'';
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile_image'] = this.profileImage;
    data['email'] = this.email;
    return data;
  }
}
