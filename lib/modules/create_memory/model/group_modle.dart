import 'package:stasht/modules/onboarding/domain/model/photo_detail_model.dart';

class GroupedPhotoModel {
  final String date; // The date (key from the map)
  final List<PhotoDetailModel> photos; // List of PhotoDetailModel for that date

  GroupedPhotoModel({
    required this.date,
    required this.photos,
  });
}
