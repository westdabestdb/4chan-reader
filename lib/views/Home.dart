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
  Future initState() {
    // TODO: implement initState
    super.initState();
    loadTabs(); // this is the code that loads tabs
  }

  loadTabs() async {
    setState(() {
      loading = true; // sets loading variable
    });
    boardsTabs = await dataService.getBoards(); // gets list of boards
    print(boardsTabs);
    var i = boardsTabs.length;
    controller = TabController(length: i, vsync: this);
    // sets tab controller length
    setState(() {
      loading = false; // sets loading false
    });
  }

  loadTabContent() async {}

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Color(0xff202124),
          centerTitle: true,
          title: Text(
            "Reader",
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
          ),
          bottom: loading
              ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
              : TabBar(
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
                          return FutureBuilder(
                            future: getThreads(board.name),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return new Text('Waiting to start');
                                case ConnectionState.waiting:
                                  return new Text('Loading...');
                                default:
                                  if (snapshot.hasError) {
                                    return new Text('Error: ${snapshot.error}');
                                  } else {
                                    return ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return snapshot.data[index];
                                        });
                                  }
                              }
                            },
                          );
                        }).toList(),
                      )
                    : Center(child: Text("none")), // no boards = none
              )
      ],
    );
  }

  Future createThreadIDList(List threads) async {
    List ids = [];
    threads.forEach((thread) {
      ids.add(thread["no"]);
    });
    return ids;
  }

  Future createThreadCards(String board, List ids) async {
    List cards = [];
    for (final id in ids) {
      print(id);
      var response = await dataService.getThread(board, id.toString());
      var decoded_body = json.decode(response.body)["posts"][0];
      var card = Card(
        child: Text(decoded_body["com"].toString()),
      );
      cards.add(card);
    }
    return cards;
  }

  Future getThreads(String board) async {
    List c = []; // so this is empty
    var response = await dataService.getBoardContent(board);
    var decoded_body = json.decode(response.body);
    var thread_data = decoded_body[0]["threads"] as List;
    var ids = await createThreadIDList(thread_data);
    c = await createThreadCards(board, ids);
    return c;
  }
}
