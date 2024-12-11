class AddCommentResponseModel {
  var status;
  var message;
  Data? data;

  AddCommentResponseModel({this.status, this.message, this.data});

  AddCommentResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
class Data {
  var userId;
  var memoryId;
  var imageId;
  var description;
  var commentId;
  var updatedAt;
  var createdAt;
  var id;

  Data(
      {this.userId,
        this.memoryId,
        this.imageId,
        this.description,
        this.commentId,
        this.updatedAt,
        this.createdAt,
        this.id});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    memoryId = json['memory_id'];
    imageId = json['image_id'];
    description = json['description'];
    commentId = json['comment_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['memory_id'] = this.memoryId;
    data['image_id'] = this.imageId;
    data['description'] = this.description;
    data['comment_id'] = this.commentId;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}


