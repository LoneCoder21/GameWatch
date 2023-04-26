import 'package:basic_flutter_app/DataBase.dart';
import 'package:basic_flutter_app/GameCard.dart';
import 'package:basic_flutter_app/GameView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SavedView extends StatelessWidget {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SavedPage();
  }
}

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  final DbManager dbManager = DbManager();
  late Future<List<GameCard>>? savedgames;

  @override
  void initState() {
    super.initState();
    savedgames = dbManager.getSavedList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        appBar: AppBar(
          title: Text('Bookmarked Games'),
          backgroundColor: Colors.purple,
        ),
        body: FutureBuilder<List<GameCard>>(
          future: savedgames,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<GameCard> gs = snapshot.data!;
              return ListView.separated(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(5),
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                        child: Column(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  GameView(gameid: gs[index].gameId),
                            ),
                          )
                              .then((value) {
                            setState(() {
                              savedgames = dbManager.getSavedList();
                            });
                          });

                          print('Out');
                        },
                        child: CachedNetworkImage(
                          imageUrl: gs[index].headerImg,
                        ),
                      ),
                      Text(
                        gs[index].name,
                      ),
                    ]));
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: gs.length);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
