import 'GameInfo.dart';

class GameCard {
  final int gameId;
  final String name;
  final String headerImg;

  const GameCard({
    required this.gameId,
    required this.name,
    required this.headerImg,
  });

  factory GameCard.fromMap(Map<String, dynamic> json) {
    return GameCard(
      gameId: json['id'],
      name: json['name'],
      headerImg: json['header_image'],
    );
  }

  factory GameCard.fromInfo(GameInfo info) {
    return GameCard(
      gameId: info.gameId,
      name: info.name,
      headerImg: info.img,
    );
  }

  Map<String, Object> toMap() {
    return {'id': gameId, 'name': name, "image": headerImg};
  }
}
