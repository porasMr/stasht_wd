class SubCategorymodel {
  int? status;
  String? message;
  List<SubCategories>? subCategories;

  SubCategorymodel({this.status, this.message, this.subCategories});

  SubCategorymodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (this.subCategories != null) {
      data['subCategories'] =
          this.subCategories!.map((v) => v.toJson()).toList();
    }
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
  String? deletedAt;

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
    name = json['name']??'';
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