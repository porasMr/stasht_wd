class CategoryMemoryModel {
  int? status;
  String? message;
  Data? data;
  List<SubCategories>? subCategories;

  CategoryMemoryModel(
      {this.status, this.message, this.data, this.subCategories});

  CategoryMemoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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
      data['data'] = this.data!.toJson();
    }
    if (this.subCategories != null) {
      data['subCategories'] =
          this.subCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? currentPage;
  List<MemoryData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  dynamic lastPageUrl;
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
      data = <MemoryData>[];
      json['data'].forEach((v) {
        data!.add( MemoryData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    
      lastPageUrl = json['last_page_url']??'';
    
    
    
      nextPageUrl = json['next_page_url']??"";
    
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

class MemoryData {
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
  SubCategory? subCategory;
  User? user;
  dynamic signleCooaborator;

  MemoryData(
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
      this.subCategory,
      this.user,
      this.signleCooaborator});

  MemoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    title = json['title'];
    if (json['sub_category_id'] == null) {
      subCategoryId = '';
    } else {
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
    deletedAt = json['deleted_at'];
    postsCount = json['posts_count']??0;
    collaboratorCount = json['collaborator_count'];
    subCategory = json['sub_category'] != null
        ?  SubCategory.fromJson(json['sub_category'])
        : null;
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
    if (this.subCategory != null) {
      data['sub_category'] = this.subCategory!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['signle_cooaborator'] = this.signleCooaborator;
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
  dynamic deletedAt;

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
  dynamic profileImage;
  String? email;

  User({this.id, this.name, this.profileImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profileImage = json['profile_image'] ?? '';
    email=json['email']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile_image'] = this.profileImage;
    data['email']=this.email;
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

class SubCategories {
  int? id;
  String? name;
  int? userId;
  int? categoryId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  bool isSelected = false;

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
