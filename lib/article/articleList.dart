import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_app/article/article.dart';
import 'package:sample_app/article/article_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ArticleModel>(
      create: (_) => ArticleModel()..getWpArticle(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            body: Consumer<ArticleModel>(
              builder:
                  (BuildContext context, ArticleModel model, Widget child) {
                final List<WPArticle> articleList = model.articleList;
                final List<Widget> listArticle = articleList
                    .map(
                      (WPArticle wpArticle) => articleCard(wpArticle),
                    )
                    .toList();
                return ListView(
                  children: listArticle,
                );
              },
            ),
          ),
          Consumer<ArticleModel>(builder:
              (BuildContext context, ArticleModel model, Widget child) {
            return loadingScreen(model.isLoading);
          }),
        ],
      ),
    );
  }

  Widget loadingScreen(bool isLoading) {
    if (isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget articleCard(WPArticle wpArticle) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          launchURL(wpArticle.link);
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  categoryBtn(wpArticle.category),
                ],
              ),
              Container(
                width: double.infinity,
                child: Text(
                  wpArticle.title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  wpArticle.date,
                  textAlign: TextAlign.left,
                ),
              ),
              articleImage(wpArticle.image),
            ],
          ),
        ),
      ),
    );
  }

  Widget articleImage(String imageUrl) {
    if (imageUrl != '') {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (BuildContext context, String url) => Container(),
        errorWidget: (BuildContext context, String url, dynamic error) =>
            Container(),
      );
    } else {
      return Container();
    }
  }

  Widget categoryBtn(String category) {
    if (category != '') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Text(
          category,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
