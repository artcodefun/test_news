import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:test_news_app/models/News.dart';
import 'package:test_news_app/services/FileHandler.dart';

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

  Future<List<News>> getNews(int count, {int? lastID}) async {
    if (!ready) await initializeDefault();

    CollectionReference fbRef = firestore.collection("news");
    Reference storageRef = FirebaseStorage.instance.ref().child("images");

    var news = (await fbRef.get()).docs;

    List<News> res = [];
    int realLast =news.firstWhere((e) => e.id == "info").get("lastID");

    lastID = (lastID == null || lastID > realLast) ? realLast: (lastID<1)? 1: lastID;

    count =(lastID-count  < 0)?  lastID : count;

    for (var i = 0; i < count; i++) {
      var data = await fbRef.doc("${lastID! - i}").get();

      String downloadUrl = "";

      downloadUrl = await storageRef.child(data.get('image')).getDownloadURL();
      if (await FileHandler.getDownloadedPhoto(data.get("image")) == null)
        FileHandler.downloadPhoto(data.get("image"), downloadUrl);


      res.add(News(
          id: int.parse(data.id),
          title: data.get('title') as String,
          description: data.get('description') as String,
          image: data.get("image")));
    }

    return res;
  }

  NewsRepo._internal() {}
}
