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
    
    return data;
  }
}