import 'dart:typed_data';

import 'package:stasht/modules/media/model/phot_mdoel.dart';

class PhotoGroupModel {
  final String date; // The date (key from the map)
   List<PhotoModel> photos; // List of PhotoDetailModel for that date
  List<Future<Uint8List?>> future = [];

  PhotoGroupModel({
    required this.date,
    required this.photos,

    required this.future
  });
}
