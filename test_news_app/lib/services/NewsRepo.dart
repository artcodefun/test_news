import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:test_news_app/models/News.dart';

class NewsRepo {
  static final NewsRepo _NewsRepo = NewsRepo._internal();

  factory NewsRepo() {
    return _NewsRepo;
  }

  bool ready = false;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  FirebaseStorage get storage => FirebaseStorage.instance;

  Future<void> initializeDefault() async {
    if (ready) return;

    FirebaseApp app = await Firebase.initializeApp();
    ready = true;
    assert(app != null);

    print('Initialized default app $app');
  }

  Future<List<News>> getNews() async {
    
    if (!ready) await initializeDefault();

    CollectionReference fbRef = firestore.collection("news");
    Reference storageRef = FirebaseStorage.instance.ref("/images");

    var news = (await fbRef.get()).docs;

    List<News> res = [];

    for (var n in news) {
      var data = await fbRef.doc(n.id).get();

      //Uint8List image = (await storageRef.child(p.get("image")).getData())!;


      String downloadUrl ="m";
      try {
        downloadUrl = await storageRef.child(data.get('image')).getDownloadURL();

        print(downloadUrl);
      } catch(e){
        print("$e");
      }

      //Todo img downloads
      
      
      res.add(News(
          title: data.get('title') as String,
          description: data.get('description') as String,
          image: downloadUrl ));
    }

    return res;
  }

  NewsRepo._internal() {}
}
