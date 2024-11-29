// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class NetworkController extends GetxController {
//   // Store a single ConnectivityResult instead of a list
//   List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

//   @override
//   void onInit() {
//     checkInterNetConnection();
//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//     super.onInit();
//   }

//   void checkInterNetConnection() async {
//     final result = await _connectivity.checkConnectivity();
//     _updateConnectionStatus(result);
//   }

//   void _updateConnectionStatus(List<ConnectivityResult> result) {
//     _connectionStatus = result;
//     print('Connectivity changed: $_connectionStatus');

//     // Display snackbar based on connection status
//     if (result == ConnectivityResult.none) {
//       Get.rawSnackbar(
//         title: "No Internet Connection",
//         message: "Please check your connection",
//         backgroundColor: Colors.red,
//         icon: Icon(Icons.wifi, color: Colors.white),
//       );
//     } else {
//       // Close any open snackbars if connection is restored
//       if (Get.isSnackbarOpen) {
//         Get.closeAllSnackbars();
//       }
//     }
//   }

//   @override
//   void onClose() {
//     _connectivitySubscription.cancel();
//     super.onClose();
//   }
// }
