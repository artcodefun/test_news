import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' as p;

class FileHandler{

  static String? _photoDir;

  static Future<String> getDir() async {
    _photoDir ??= (await getApplicationDocumentsDirectory()).path + "/images/";
    return _photoDir!;
  }


  static Future<File> downloadPhoto(String filename, String url) async {
    String path = await getDir() + filename;
    try {
      await Dio().download(url, path);
    } catch (e) {
      try {
        File file = File(path);
        await file.delete();
      } catch (e) {
        print(e);
      }
      throw HttpException("");

    }
    return (await getDownloadedPhoto(filename))!;
  }

  static Future<File?> getDownloadedPhoto(String filename) async {
    String path = await getDir() + filename;
    File file = File(path);
    if (await file.exists()) {
      return file;
    } else
      return null;
  }
}