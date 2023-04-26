import 'package:basic_flutter_app/LibraryView.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter_app/IntroView1.dart';
import 'package:basic_flutter_app/IntroView2.dart';
import 'package:basic_flutter_app/IntroView3.dart';
import 'package:basic_flutter_app/SearchView.dart';
import 'package:basic_flutter_app/MainBar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const IntroView1());
}
