import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader/Base.dart';
import 'package:reader/views/AddBoard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff202124),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xff202124),
    ));

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue, canvasColor: Colors.transparent),
      routes: {"/add-board": (context) => AddBoard()},
      home: Base(),
    );
  }
}
