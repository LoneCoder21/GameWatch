import 'package:gamewatch/IntroView2.dart';
import 'package:flutter/material.dart';
import 'package:gamewatch/MainBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroView3 extends StatelessWidget {
  const IntroView3({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage3();
  }
}

class HomePage3 extends StatefulWidget {
  const HomePage3({super.key});

  @override
  State<HomePage3> createState() => _HomePageState3();
}

class _HomePageState3 extends State<HomePage3> {
  bool _new = true;

  Future<void> _setStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _new = false;
      prefs.setBool('new', false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GameWatch'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset('assets/game_watch_icon_512.png', width: 100),
            ),
            const SizedBox(height: 30),
            const Text(
              'Let\'s begin!',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            const SizedBox(height: 30),
            const Text(
              '3/3',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 25),
            ),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const IntroView2(),
                    ),
                  );
                },
                child: Text('Previous'),
              ),
              TextButton(
                onPressed: () {
                  _setStatus();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainBar(),
                    ),
                  );
                },
                child: Text('Begin!'),
              )
            ]),
          ],
        ),
      ),
    );
  }
}
