import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reader/Constants.dart';
import 'package:reader/DataService.dart';
import 'package:reader/models.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey _futureBuilderKey = new GlobalKey();
  TabController controller;
  DataService dataService = DataService();
  var unescape = new HtmlUnescape();
  List boardsTabs = [];
  bool loading = false;
  int activeTab = 0;

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
    controller.addListener(_tabListener);
    setState(() {
      loading = false;
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {},
            )
          ],
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
                          return Center(
                            child: boardsTabs.indexOf(board) == activeTab
                                ? RefreshIndicator(
                                    key: _refreshIndicatorKey,
                                    onRefresh: _refreshBoard,
                                    child: FutureBuilder(
                                      key: _futureBuilderKey,
                                      future: getThreads(board.name),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.none:
                                            return CircularProgressIndicator();
                                          case ConnectionState.waiting:
                                            return CircularProgressIndicator();
                                          default:
                                            if (snapshot.hasError) {
                                              return new Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              return ListView.builder(
                                                  itemCount:
                                                      snapshot.data.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return snapshot.data[index];
                                                  });
                                            }
                                        }
                                      },
                                    ),
                                  )
                                : CircularProgressIndicator(),
                          );
                        }).toList(),
                      )
                    : Center(child: Text("none")), // no boards = none
              )
      ],
    );
  }

  Future getThreads(String board) async {
    List c = []; // so this is empty
    print("lulz");
    var a = '<a href="http://google.com">fudked</a>';
    var response = await dataService.getBoardContent(board);
    var decoded_body = json.decode(response.body);
    var thread_data = decoded_body["threads"] as List;
    for (final thread_list in thread_data) {
      thread_data = thread_list["posts"] as List;
      for (final thread in thread_data) {
        var replies = thread["replies"];
        if (replies == null) {
          replies = "no";
        }
        ;
        if (thread["resto"] == 0) {
          var card = Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xff242528)),
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "/${board}/ • ${replies} replies",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white70,
                      ),
                      padding: EdgeInsets.all(0),
                      tooltip: "Actions",
                      itemBuilder: (BuildContext context) {
                        return Constants.menu.map((String choice) {
                          return PopupMenuItem(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                    dense: true,
                  ),
                  thread["tim"] != null
                      ? Container(
                          child: Image.network(
                            "http://i.4cdn.org/${board}/${thread["tim"]}${thread["ext"]}",
                          ),
                          margin: EdgeInsets.only(bottom: 16.0),
                        )
                      : Container(width: 0, height: 0),
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
//                    child: HtmlView(
//                      data: thread["com"].toString(),
//                    ),
                    child: Text(
                      replaceHTML(thread["com"].toString()),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ));
          c.add(card);
        }
      }
    }
    return c;
  }

  void _tabListener() {
    setState(() {
      activeTab = controller.index;
    });
  }

  replaceHTML(String html) {
    var returnable = html.replaceAll(new RegExp(r'<br>'), "\n");
//    var returnable = html.replaceAll(new RegExp(r'<br><br>'), "\t");
    returnable = unescape.convert(returnable);
    return returnable;
  }

  Future<Null> _refreshBoard() async {
    print("refreshed");
    setState(() {

    });
    await new Future.delayed(new Duration(seconds: 2));
    return null;
  }
}
