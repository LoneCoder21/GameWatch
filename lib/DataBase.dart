import 'dart:async';
import 'dart:convert';
import 'package:basic_flutter_app/GameCard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:basic_flutter_app/Game.dart';
import 'package:http/http.dart' as http;

class DbManager {
  late Database _database;

  Future openDb() async {
    _database = await openDatabase(join(await getDatabasesPath(), "ss.db"),
        version: 1, onCreate: (Database db, int version) async {
      //await db.execute("CREATE TABLE games(id INTEGER PRIMARY KEY autoincrement, name TEXT)");
      await db.execute(
          "CREATE TABLE saved(id INTEGER PRIMARY KEY autoincrement, name TEXT, image TEXT, timestamp INTEGER)");
    });
    return _database;
  }

  Future saveGame(GameCard card) async {
    await openDb();
    await _database.transaction((txn) async {
      final map = card.toMap();
      map['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      txn.insert('saved', map, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future deleteGame(int id) async {
    await openDb();
    await _database.transaction((txn) async {
      txn.delete(
        'saved',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future insertGames(List<Game> games) async {
    await openDb();
    await _database.transaction((txn) async {
      final batch = txn.batch();
      for (Game game in games) {
        txn.insert('games', game.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true, continueOnError: true);
    });
  }

  Future<List<Game>> getGameList(String search, int amount) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query(
      'games',
      where: "name LIKE \'${search}%\'",
      limit: amount,
    );
    return List.generate(maps.length, (i) {
      return Game(gameId: maps[i]['id'], name: maps[i]['name']);
    });
  }

  Future<List<GameCard>> getGameCardList(
      String search, int amount, int hardamount) async {
    final gamelist = await getGameList(search, amount);
    List<GameCard> gamecards = [];
    String key = dotenv.env['KEY']!;
    http.Client client = http.Client();
    for (final game in gamelist) {
      if (gamecards.length >= hardamount) break;
      final response = await client.get(Uri.parse(
          'https://store.steampowered.com/api/appdetails?key=${key}&appids=${game.gameId}'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<String> types = ["game", "dlc", "demo"];
        if (jsonData['${game.gameId}']['success'].toString() == "false" ||
            !types.contains(
                jsonData['${game.gameId}']['data']['type'].toString())) {
          continue;
        }
        String img = jsonData['${game.gameId}']['data']['header_image'];
        gamecards.add(
            GameCard(gameId: game.gameId, name: game.name, headerImg: img));
      }
    }
    return gamecards;
  }

  Future<List<GameCard>> getSavedList() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.query('saved', orderBy: "timestamp DESC");

    return List.generate(maps.length, (i) {
      return GameCard(
          gameId: maps[i]['id'],
          name: maps[i]['name'],
          headerImg: maps[i]['image']);
    });
  }

  Future<bool> checkIfGameExists(int appid) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query(
      'saved',
      where: "id = ${appid}",
    );
    return maps.length == 1;
  }
}
