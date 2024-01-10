import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () {
          _page++;
          getList();
        },
        child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Image.network(_list[index]),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        getList();
      }),
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
      _list.add(row.attributes["src"]!);
    }
    setState(() {});
  }
}
