
import 'package:stasht/modules/onboarding/domain/model/all_photo_model.dart';

class CombinedPhotoModel {
  final String createDate; // The date (key from the map)
   List<AllPhotoModel> photos; // List of PhotoDetailModel for that date

  CombinedPhotoModel({
    required this.createDate,
    required this.photos,

  });
}
