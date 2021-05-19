import 'package:flutter/cupertino.dart';
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
    var result = await controller.updateNews();

    if (result == null) {
      _refreshController.refreshFailed();
      return;
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    var result = await controller.loadMoreNews();

    if (result == null) {
      _refreshController.loadFailed();
      return;
    }
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
            onLoading: _onLoading,
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropHeader(
              waterDropColor: Theme.of(context).primaryColor,
            ),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("pull up load");
                } else if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("release to load more");
                } else {
                  body = Text("No more Data");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: StreamBuilder<List<News>>(
                stream: controller.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty)
                      return (Center(
                        child: Text("No news are awailiable right now"),
                      ));
                    return SafeScroll(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: snapshot.data!
                            .map((e) => SizedBox(
                                  height: MediaQuery.of(context).size.height ~/
                                      3 *
                                      1.0,
                                  child: NewsWidget(news: e),
                                ))
                            .toList(),
                      ),
                    );
                  }
                  return ListView.builder(
                      itemBuilder: (c, i) => Container(
                            color: Colors.black.withOpacity(0.2 * (i % 2)),
                            height:
                                MediaQuery.of(context).size.height ~/ 3 * 1.0,
                            child: Center(child: CircularProgressIndicator()),
                          ));
                }),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
