import 'dart:async'; //非同期処理用
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //httpリクエスト用
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sample_app/article/article.dart';

class ArticleModel extends ChangeNotifier {
  //記事リスト
  List<WPArticle> articleList = <WPArticle>[];
  //ローディング
  bool isLoading = true;

  //WP APIからデータを取得
  Future<void> getWpArticle() async {
    //読み込みたいWordPressサイトのエンドポイント
    const String url =
        'https://techsmeme.com/index.php/wp-json/wp/v2/posts?_embed';
    final http.Response response =
        await http.get(url, headers: {'Accept': 'application.json'});

    //もし成功したら
    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> responseContent =
          jsonDecode(response.body).cast<Map<String, dynamic>>()
              as List<Map<String, dynamic>>;
      final List<WPArticle> newsList = responseContent
          .map(
            (Map<String, dynamic> wpArticle) => WPArticle(
              wpArticle['title']['rendered'] as String,
              removeHtmlTag(wpArticle['content']['rendered'] as String),
              changeDateFormat(wpArticle['date'] as String),
              judgeImageUrl(wpArticle),
              judgeCategory(wpArticle),
              wpArticle['link'] as String,
            ),
          )
          .toList();
      this.articleList = newsList;
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      notifyListeners();
      throw Exception('response is failed');
    }
  }

  //HTMLタグ排除
  String removeHtmlTag(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  //年月表示
  String changeDateFormat(String date) {
    initializeDateFormatting('ja_JP');
    // StringからDate
    final DateTime datetime = DateTime.parse(date);

    final DateFormat formatter = DateFormat('yyyy年MM月dd日', 'ja_JP');
    // DateからString
    final String formatted = formatter.format(datetime);
    return formatted;
  }

  //アイキャッチがあるか判定
  String judgeImageUrl(Map<String, dynamic> article) {
    if (article['_embedded']['wp:featuredmedia'] != null) {
      return article['_embedded']['wp:featuredmedia'][0]['media_details']
          ['sizes']['full']['source_url'] as String;
    } else {
      return '';
    }
  }

  //カテゴリーがあるか判定
  String judgeCategory(Map<String, dynamic> article) {
    if (article['_embedded']['wp:term'] != null) {
      return article['_embedded']['wp:term'][0][0]['name'] as String;
    } else {
      return '';
    }
  }
}
