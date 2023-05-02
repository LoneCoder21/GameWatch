import 'package:gamewatch/DataBase.dart';
import 'package:flutter/material.dart';
import 'package:gamewatch/GameView.dart';
import 'package:gamewatch/GameCard.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GameRowList extends StatelessWidget {
  final List<GameCard> list;
  final String title;
  final DbManager dbManager = new DbManager();

  GameRowList({
    required this.list,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.only(bottom: 10)),
            Expanded(
              child: Center(
                  child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(0),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  GameCard card = list[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GameView(
                                  gameid: card.gameId,
                                ),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: card.headerImg,
                          ),
                        ),
                      ),
                      Container(
                        width: 271,
                        alignment: Alignment.center,
                        child: Text(card.name,
                            overflow: TextOverflow.clip,
                            softWrap: false,
                            style: TextStyle(fontWeight: FontWeight.w400)),
                      ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(
                  endIndent: 10,
                ),
              )),
            ),
          ],
        ));
  }
}
