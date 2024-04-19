import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../models/item.dart';

class DetailScreen extends StatefulWidget {
  final Item item;

  DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<String> _list = [];
  int _page = 1;
  bool _pageEnd = false;

  @override
  void initState() {
    init();
  }

  init() {
    getList();
    // _page++;
    // getList();
    // _page++;
    // getList();
    // _page++;
    // getList();
    // _page++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () {
          if (_pageEnd) return;
          _page++;
          getList();
        },
        child: MasonryGridView.count(
          itemCount: _list.length,
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _list[index],
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
            );
          },
        ),
      ),
    );
  }

  Future<void> getList() async {
    var client = http.Client();
    var response = await client.get(
      Uri.parse(widget.item.detailUrl + _page.toString()),
    );
    String responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    dom.Document document = parse(responseBody);
    List<dom.Element> imageList = document.querySelectorAll("img.aligncenter");
    for (dom.Element row in imageList) {
      if (_list.contains(row.attributes["src"]!)) {
        _pageEnd = true;
        return;
      }
      _list.add(row.attributes["src"]!);
    }
    setState(() {});
  }
}
