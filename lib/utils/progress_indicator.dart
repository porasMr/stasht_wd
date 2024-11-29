import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';

class CircularProgressController extends GetxController {
  var progress = 0.0.obs; // Observable variable for progress

  // void startProgress() async {
  //   // Simulate a task with progress updates
  //   for (double i = 0; i <= 1.0; i += 0.01) {
  //     await Future.delayed(Duration(milliseconds: 100)); // Simulate work
  //     progress.value = i; // Update progress
  //   }
  // }
  updateProgress(double newValue) async {
    double oldValue=progress.value;
    for (double i = oldValue; i <= newValue; i += 0.01) {
      await Future.delayed(const Duration(milliseconds: 30)); // Simulate work
      progress.value = i; // Update progress
    }
    update();

  }

}



// ignore: must_be_immutable
class CustomCircularProgressBar extends StatelessWidget {
  String textContent;
  CustomCircularProgressBar({super.key, required this.textContent});
  @override
  Widget build(BuildContext context) {
    final CircularProgressController controller = Get.find();

    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Background Circle
          CircularProgressIndicator(
            value: controller.progress.value,
            strokeWidth: 4, // Adjusted stroke width for a sleeker look
            backgroundColor: Colors.grey[300], // Background color
            color: AppColors.primaryColor, // Fill color
          ),
          SizedBox(height: 10,),
          Text(textContent,style: const TextStyle(color: Colors.white),)


        ],
      );
    });
  }
}
