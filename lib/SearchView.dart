import 'dart:convert';

import 'package:gamewatch/DataBase.dart';
import 'package:gamewatch/Game.dart';
import 'package:gamewatch/GameCard.dart';
import 'package:gamewatch/GameView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gamewatch/GameCache.dart';

import 'GameInfo.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchPage();
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class GameManager {
  List<Game> parseGames(String responseBody) {
    final jsonData = json.decode(responseBody);
    List<Game> model = [];
    for (Map<String, dynamic> i in jsonData['applist']['apps']) {
      int id = i['appid'];
      model.add(Game(gameId: id, name: i['name']));
    }
    model.sort((a, b) => a.name.length.compareTo(b.name.length));
    return model;
  }

  Future<List<Game>> fetchGames(http.Client client) async {
    final response = await client.get(
        Uri.parse('http://api.steampowered.com/ISteamApps/GetAppList/v0002/'));

    if (response.statusCode == 200) {
      return compute(parseGames, response.body);
    }
    return [];
  }

  Future<List<GameCard>> fetchQueryGames(
      Future<List<Game>> gamelist, http.Client client, String text,
      [int amount = 10]) async {
    List<GameCard> gamecards = [];
    for (final game in await gamelist) {
      if (gamecards.length >= amount) break;
      if (!game.name.toLowerCase().startsWith(text.toLowerCase())) continue;
      int id = game.gameId;

      List<String> types = ["game", "dlc", "demo"];
      GameInfo? info = await getGame(id);
      if (info == null || !types.contains(info.type) || info.unsafecontent) {
        continue;
      }
      gamecards.add(GameCard(gameId: id, name: game.name, headerImg: info.img));
    }
    return gamecards;
  }
}

class SearchPageState extends State<SearchPage> {
  final DbManager dbManager = DbManager();
  final controller = TextEditingController();
  final focusnode = FocusNode();
  final gm = GameManager();
  final client = http.Client();

  late Future<List<Game>> games;
  late Future<List<GameCard>>? searched_games;

  void handleText() {}

  Future<List<GameCard>> initGames() async {
    return [];
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(handleText);
    searched_games = initGames();
    games = gm.fetchGames(client);
  }

  @override
  void dispose() {
    controller.dispose();
    focusnode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      appBar:
          AppBar(title: const Text('Search'), backgroundColor: Colors.purple),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.all(10.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter game',
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        controller.clear();
                      },
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          setState(() {
                            //searched_games = dbManager.getGameCardList(controller.text, 15, 10);
                            searched_games = gm.fetchQueryGames(
                                games, client, controller.text);
                          });
                          //dbManager.getGameCardList(controller.text, 15, 10).then((value) {});
                        }
                        focusnode.unfocus();
                      },
                    ),
                  ),
                  controller: controller,
                  focusNode: focusnode,
                  onSubmitted: (String text) async {
                    if (text.isNotEmpty) {
                      setState(() {
                        //searched_games = dbManager.getGameCardList(controller.text, 15, 10);
                        searched_games =
                            gm.fetchQueryGames(games, client, text);
                      });
                      //dbManager.getGameCardList(text, 10, 5).then((value) {});
                    }
                  },
                )),
            Expanded(
                child: FutureBuilder<List<GameCard>>(
              future: searched_games,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState != ConnectionState.waiting) {
                  List<GameCard> gs = snapshot.data!;

                  return ListView.separated(
                    itemCount: gs.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    GameView(gameid: gs[index].gameId),
                              ),
                            );
                          },
                          leading: SizedBox(
                            width: 125,
                            child: CachedNetworkImage(
                                imageUrl: gs[index].headerImg,
                                fit: BoxFit.fill),
                          ),
                          title: Text(gs[index].name));
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            )),
          ],
        ),
      ),
    );
  }
}
