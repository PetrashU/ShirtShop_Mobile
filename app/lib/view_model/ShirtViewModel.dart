import 'dart:io';
import 'package:Tshirt/config/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Tshirt/model/ShirtModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Tshirt/view/ShirtView.dart';
import 'package:connectivity_plus/connectivity_plus.dart';



class ShirtViewModel extends GetxController{
  var isLoading = false.obs;
  var allShirts = <ShirtModel>[].obs;
  bool isAdmin;
  final String apiUrl = Config.apiBaseUrl;

  ShirtViewModel({required this.isAdmin});

  void updateAdmin(bool IsAdmin) {
    isAdmin = IsAdmin;
    update();
  }
  
  void initialize(bool IsAdmin) {
    isAdmin = IsAdmin;
    fetchAllShirts();
  }

  @override
  void onInit() {
    super.onInit();
    initialize(isAdmin);
  }

  Future<void> fetchAllShirts() async {
    isLoading.value = true;
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw SocketException("No internet connection available");
      }

      final response = await http.get(Uri.parse('${apiUrl}shirts'));

      if (response.statusCode == 200) {
        List<dynamic> shirtsFromServer = json.decode(response.body);
        allShirts.clear();
        for (var shirt in shirtsFromServer) {
          allShirts.add(ShirtModel.fromJson(shirt));
        }
        isLoading.value = false;
      } else {
        isLoading.value = false;
        Get.snackbar(
          "Error loading shirts",
          "There was a problem while getting the list of shirts. Try again later or contact our technical support. Status code: ${response.statusCode}",
          colorText: Colors.white,
          backgroundColor: Colors.red, 
          duration: const Duration(seconds: 5), 
          showProgressIndicator: true, 
        );
      }
    } on SocketException {
      isLoading.value = false;
      Get.snackbar(
        "Network Error",
        "Please check your internet connection and try again",
        colorText: Colors.white,
        backgroundColor: Colors.red, 
        duration: const Duration(seconds: 3), 
        showProgressIndicator: true
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again later or contact out technical support. Details: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5), 
        showProgressIndicator: true
      );
    }
  }

  Future<String?> uploadPhoto(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${apiUrl}upload'))
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonMap = json.decode(responseData);
        var url = jsonMap['url'];
        return url;
      } else {
        Get.snackbar("Upload Error", "Failed to upload photo.  Try again later or contact our technical support. Status code: ${response.statusCode}", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
        return null;
      }
    } on SocketException {
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 3), showProgressIndicator: true);
      return null;
    } catch (e) {
      Get.snackbar("Error", "Please contact our technical support. An unexpected error occurred: $e", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
      return null;
    }
  }

  addShirt(String color, String text, File? photo) async {
    isLoading.value = true;
    String? photoUrl;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      isLoading.value = false;
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    if (photo != null) {
      photoUrl = await uploadPhoto(photo);
      if (photoUrl == null) {
        isLoading.value = false;
        Get.snackbar("Upload Error", "Failed to upload photo", colorText: Colors.white, backgroundColor: Colors.red);
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('${apiUrl}shirts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'color': color, 'text': text, 'photoUrl': photoUrl}),
      );

      if (response.statusCode == 201) {
        fetchAllShirts();
        Get.snackbar("Shirt added", "Shirt was successfully added", colorText: Colors.white, backgroundColor: Colors.green);
      } else {
        Get.snackbar("Failed to add shirt", "Shirt adding failed. Please try again later or contact out technical support. Status code: ${response.statusCode}", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
      }
    } on SocketException {
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 3), showProgressIndicator: true);
    } catch (e) {
      Get.snackbar("Error", "Contact our technical support. An unexpected error occurred: $e", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> deleteFile(String url) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}deletephoto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'oldFileUrl': url}),
      );

      if (response.statusCode == 200) {
        print('File deleted successfully');
      } else {
        print('Failed to delete file');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  updateShirt(String color, String text, File? photo, int id, String? photoUrl) async {
    isLoading.value = true;
    String? newPhotoUrl;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      isLoading.value = false;
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 3), showProgressIndicator: true);
      return;
    }

    try {
      if (photoUrl != null && photo != null) {
        await deleteFile(photoUrl);
        newPhotoUrl = await uploadPhoto(photo);
      } else if (photoUrl == null && photo != null) {
        newPhotoUrl = await uploadPhoto(photo);
      } else if (photo == null && photoUrl != null) {
        await deleteFile(photoUrl);
        newPhotoUrl = null;
      }

      final response = await http.put(
        Uri.parse('${apiUrl}shirts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'color': color, 'text': text, 'photoUrl': newPhotoUrl}),
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        fetchAllShirts();
        Get.offAll(ShirtView(shirtViewModel: this));
        Get.snackbar("Shirt updated", "Shirt was successfully updated", colorText: Colors.white, backgroundColor: Colors.green);
      } else {
        isLoading.value = false;
        Get.snackbar("Failed to update", "Shirt update failed. Please try again later or contact out technical support. Status code: ${response.statusCode}", colorText: Colors.white, backgroundColor: Colors.red);
      }
    } on SocketException {
      isLoading.value = false;
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Contact our technical support. An unexpected error occurred: $e", colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  deleteShirt(ShirtModel shirt) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw SocketException("No internet connection available");
      }
      
      final response = await http.delete(Uri.parse('${apiUrl}shirts/${shirt.id}'));

      String? url = shirt.photoUrl;

      if (response.statusCode == 200) {
        allShirts.remove(shirt);
        if (url != null) {
          await deleteFile(url);
        }
        Get.snackbar("Shirt deleted", "Shirt was successfully deleted", colorText: Colors.white, backgroundColor: Colors.green);
      } else {
        Get.snackbar("Shirt delete", "Shirt deleting failed. Try again later or contact out technical support. Status code: ${response.statusCode}", colorText: Colors.white, backgroundColor: Colors.red, duration: const Duration(seconds: 5), showProgressIndicator: true);
      }
    } on SocketException {
      Get.snackbar("Network Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red,  duration: const Duration(seconds: 5), showProgressIndicator: true);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred. Please try again later", colorText: Colors.white, backgroundColor: Colors.red,  duration: const Duration(seconds: 5), showProgressIndicator: true);
    }
  }

}