import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gamewatch/GameInfo.dart';
import 'package:http/http.dart' as http;

Map<int, GameInfo?> gameCache = {};
http.Client client = http.Client();

Future<GameInfo?> fetchGameByAppID(int appid) async {
  String key = dotenv.env['KEY']!;

  final response = await client.get(Uri.parse(
      'https://store.steampowered.com/api/appdetails?key=${key}&appids=${appid}'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['${appid}']['success'] == false) {
      return null;
    }
    return GameInfo.fromMap(data['${appid}']['data']);
  }
  return null;
}

Future<GameInfo?> getGame(int id) async {
  if (gameCache.containsKey(id)) {
    return gameCache[id];
  } else {
    GameInfo? gameInfo = await fetchGameByAppID(id);
    gameCache[id] = gameInfo;
    return gameInfo;
  }
}
