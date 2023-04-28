import 'dart:convert';
import 'dart:async';
import 'package:basic_flutter_app/GameCard.dart';
import 'package:basic_flutter_app/GameView.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:basic_flutter_app/GameRowListView.dart';
import 'package:basic_flutter_app/Game.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return LibraryPage();
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  final size = 10.0;
  final cardheight = 190.0;
  final GameDetails details = GameDetails();
  late Future<List<GameCard>> futureFeatured;
  late Future<List<GameCard>> futureComingSoon;
  late Future<List<GameCard>> futureTopSellers;
  late Future<List<GameCard>> futureNewReleases;
  late Future<List<GameCard>> futureSpecials;

  List<int> skipids = [
    1675200,
    1059530,
    354231,
    1059550,
    1059570,
  ];

  Future<List<GameCard>> fetchFeaturedGames(http.Client client,
      [int limit = 5]) async {
    final response = await client
        .get(Uri.parse('https://store.steampowered.com/api/featured/'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<GameCard> model = [];
      Set<int> s = {};
      int count = 0;
      for (Map<String, dynamic> i in jsonData['featured_win']) {
        if (count > limit) break;
        int id = i['id'];
        if (!skipids.contains(id) && !s.contains(id)) {
          count++;
          final info = await details.fetchGameByAppID(id);
          if (info != null && info.unsafecontent == false) {
            s.add(id);
            model.add(GameCard.fromMap(i));
          }
        }
      }
      return model;
    } else {
      return [];
    }
  }

  Future<List<List<GameCard>>> fetchCategoryGames(
      http.Client client, List<String> categories,
      [int limit = 5]) async {
    final response = await client.get(
        Uri.parse('https://store.steampowered.com/api/featuredcategories/'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<List<GameCard>> models = [];
      for (String category in categories) {
        List<GameCard> model = [];
        Set<int> s = {};
        int count = 0;
        for (Map<String, dynamic> i in jsonData[category]['items']) {
          if (count > limit) break;
          int id = i['id'];
          if (!skipids.contains(id) && !s.contains(id) && i['type'] == 0) {
            count++;
            final info = await details.fetchGameByAppID(id);
            if (info != null && info.unsafecontent == false) {
              s.add(id);
              model.add(GameCard.fromMap(i));
            }
          }
        }
        models.add(model);
      }
      return models;
    } else {
      return [];
    }
  }

  List<Game> parseGames(String rbody) {
    final jsonData = json.decode(rbody);
    List<Game> g = [];
    Set<int> s = {};
    for (Map<String, dynamic> i in jsonData['applist']['apps']) {
      int id = i['appid'];
      if (!skipids.contains(id) && !s.contains(id)) {
        s.add(id);
        g.add(Game(gameId: i['appid'], name: i['name']));
      }
    }
    return g;
  }

  @override
  void initState() {
    super.initState();

    final client = http.Client();

    futureFeatured = fetchFeaturedGames(client);
    late Future<List<List<GameCard>>> categorygames = fetchCategoryGames(
        client, ['coming_soon', 'top_sellers', 'new_releases', 'specials']);

    futureComingSoon = categorygames.then((value) => value[0]);
    futureTopSellers = categorygames.then((value) => value[1]);
    futureNewReleases = categorygames.then((value) => value[2]);
    futureSpecials = categorygames.then((value) => value[3]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<GameCard>>>(
      future: Future.wait([
        futureFeatured,
        futureComingSoon,
        futureTopSellers,
        futureNewReleases,
        futureSpecials
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<GameCard> featured = snapshot.data![0];
          List<GameCard> coming_soon = snapshot.data![1];
          List<GameCard> top_sellers = snapshot.data![2];
          List<GameCard> new_releases = snapshot.data![3];
          List<GameCard> specials = snapshot.data![4];

          return Scaffold(
              backgroundColor: Color(0xffF5F5F5),
              appBar: AppBar(
                  title: Text('Library'), backgroundColor: Colors.purple),
              body: ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                  Container(
                    height: cardheight,
                    child: GameRowList(list: featured, title: 'Featured'),
                  ),
                  /*SizedBox(height: size),
                  Container(
                    height: cardheight,
                    child: GameRowList(list: coming_soon, title: 'Coming Soon'),
                  ),*/
                  SizedBox(height: size),
                  Container(
                    height: cardheight,
                    child: GameRowList(list: top_sellers, title: 'Top Sellers'),
                  ),
                  SizedBox(height: size),
                  Container(
                    height: cardheight,
                    child: GameRowList(list: specials, title: 'Specials'),
                  ),
                  /*SizedBox(height: size),
                  Container(
                    height: cardheight,
                    child:
                        GameRowList(list: new_releases, title: 'New Releases'),
                  ),*/
                ],
              ));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
