import 'package:Tshirt/config/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:Tshirt/view/ShirtView.dart";
import "package:Tshirt/view_model/ShirtViewModel.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegisterViewModel extends GetxController {
  Future<void> registerUser(String email, String username, String password) async {
    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      Get.snackbar("Input validation", "All fields must contain text", colorText: Colors.white, backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5), showProgressIndicator: true);
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 3), showProgressIndicator: true);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        Get.showSnackbar(
          const GetSnackBar(
            title: 'Registration Successful',
            message: 'Redirecting to Shirt page...',
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
            showProgressIndicator: true,
            progressIndicatorBackgroundColor: Colors.green,
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(Duration(seconds: 2), () {
          ShirtViewModel shirtViewModel = Get.put(ShirtViewModel(isAdmin: false));
          shirtViewModel.updateAdmin(false);
          Get.offAll(ShirtView(shirtViewModel: shirtViewModel));
        });
      } else if (response.statusCode == 400) {
      Get.snackbar("Information validation", response.body, colorText: Colors.white, backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM, 
        duration: null,
        mainButton: TextButton(
        onPressed: () {
        if (Get.isSnackbarOpen) {
          Get.back();
        }
        },
        child: const Text('Got it', style: TextStyle(color: Colors.white)),
      ),
  );
      } else {
        Get.snackbar("Registration error", "Registration has failed. Please try again later or contact out technical support. Status code: ${response.statusCode}", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
      }
    } catch (error) {
      Get.snackbar("Error", "Contact our technical support. An unexpected error occurred: $error", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
    }
  }
}