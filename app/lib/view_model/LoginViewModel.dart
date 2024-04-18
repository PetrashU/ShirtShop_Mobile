import 'package:Tshirt/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Tshirt/view/ShirtView.dart';
import 'package:Tshirt/view_model/ShirtViewModel.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginViewModel extends GetxController {
  Future<Tuple2<bool, bool>> authenticate(String username, String password) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 3), showProgressIndicator: true);
        return const Tuple2(false, false);
      }

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool isAdmin = data['isAdmin'];
        return Tuple2(true, isAdmin);
      } else if (response.statusCode == 400) {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Invalid username or password',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
          },
        );
        return const Tuple2(false, false);
      } else {
        Get.snackbar("Error login", "Error logging in. Please try again later or contact technical support. Status code: ${response.statusCode}", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
        return const Tuple2(false, false);
      }
    } catch (error) {
      Get.snackbar("Error login", "Error logging in. Please try again later or contact technical support: $error", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
      return const Tuple2(false, false);
    }
  }

  loginWithGoogle() async {
    try {
      Get.dialog(
        Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Get.back();
        return;
      }

      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      Get.back();

      if (userCredential.user != null) {
        ShirtViewModel shirtViewModel = Get.put(ShirtViewModel(isAdmin: false));
        shirtViewModel.updateAdmin(false);
        Get.offAll(ShirtView(shirtViewModel: shirtViewModel));
      }
    } catch (error) {
      Get.back();
      Get.snackbar(
        "Sign-in Error",
        "An error occurred during sign-in: $error",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }
}