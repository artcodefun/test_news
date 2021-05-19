import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test_news_app/models/News.dart';
import 'package:test_news_app/services/DBHelper.dart';
import 'package:test_news_app/services/NewsRepo.dart';

class NewsController {
  static const int itemsForPage = 10;
  List<News>? _newsList;

  StreamController<List<News>> _controller = StreamController.broadcast();

  NewsController() {
    _stream = _controller.stream;
    _sink = _controller.sink;
  }

  Stream<List<News>>? _stream;
  StreamSink<List<News>>? _sink;

  Stream<List<News>> get stream => () {
        getNews();
        return _stream!;
      }();

  Future<List<News>> getNews() async {
    if (_newsList != null) {
      _sink!.add(_newsList!);
      return _newsList!;
    }

    try {
      _newsList = await Future.any([
        NewsRepo().getNews(itemsForPage),
        Future.delayed(Duration(seconds: 10), () => null)
      ]).then((v) async {
        if (v == null) {
          var backup = await DBHelper().getNews();
          return backup;
        } else
          return v;
      });
      DBHelper().updateNewsFromList(_newsList!);
    } catch (e) {
      _newsList = await DBHelper().getNews();
    }

    _sink!.add(_newsList!);

    return _newsList!;
  }

  updateNews() async {
    return await Future.any([
      NewsRepo()
          .getNews(itemsForPage,
              lastID:
                  (_newsList!.isEmpty ? itemsForPage*2 : _newsList!.first.id) + itemsForPage)
          .then((list) async {
        await DBHelper().updateNewsFromList(list);
        _newsList = await DBHelper().getNews();
        _sink!.add(_newsList!);
        return _newsList;
      }),
      Future.delayed(Duration(seconds: 10), () => null)
    ]).onError((error, stackTrace) => null);
  }

  loadMoreNews() async {
    return await Future.any([
      NewsRepo()
          .getNews(itemsForPage,
              lastID: (_newsList!.isEmpty ? 10 : _newsList!.last.id))
          .then((list) async {
        await DBHelper().updateNewsFromList(list);
        _newsList = await DBHelper().getNews();
        _sink!.add(_newsList!);
        return _newsList;
      }),
      Future.delayed(Duration(seconds: 10), () => null)
    ]).onError((error, stackTrace) => null);
  }
}
