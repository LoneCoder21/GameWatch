import 'package:flutter/material.dart';
import 'package:gamewatch/IntroView1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const IntroView1());
}
