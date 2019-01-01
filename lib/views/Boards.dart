import 'package:flutter/material.dart';
import 'package:reader/DataService.dart';

class Boards extends StatefulWidget {
  @override
  _BoardsState createState() => _BoardsState();
}

class _ListItem {
  _ListItem(this.name, this.value, this.checked);

  final String name;
  final String value;
  bool checked;
}

class _BoardsState extends State<Boards> {
  DataService dataService = DataService();
  List boards = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataService.getBoards().then((response) {
      setState(() {
        boards = response;
      });
      boards = response;
      print(boards);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xff202124),
        title: Text(
          "Boards",
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
//      body: boards.length > 0 ? renderBoardList() : renderEmptyBoardList(),
      body: FutureBuilder(
        future: dataService.getBoards(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Center(
                child: Text("Loading"),
              );

            default:
              if (snapshot.hasError)
                return new Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              else if (snapshot.hasData && snapshot.data.length <= 0) {
                print(snapshot.data.toString() + "data");
                return renderEmptyBoardList();
              } else
                return ReorderableListView(
                  children: snapshot.data
                      .map<Widget>((board) => Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          key: Key(board.name),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                key: Key(board.name),
                                title: Text(
                                  board.value,
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: Container(
                                  width: 96,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        color: Colors.white,
                                        icon: Icon(Icons.delete_forever),
                                        onPressed: () =>
                                            deleteBoard(board.name),
                                      ),
                                      IconButton(
                                        color: Colors.white,
                                        icon: Icon(Icons.reorder),
                                        onPressed: () {},
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.white54,
                              )
                            ],
                          )))
                      .toList(),
                  onReorder: _onReorder,
                );
          }
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex = -1;
      }
      final _ListItem _board = boards.removeAt(oldIndex);
      boards.insert(newIndex, _board);
    });
  }

  deleteBoard(String board) {
    DataService dataService = DataService();
    dataService.deleteBoard(board);
    dataService.getBoards().then((response) {
      setState(() {
        boards = response;
      });
      boards = response;
      print(boards);
    });
  }

  renderBoardList() {
    return ReorderableListView(
      children: boards
          .map((board) => Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              key: Key(board.name),
              child: Column(
                children: <Widget>[
                  ListTile(
                    key: Key(board.name),
                    title: Text(
                      board.value,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Container(
                      width: 96,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.delete_forever),
                            onPressed: () => deleteBoard(board.name),
                          ),
                          IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.reorder),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.white54,
                  )
                ],
              )))
          .toList(),
      onReorder: _onReorder,
    );
  }

  renderEmptyBoardList() {
    return Center(
      child: Text(
        "No active boards",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
