import 'package:flutter/material.dart';
import 'package:reader/DataService.dart';
import 'package:reader/views/Boards.dart';
import 'package:reader/views/Home.dart';

class Base extends StatefulWidget {
  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> with SingleTickerProviderStateMixin {
  TabController controller;
  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 9, vsync: this);
    _pageController = PageController(keepPage: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.sync(onWillPop),
      child: Scaffold(
        backgroundColor: Color(0xff383B36),
        body: PageView(
          onPageChanged: onPageChanged,
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Home(),
            Boards(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Color(0xff383B36),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            height: 56.0,
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: showMenu,
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                ),
                Spacer(),
                _page == 0
                    ? IconButton(
                        onPressed: () {
                          DataService dataService = DataService();
                          dataService.resetDatabase();
                        },
                        icon: Icon(Icons.search),
                        color: Colors.white,
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                _page == 0
                    ? IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                        color: Colors.white,
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                _page == 1
                    ? IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.pushNamed(context, "/add-board");
                        },
                        color: Colors.white,
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: Color(0xff383B36),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  height: (56 * 5).toDouble(),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          "Home",
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        onTap: () => go(0),
                      ),
                      ListTile(
                        title: Text(
                          "Boards",
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Icon(
                          Icons.format_list_bulleted,
                          color: Colors.white,
                        ),
                        onTap: () => go(1),
                      ),
                      ListTile(
                        title: Text(
                          "Bookmarks",
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Icon(
                          Icons.bookmark_border,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(
                          "History",
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Icon(
                          Icons.history,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(
                          "Settings",
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Icon(
                          Icons.tune,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.wb_sunny),
                  onPressed: () {},
                  color: Colors.white,
                )
              ],
            ),
          );
        });
  }

  void go(int index) {
    _pageController.jumpToPage(index);
    Navigator.pop(context);
//    _pageController.animateToPage(
//        index,
//        duration: const Duration(milliseconds: 300),
//        curve: Curves.ease
//    );
  }

  void onPageChanged(int value) {
    setState(() {
      this._page = value;
    });
  }

  bool onWillPop() {
    if (_page != 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 1),
        curve: Curves.linear,
      );
      return false;
    } else {
      return true;
    }
  }
}
