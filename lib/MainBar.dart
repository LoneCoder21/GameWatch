import 'dart:convert';
import 'dart:async';
import 'package:basic_flutter_app/DataBase.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter_app/LibraryView.dart';
import 'package:basic_flutter_app/SavedView.dart';
import 'package:basic_flutter_app/SearchView.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:basic_flutter_app/Game.dart';

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
      //print(id);
      model.add(Game(gameId: id, name: i['name']));
    }
    return model;
    //manager.insertGames(model);
  }

  void fetchGames(http.Client client) async {
    final response = await client.get(
        Uri.parse('http://api.steampowered.com/ISteamApps/GetAppList/v0002/'));

    if (response.statusCode == 200) {
      final games = compute(parseGames, response.body);
      //manager.insertGames(await games);
    }
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
  GameManager manager = GameManager();
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
    manager.fetchGames(http.Client());
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
