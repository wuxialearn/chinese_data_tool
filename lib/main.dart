import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemStatusBarContrastEnforced: false,
    statusBarIconBrightness: Brightness.dark,
  ));
  //test();
  runApp(const MyApp());
}

void test() async {
  var data = await SQLHelper.getUnitWithMissingSentences(40);
  print(data);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const CupertinoScrollBehavior(),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Scaffold(
        body: MyHomePage(tab: 0),
      ),
      //home: const MyStatefulWidget(),
    );
  }
}
