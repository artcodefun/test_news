import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:test_news_app/components/NewsWidget.dart';
import 'package:test_news_app/components/SafeScroll.dart';
import 'package:test_news_app/controllers/NewsController.dart';

import 'models/News.dart';
import 'services/NewsRepo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            headline1: TextStyle(color: Colors.white, fontSize: 25),
            bodyText1: TextStyle(color: Colors.white, fontSize: 15),
          )),
      home: MyHomePage(title: 'Flutter Test News App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NewsController controller = NewsController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            header: WaterDropHeader( waterDropColor: Theme.of(context).primaryColor,),
            child: FutureBuilder<List<News>>(
                future: controller.getNews(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SafeScroll(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: snapshot.data!
                            .map((e) => SizedBox(
                                  height: MediaQuery.of(context).size.height ~/ 3 *1.0,
                                  child: NewsWidget(news: e),
                                ))
                            .toList(),
                      ),
                    );
                  }
                  return ListView.builder(itemBuilder: (c,i)=>Container(color: Colors.black.withOpacity(0.2*(i%2)),
                    height: MediaQuery.of(context).size.height ~/ 3 *1.0, child: Center(child: CircularProgressIndicator()), ));
                }),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
