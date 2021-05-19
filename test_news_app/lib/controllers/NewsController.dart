import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test_news_app/models/News.dart';
import 'package:test_news_app/services/DBHelper.dart';
import 'package:test_news_app/services/NewsRepo.dart';


class NewsController {
  static const int itemsForPage = 10;
  List<News>? _newsList;

  Future<List<News>> getNews() async {
    if (_newsList != null) return _newsList!;

    try {
      _newsList = await Future.any([
        NewsRepo().getNews(itemsForPage),
        Future.delayed(Duration(seconds: 10), ()=>null)
      ]).then((v) async {
      if(v==null) return await DBHelper().getNews(); else return v;} );
      DBHelper().updateNewsFromList(_newsList!);
    } catch (e) {
      DBHelper().getNews();
      _newsList = [];
    }

    return _newsList!;
  }
}
