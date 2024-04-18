import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Tshirt/view_model/ImageGetter.dart';
import 'package:Tshirt/view_model/ShirtViewModel.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UpdateShirt extends StatefulWidget {
  final ShirtViewModel shirtViewModel;

  const UpdateShirt({Key? key, required this.shirtViewModel}) : super(key: key);

  @override
  State<UpdateShirt> createState() => _UpdateShirtState();
}

class _UpdateShirtState extends State<UpdateShirt> {
  final colorController = TextEditingController();
  final textController = TextEditingController();
  File? _image;

  var data = Get.arguments;

  Future<File> getImageFile(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/cached_image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> downloadImage(String url) async {
    final file = await getImageFile(url);
    setState(() {
      _image = file;
    });
  }

  @override
  void initState() {
    super.initState();
    colorController.text = data.color;
    textController.text = data.text;
    if (data.photoUrl != null){
      downloadImage(data.photoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
     return SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text("Edit Shirt:", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.deepPurple,),
          body: Obx(() => LoadingOverlay(
            isLoading: widget.shirtViewModel.isLoading.value,
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        File? croppedImage = await ImageGetter.pickAndCropImage(context, 1.0);
                        setState(() {
                          _image = croppedImage;
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover,): Icon(Icons.add_a_photo, color:Colors.grey[700], size: 50,),
                      ),
                    ),
                    SizedBox(height: 24,),
                    TextField(
                      controller: colorController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        labelText: 'Colors',
                        hintText: 'Enter available colors'
                      ),
                    ),

                    SizedBox(height: 14,),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        labelText: 'Materials',
                        hintText: 'Enter materials description'
                      ),
                    ),
                    SizedBox(height: 24,), 

                    InkWell(
                      onTap: (){
                        if(colorController.text != "" && textController.text != "")
                        {
                          widget.shirtViewModel.updateShirt(colorController.text, textController.text, _image, data.id, data.photoUrl);
                        } else {Get.snackbar("Invalid input", "All fields must contain text", colorText: Colors.white, backgroundColor: Colors.red);}
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text("Submit", style: TextStyle(color: Colors.white),),
                      )
                    )
                  ]
                ),
              )
            )
          )
        )
      )
    );
  }
}