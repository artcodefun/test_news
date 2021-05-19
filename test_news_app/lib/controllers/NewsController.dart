import 'package:test_news_app/models/News.dart';
import 'package:test_news_app/services/NewsRepo.dart';


class NewsController{

  static const int itemsForPage = 10;
  List<News>? _newsList;

  Future<List<News>> getNews() async {
    if(_newsList!=null) return _newsList!;
    try{
      _newsList = await NewsRepo().getNews(itemsForPage);

    }catch(e){
      _newsList =[];
    }

    return _newsList!;
  }




}