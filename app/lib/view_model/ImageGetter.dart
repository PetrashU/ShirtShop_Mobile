import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ImageGetter {
  static Future<File?> pickAndCropImage(BuildContext context, double desiredAspectRatio) async {
    final ImagePicker picker = ImagePicker();
    final Completer<ImageSource?> sourceCompleter = Completer<ImageSource?>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Upload new or delete'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                sourceCompleter.complete(ImageSource.camera);
                Navigator.pop(context);
              },
              child: const Text('From camera'),
            ),
            SimpleDialogOption(
              onPressed: () {
                sourceCompleter.complete(ImageSource.gallery);
                Navigator.pop(context);
              },
              child: const Text('From gallery'),
            ),
            SimpleDialogOption(
              onPressed: () {
                sourceCompleter.complete(null);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    final ImageSource? source = await sourceCompleter.future;

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        ImageProperties properties = await FlutterNativeImage.getImageProperties(pickedFile.path);

        int? minLength = properties.width! < properties.height!
            ? properties.width
            : properties.height;

        int x = (properties.width! - minLength!) ~/ 2;
        int y = (properties.height! - minLength) ~/ 2;

        File croppedFile = await FlutterNativeImage.cropImage(
          pickedFile.path, 
          x,
          y,
          minLength,
          minLength,
        );

        return croppedFile;
      }
    }

    return null;
  }
}
