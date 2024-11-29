import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerWidget(double height, double width) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[100]!,
    highlightColor: Colors.grey[300]!,
    child: Container(
      height: height,
      width: width,
      color: Colors.grey[300],
    ),
  );
}
