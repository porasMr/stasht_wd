import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:stasht/utils/app_colors.dart';

class ProgressDialog extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;

  ProgressDialog(this.progressNotifier);

  

  @override
  Widget build(BuildContext context) {
    return 
    AlertDialog(
      shadowColor:Colors.transparent ,
      

        backgroundColor: Colors.transparent,elevation: 0, insetPadding: EdgeInsets.zero,
        content:ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (context, progress, child) {
          return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: progressNotifier.value, // Reactive value
              backgroundColor: AppColors.textfieldFillColor,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '${(progressNotifier.value * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: AppColors.primaryColor),
            ),
          ],
        );
        })
        
        
        );
  }
}