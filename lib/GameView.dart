import 'dart:async';
import 'dart:convert';

import 'package:basic_flutter_app/DataBase.dart';
import 'package:basic_flutter_app/GameCard.dart';
import 'package:basic_flutter_app/GameInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GameDetails {
  Future<GameInfo?> fetchGameByAppID(int appid) async {
    String key = dotenv.env['KEY']!;

    final response = await http.get(Uri.parse(
        'https://store.steampowered.com/api/appdetails?key=${key}&appids=${appid}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['${appid}']['success'] == 'false') {
        return null;
      }
      return GameInfo.fromMap(data['${appid}']['data']);
    }

    return null;
  }
}

class GameView extends StatelessWidget {
  const GameView({required this.gameid, super.key});
  final int gameid;
  @override
  Widget build(BuildContext context) {
    return GamePage(
      gameid: gameid,
    );
  }
}

class GamePage extends StatefulWidget {
  final int gameid;

  const GamePage({super.key, required this.gameid});

  @override
  State<GamePage> createState() => GamePageState(gameid: gameid);
}

class GamePageState extends State<GamePage> {
  final DbManager dbManager = DbManager();
  final GameDetails details = GameDetails();
  final int gameid;
  late Future<GameInfo?> info;
  late Future<bool> bookmarked;

  GamePageState({required this.gameid});

  Future<bool> initBookmark() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    print(gameid);
    info = details.fetchGameByAppID(gameid);
    resetBookmark();
  }

  void resetBookmark() {
    bookmarked = initBookmark();
    info.then((gameinfo) {
      if (gameinfo != null) {
        bookmarked = dbManager.checkIfGameExists(gameinfo.gameId);
      }
    });
  }

  Color? getCriticColor(double t) {
    final startColor = const Color(0xffD2042D);
    final endColor = const Color(0xff32CD32);
    final double middle = 0.5;
    if (t < middle) {
      return Color.lerp(startColor, Colors.orange, t / middle);
    } else {
      return Color.lerp(Colors.orange, endColor, (t - middle) / middle);
    }
  }

  Future openUrl(String? url) async {
    if (url == null) return;
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<bool> urlf(String? url) async {
    if (url == null) return false;
    Uri uri = Uri.parse(url);
    return await (canLaunchUrl(uri));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        appBar: AppBar(
          leading: FutureBuilder<List<GameInfo?>>(
              future: Future.wait([info]),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data![0] != null) {
                  GameInfo info = snapshot.data![0]!;
                  return FutureBuilder<bool>(
                      future: bookmarked,
                      builder: (iconctx, iconsnap) {
                        if (!iconsnap.hasData || iconsnap.hasError) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        bool is_bookmarked = iconsnap.data!;
                        return BackButton(
                          onPressed: () {
                            if (is_bookmarked) {
                              GameCard g = GameCard(
                                  gameId: info.gameId,
                                  name: info.name,
                                  headerImg: info.img);
                              dbManager.saveGame(g);
                            }
                            Navigator.of(context).pop();
                          },
                        );
                      });
                }
                return const Center(child: CircularProgressIndicator());
              }),
          title: Text('GameView'),
          backgroundColor: Colors.purple,
        ),
        body: Container(
            child: FutureBuilder<List<GameInfo?>>(
          future: Future.wait([info]),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data![0] != null) {
              GameInfo info = snapshot.data![0]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            info.name,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17.0),
                          ),
                        ),
                        FutureBuilder<bool>(
                            future: bookmarked,
                            builder: (iconctx, iconsnap) {
                              if (!iconsnap.hasData || iconsnap.hasError) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              bool is_bookmarked = iconsnap.data!;
                              return IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (is_bookmarked) {
                                      dbManager.deleteGame(info.gameId);
                                    } else {
                                      dbManager.saveGame(GameCard(
                                          gameId: info.gameId,
                                          name: info.name,
                                          headerImg: info.img));
                                    }
                                    resetBookmark();
                                  });
                                },
                                icon: is_bookmarked
                                    ? Icon(
                                        Icons.star,
                                        color: Color(0xffFFAA33),
                                      )
                                    : Icon(Icons.star),
                              );
                            }),
                      ],
                    ),
                  ),
                  Image.network(info.img),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                      height: 30,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: info.genres.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Color(0xffFF5F1F),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20), // <-- Radius
                              ),
                            ),
                            onPressed: null,
                            child: Text('${info.genres[index]}'),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          endIndent: 10,
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Text(
                        info.desc,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      )),
                  Center(
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                          TextSpan(
                              text: 'Developers: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${info.devs}', style: TextStyle()),
                        ])),
                  ),
                  Center(
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                          TextSpan(
                              text: 'Publishers: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${info.pubs}', style: TextStyle()),
                        ])),
                  ),
                  Center(
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                          TextSpan(
                              text: 'Release Date: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: '${info.release_date}', style: TextStyle()),
                        ])),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (info.price != null && !info.free)
                        Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      disabledForegroundColor: Colors.white,
                                      backgroundColor: Color(0xffA020F0),
                                      disabledBackgroundColor:
                                          Color(0xffA020F0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            1), // <-- Radius
                                      ),
                                      elevation: 3),
                                  onPressed: info.website != null
                                      ? () {
                                          print(info.website);
                                          setState(() {
                                            openUrl(info.website);
                                          });
                                        }
                                      : null,
                                  child: Text(
                                    info.price!,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                              ),
                              Text(
                                'Price',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ]),
                      if (info.free)
                        Column(children: [
                          Container(
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  backgroundColor: Color(0xffA020F0),
                                  disabledBackgroundColor: Color(0xffA020F0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(1), // <-- Radius
                                  ),
                                  elevation: 3),
                              onPressed: info.website != null
                                  ? () {
                                      print(info.website);
                                      setState(() {
                                        openUrl(info.website);
                                      });
                                    }
                                  : null,
                              child: Text(
                                'Free',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                          Text(
                            'Price',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ]),
                      if ((info.free || info.price != null) &&
                          info.score != null)
                        SizedBox(width: 30),
                      if (info.score != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  backgroundColor:
                                      getCriticColor((info.score! / 100.0)),
                                  disabledBackgroundColor:
                                      getCriticColor((info.score! / 100.0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  elevation: 3),
                              onPressed: info.criticsite != null
                                  ? () {
                                      setState(() {
                                        openUrl(info.criticsite);
                                      });
                                    }
                                  : null,
                              child: Text(
                                '${info.score!}',
                                style: TextStyle(fontSize: 50),
                              ),
                            ),
                            Text(
                              'Critic Score',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                  //eleve button
                  if (info.coming_soon)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.greenAccent,
                          disabledBackgroundColor: Colors.greenAccent,
                          disabledForegroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5), // <-- Radius
                          ),
                        ),
                        onPressed: null,
                        child: Text(
                          'Coming soon!',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        )));
  }
}
