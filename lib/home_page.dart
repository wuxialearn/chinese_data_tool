import 'package:chinese_data_tool/sort_units.dart';
import 'package:flutter/material.dart';
import 'custom_course.dart';
import 'literal_definition_sorter.dart';
import 'search_word.dart';
import 'home_hsk.dart';

class MyHomePage extends StatefulWidget {
  final int tab;
  const MyHomePage({super.key, required this.tab});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  onTappedTab(int index) {
    setState(() {
      tabsIndex = index;
    });
  }

  int tabsIndex = 2;
  late List<Widget> tabList = <Widget>[];
  @override
  void initState() {
    super.initState();
    tabsIndex = widget.tab;
    tabList = <Widget>[
      const SafeArea(child: HomeHsk()),
      const SafeArea(child: SortUnits()),
      const SearchWord(
        courseName: 'wuxia',
      ),
      const SafeArea(child: CustomCourse()),
      //const LiteralDefinitionSorter(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(child: tabList[tabsIndex]),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: tabsIndex,
        onTap: onTappedTab,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.query_stats_sharp), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
          BottomNavigationBarItem(icon: Icon(Icons.create), label: "custom"),
          //BottomNavigationBarItem(icon: Icon(Icons.sort), label: "literals"),
        ],
      ),
    );
  }
}
