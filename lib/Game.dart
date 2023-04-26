class Game {
  final int gameId;
  final String name;

  const Game({
    required this.gameId,
    required this.name,
  });

  Map<String, Object> toMap() {
    return {'id': gameId, 'name': name};
  }

  static Game fromMap(Map<String, dynamic> item) {
    return Game(gameId: item['appid'], name: item['name']);
  }
}
