class FaceBookPhoto {
  final String id;
  String? createdTime;

  FaceBookPhoto({
    required this.id,
    this.createdTime,
  });

  // Factory constructor to create an instance from JSON
  factory FaceBookPhoto.fromJson(Map<String, dynamic> json) {
    return FaceBookPhoto(
      id: json['id'],
      createdTime: json['created_time'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_time': createdTime,
    };
  }
}