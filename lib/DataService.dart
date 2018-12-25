import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:reader/models.dart';
import 'package:sqflite/sqflite.dart';

class DataService {
  static final DataService _instance = new DataService.internal();

  factory DataService() => _instance;
  static Database _db;

  DataService.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'reader.db');
//    await deleteDatabase(path);
    var db = await openDatabase(path, version: 1, onCreate: _create);
    return db;
  }

  void _create(Database db, int version) async {
    await db.execute(
        "CREATE TABLE boards(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, title TEXT);");
  }

  fetchPost() async {
    final response = await http.get('https://a.4cdn.org/boards.json');

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<List> getBoards() async {
    List boards = new List();
    var db_connection = await db;
    List rows = await db_connection.rawQuery("SELECT * FROM boards");
    for (var i = 0; i < rows.length; i++) {
      var board = BoardListItem(rows[i]["name"], rows[i]["title"], false);
      boards.add(board);
    }
    print(boards.length);
    return boards;
  }

  Future addBoard(String board, String title) async {
    var db_connection = await db;
    print(db_connection);
    await db_connection
        .rawInsert("INSERT INTO boards(name, title) VALUES('" +
            board +
            "', '" +
            title +
            "')")
        .then((response) => print(response));
  }

  Future deleteBoard(String board) async {
    var db_connection = await db;
    await db_connection.rawDelete("DELETE FROM boards WHERE name = ?",
        [board]).then((response) => print(response));
  }

  Future resetDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'reader.db');
    await deleteDatabase(path);
  }

  Future getBoardContent(String board) async {
    final response = await http.get('https://a.4cdn.org/${board}/threads.json');
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future getThread(String board, String threadID) async {
    final response =
        await http.get('https://a.4cdn.org/${board}/thread/${threadID}.json');
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load post');
    }
  }
}
