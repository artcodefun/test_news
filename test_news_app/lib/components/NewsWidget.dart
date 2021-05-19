import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_news_app/models/News.dart';
import 'package:test_news_app/services/FileHandler.dart';
import 'package:test_news_app/services/NewsRepo.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({Key? key, required this.news}) : super(key: key);

  final News news;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<File?>(
          future: FileHandler.getDownloadedPhoto(news.image),
          builder: (context, snapshot) {
            if(snapshot.hasData)
            return Positioned.fill(
                child: Image.file(
                  snapshot.data!
              ,
              fit: BoxFit.fitHeight,
            ));
            return Container();
          }
        ),
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
