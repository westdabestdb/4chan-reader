import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reader/DataService.dart';
import 'package:reader/models.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController controller;
  DataService dataService = DataService();
  List boardsTabs = [];
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var i = 0;
    setState(() {
      loading = true;
    });
    dataService.getBoards().then((boards) {
      i = boards.length;
      boardsTabs = boards;
      controller = TabController(length: i, vsync: this);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Color(0xff383B36),
          centerTitle: true,
          title: Text(
            "Reader",
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
          ),
          bottom: loading
              ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
              : TabBar(
//            isScrollable: boardsTabs.length > 4 ? true : false,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2.0,
                  tabs: boardsTabs
                      .map(
                        (board) => Container(
                            width: 64.0,
                            child: Tab(text: "/" + board.name + "/")),
                      )
                      .toList(),
                  controller: controller,
                ),
        ),
        loading
            ? SliverFillRemaining(
                child: Center(child: Text("Loading")),
              )
            : SliverFillRemaining(
                child: boardsTabs.length > 0
                    ? TabBarView(
                        controller: controller,
                        children: boardsTabs.map((board) {
                          return Container(
                            child: ListView(
                              children: createThreadListView(board.name),
                            ),
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Text(
                        "Not following any boards",
                        style: TextStyle(color: Colors.white),
                      )),
              )
      ],
    );
  }

  createThreadListView(String board) async {
    List posts = [];
    List<dynamic> ids = [];
    dataService.getBoardContent(board).then((response) {
      var decoded_body = json.decode(response.body);
      List threads = decoded_body[0]["threads"] as List;
      createThreadIDList(threads).then((data) {
        ids = data;
        print(ids);
        ids.forEach((id) {
          dataService.getThread(board, id.toString()).then((response) {
            var decoded_body = json.decode(response.body);
            var thread_data = decoded_body["posts"];
            thread_data = thread_data[0];
            Thread post = Thread(
                thread_data["no"],
                thread_data["now"],
                thread_data["com"],
                thread_data["replies"],
                thread_data["filename"],
                thread_data["extension"],
                thread_data["resto"]);
            posts.add(post);
          });
        });
      });
    });
    return posts.toList();

//    threads.forEach((val) {
//      dataService.getThread(board, val["no"].toString()).then((response) {
//        var decoded_thread = json.decode(response.body);
//        decoded_thread = decoded_thread["posts"];
//        print(decoded_thread);
//      });
//    });
  }

  Future createThreadIDList(List threads) async {
    List ids = [];
    threads.forEach((thread) {
      ids.add(thread["no"]);
    });
    return ids;
  }
}
