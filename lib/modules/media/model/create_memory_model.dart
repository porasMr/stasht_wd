class CreateMoemoryModel {
  String? title;
  String? memoryId;
  String? categoryId;
  String? subCategoryId;
  List<ImagesFile>? images;

  CreateMoemoryModel(
      {this.title, this.categoryId, this.subCategoryId, this.images});

  CreateMoemoryModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    if (json['images'] != null) {
      images = <ImagesFile>[];
      json['images'].forEach((v) {
        images!.add(new ImagesFile.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;

    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
   Map<String, dynamic> toWithMemoryIdJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
        data['memory_id'] = this.memoryId;

    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImagesFile {
  String? link;
  String? type;
  String? typeId;
  String? location;
  String? captureDate;
  String? description;

  ImagesFile(
      {this.link,
      this.type,
      this.typeId,
      this.location,
      this.captureDate,
      this.description});

  ImagesFile.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    type = json['type'];
    typeId = json['type_id'];
    location = json['location'];
    captureDate = json['capture_date'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link'] = this.link;
    data['type'] = this.type;
    data['type_id'] = this.typeId;
    data['location'] = this.location;
    data['capture_date'] = this.captureDate;
    data['description'] = this.description;
    return data;
  }
}