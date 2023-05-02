import 'package:flutter/material.dart';
import 'package:gamewatch/MainBar.dart';
import 'package:gamewatch/IntroView2.dart';

import 'package:shared_preferences/shared_preferences.dart';

class IntroView1 extends StatelessWidget {
  const IntroView1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(title: 'GameWatch'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _new = true;

  Future<void> _loadNewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _new = (prefs.getBool('new') ?? true);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNewStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_new == true) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child:
                    Image.asset('assets/game_watch_icon_512.png', width: 100),
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to GameWatch',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 30),
              const Text(
                '1/3',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 25),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const IntroView2(),
                    ),
                  );
                },
                child: Text('Next'),
              )
            ],
          ),
        ),
      );
    } else {
      return MainBar();
    }
  }
}
