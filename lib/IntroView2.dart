import 'package:flutter/material.dart';
import 'package:basic_flutter_app/IntroView1.dart';
import 'package:basic_flutter_app/IntroView2.dart';
import 'package:basic_flutter_app/IntroView3.dart';

class IntroView2 extends StatelessWidget {
  const IntroView2({super.key});

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
              child: const Text(
                'See the latest games',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bookmark your games',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'View game information',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              '2/3',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 25),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Previous'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const IntroView3(),
                    ),
                  );
                },
                child: Text('Next'),
              )
            ]),
          ],
        ),
      ),
    );
  }
}
