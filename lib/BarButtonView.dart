import 'package:flutter/material.dart';

class BarButton extends StatelessWidget {
  const BarButton({
    required this.icon,
    required this.name,
    required this.transition,
    super.key,
  });

  final Icon icon;
  final String name;
  final Widget transition;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => this.transition,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            this.icon,
            const SizedBox(height: 10),
            Text(
              this.name,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
