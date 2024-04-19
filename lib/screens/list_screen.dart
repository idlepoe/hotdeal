import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotdeal/screens/detail_screen.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../models/item.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Item> _list = [];
  int _page = 1;

  @override
  void initState() {
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hotdeal"),
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () {
          _page++;
          getList();
        },
        child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {

                Navigator.of(context).push(SwipeablePageRoute(
                  builder: (BuildContext context) => DetailScreen(item: _list[index]),
                ));

                // Navigator.of(context).push(CupertinoPageRoute(
                //   builder: (context) {
                //     return DetailScreen(item: _list[index]);
                //   },
                // ));
              },
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: _list[index].imageUrl,
                    placeholder: (context, url) => Container(
                        width: 100,
                        height: 100,
                        child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) {
                      print(url);
                      print(error);
                      return Container(
                          width: 100, height: 100, child: Icon(Icons.error));
                    },
                  ),
                  Text(_list[index].title),
                  Text(_list[index].detailUrl),
                ],
              ),
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   getList();
      // }),
    );
  }

  Future<void> getList() async {
    var client = http.Client();
    var response = await client.get(
      Uri.parse('https://misskon.com/page/' + _page.toString()),
    );
    String responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    dom.Document document = parse(responseBody);
    List<dom.Element> imageList =
        document.querySelectorAll("article.item-list");

    for (dom.Element row in imageList) {
      String? imageUrl = row.querySelector("img")!.attributes["src"];
      String? title = row.querySelectorAll("a")[1].text.trim();
      String? detailUrl = row.querySelectorAll("a")[1].attributes["href"];
      _list.add(Item(imageUrl!, title, detailUrl!));
      setState(() {});
    }
  }
}
