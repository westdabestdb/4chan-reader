import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reader/DataService.dart';

class AddBoard extends StatefulWidget {
  @override
  _AddBoardState createState() => _AddBoardState();
}

class _AddBoardState extends State<AddBoard> {
  DataService dataService = DataService();
  List boards = List();
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    dataService.fetchPost().then((response) {
      var decoded_body = json.decode(response.body);
      boards = decoded_body["boards"] as List;
      print(boards);
      setState(() {
        isLoading = false;
      });
    }).whenComplete(() => print("done"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff202124),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xff202124),
        title: Text(
          "Add Board",
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            )
          : ListView.builder(
              itemCount: boards.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    "/" +
                        boards[index]["board"] +
                        "/ - " +
                        boards[index]["title"],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        addBoard(
                            boards[index]["board"], boards[index]["title"]);
                      }),
                );
              }),
    );
  }

  void addBoard(String board, String title) {
    DataService dataService = DataService();
    dataService.addBoard(board, title);
//    dataService.addBoard(board);
  }
}
