import 'dart:convert';
import 'package:gamewatch/DataBase.dart';
import 'package:flutter/material.dart';
import 'package:gamewatch/LibraryView.dart';
import 'package:gamewatch/SavedView.dart';
import 'package:gamewatch/SearchView.dart';
import 'package:gamewatch/Game.dart';

class MainBar extends StatelessWidget {
  const MainBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Bar(title: 'Welcome'),
    );
  }
}

class GameManager {
  final DbManager manager = new DbManager();

  List<Game> parseGames(String responseBody) {
    final jsonData = json.decode(responseBody);
    List<Game> model = [];
    for (Map<String, dynamic> i in jsonData['applist']['apps']) {
      int id = i['appid'];
      model.add(Game(gameId: id, name: i['name']));
    }
    return model;
  }
}

class Bar extends StatefulWidget {
  const Bar({super.key, required this.title});

  final String title;

  @override
  State<Bar> createState() => BarState();
}

class BarState extends State<Bar> {
  int _index = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    LibraryView(),
    SavedView(),
    SearchView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_index),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: this._index,
        selectedItemColor: Color(0xffDA70D6),
        onTap: _onItemTapped,
      ),
    );
  }
}
