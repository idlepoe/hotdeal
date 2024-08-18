import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hotdeal/screens/detail_screen.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:popup_banner/popup_banner.dart';
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

  int _count = 0;

  List<String> _bull_type = [
    "archive",
    "ranking-images",
    "ranking-images/sort/update"
  ];

  @override
  void initState() {
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hotdeal"),
        actions: [
          ElevatedButton(
              onPressed: () {
                _count++;
                _page = 1;
                _list = [];
                setState(() {});
                if (_count == 3) {
                  _count = 0;
                }
                getList();
              },
              child: Text(_bull_type[_count]))
        ],
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () {
          _page++;
          getList();
        },
        child: MasonryGridView.count(
          itemCount: _list.length,
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                List<String> list = _list[index].imageUrl.split("/");

                String remake = "";
                int i = 0;
                for (String row in list) {
                  if (i == list.length - 2) {
                  } else {
                    remake += row + "/";
                  }
                  i++;
                }

                remake = remake.substring(0, remake.length - 1);

                print(remake);
                print(remake);
                print(remake);

                final imageProvider = Image.network(remake).image;
                showImageViewer(context, imageProvider,
                    swipeDismissible: true,
                    doubleTapZoomable: true, onViewerDismissed: () {
                  print("dismissed");
                });
              },
              child: FastCachedImage(
                url: _list[index].imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(seconds: 1),
                errorBuilder: (context, exception, stacktrace) {
                  return SizedBox();
                },
                loadingBuilder: (context, progress) {
                  return Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (progress.isDownloading &&
                            progress.totalBytes != null)
                          Text(
                              '${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb',
                              style: const TextStyle(color: Colors.red)),
                        SizedBox(
                            width: 120,
                            height: 120,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.blue,
                                    value: progress.progressPercentage.value))),
                      ],
                    ),
                  );
                },
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
    try {
      var client = http.Client();
      var response = await client.get(
        Uri.parse('https://ko.hentai-cosplays.com/' +
            _bull_type[_count] +
            '/page/' +
            _page.toString()),
      );
      String responseBody =
          utf8.decode(response.bodyBytes, allowMalformed: true);
      dom.Document document = parse(responseBody);
      List<dom.Element> imageList = document.querySelectorAll("img");

      for (dom.Element row in imageList) {
        print(row.attributes.toString());
        String? imageUrl = row.attributes["data-original"].toString();
        String? title = row.attributes["alt"].toString();
        String? detailUrl = "";
        _list.add(Item(imageUrl!, title, detailUrl!));
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
}
