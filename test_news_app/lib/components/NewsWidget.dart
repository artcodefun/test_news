import 'package:flutter/material.dart';
import 'package:test_news_app/models/News.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({Key? key, required this.news}) : super(key: key);

  final News news;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: Image.network(
          news.image,
          fit: BoxFit.fitHeight,
        )),
        Positioned.fill(
            child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(news.title, style: Theme.of(context).textTheme.headline1),

              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(news.description,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
            ]),
          ),
        ))
      ],
    );
  }
}
