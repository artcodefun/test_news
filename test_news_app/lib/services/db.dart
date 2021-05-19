import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' as p;
import 'package:test_news_app/models/News.dart';

class DBHelper {
  static Database? _db;

  static String? _photoDir;

  static getDir() async {
    _photoDir = _photoDir ??
        (await getApplicationDocumentsDirectory()).path + "/images/";
    return _photoDir;
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentDirectory.toString() , 'news.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    await getDir();
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
          'CREATE TABLE news (id INTEGER PRIMARY KEY, title TEXT, description TEXT, image TEXT,)');

  }

  Future<News> addFriend(News news) async {
    var dbClient = await db;
    await dbClient.insert('news', news.toMap());
    return news;
  }

  Future<List<News>> getNews() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('news', columns: ['id', 'title', 'description', 'image']);
    List<News> news = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        news.add(News.fromMap(maps[i]));
      }
    }
    return news;
  }

  Future<int> deleteNews(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'news',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<int> updateNewsFromList(List list) async {

    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('news', columns: ['id', 'title', 'description', 'image']);

/*    for (var i in maps) {
      if (!list.map((e) => e["id"]).contains(i["id"])) {
        await deleteNews(i["id"]);
        maps.remove(i);
      }
    }*/


        for (var i in list) {
      if (!maps.map((e) => e["id"]).contains(i["id"])) {
        await addFriend(News( id: i["id"], title: i["title"], description: i["description"], image: i["image"]));
      }
    }

    return 1;
  }

  Future clear() async{
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      var batch = txn.batch();
      batch.delete("news");
      await batch.commit();
    });

  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
