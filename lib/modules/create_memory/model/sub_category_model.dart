class SubCategoryResModel {
  int? status;
  String? message;
  Categories? categories;

  SubCategoryResModel({this.status, this.message, this.categories});

  SubCategoryResModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    categories = json['categories'] != null
        ? new Categories.fromJson(json['categories'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.categories != null) {
      data['categories'] = this.categories!.toJson();
    }
    return data;
  }
}

class Categories {
  int? userId;
  String? name;
  String? categoryId;
  String? updatedAt;
  String? createdAt;
  int? id;

  Categories(
      {this.userId,
      this.name,
      this.categoryId,
      this.updatedAt,
      this.createdAt,
      this.id});

  Categories.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    categoryId = json['category_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['category_id'] = this.categoryId;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}