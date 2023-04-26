import 'package:basic_flutter_app/Game.dart';

class GameInfo {
  final int gameId;
  final String name;
  final String img;
  final String desc;
  final String devs, pubs;
  final String? price;
  final String? website;
  final bool free;
  final int? score;
  final String? criticsite;
  final String release_date;
  final bool coming_soon;
  final List<String> genres;

  const GameInfo({
    required this.gameId,
    required this.name,
    required this.img,
    required this.desc,
    required this.devs,
    required this.pubs,
    required this.price,
    required this.free,
    required this.score,
    required this.website,
    required this.criticsite,
    required this.release_date,
    required this.coming_soon,
    required this.genres,
  });

  factory GameInfo.fromMap(Map<String, dynamic> json) {
    int id = json['steam_appid'];
    String name = json['name'];
    String img = json['header_image'];
    String desc = json['short_description'];
    String devs = "Unknown", pubs = "Unknown";
    if (json['developers'] != null && json['developers'][0] != null) {
      devs = json['developers'][0];
    }
    if (json['publishers'] != null && json['publishers'][0] != null) {
      pubs = json['publishers'][0];
    }
    String? price = null;
    bool free = json['is_free'] == true;
    if (json['price_overview'] != null &&
        json['price_overview']['final_formatted'] != null) {
      price = json['price_overview']['final_formatted'];
    }
    int? score = null;
    String? criticsite = null;
    if (json['metacritic'] != null && json['metacritic']['score'] != null) {
      score = json['metacritic']['score'];
      if (json['metacritic']['url'] != null) {
        criticsite = json['metacritic']['url'];
      }
    }
    bool coming_soon = json['release_date']['coming_soon'];
    String releasedate = json['release_date']['date'];
    String? website = null;
    if (json['website'] != null) {
      website = json['website'];
    }
    List<String> genres = [];
    if (json['genres'] != null) {
      for (Map<String, dynamic> m in json['genres']) {
        genres.add(m['description']);
      }
    } else {
      genres.add('Tagless');
    }
    return GameInfo(
        gameId: id,
        name: name,
        img: img,
        desc: desc,
        devs: devs,
        pubs: pubs,
        price: price,
        free: free,
        score: score,
        website: website,
        criticsite: criticsite,
        release_date: releasedate,
        coming_soon: coming_soon,
        genres: genres);
  }
}
