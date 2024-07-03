import 'package:chinese_data_tool/pinyin_formater.dart';
import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchWord extends StatefulWidget {
  final String courseName;
  const SearchWord({
    super.key,
    required this.courseName,
  });

  @override
  State<SearchWord> createState() => _SearchWordState();
}

class _SearchWordState extends State<SearchWord> {
  Future<List<Map<String, dynamic>>> hskFuture =
      Future<List<Map<String, dynamic>>>.value([]);
  Future<List<Map<String, dynamic>>> unitsFuture =
      SQLHelper.getCourseUnits("hsk");
  TextEditingController textController = TextEditingController(text: '');
  String prev = '';
  late int? unitNumber;

  void updateSearchWord() {
    String newText = textController.text;
    if (newText != '' && newText != prev) {
      setState(() {
        hskFuture = SQLHelper.findWord(textController.text);
      });
    }
    prev = newText;
  }

  @override
  void initState() {
    textController.addListener(updateSearchWord);
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void updateUnitNumber(int newUnitNumber) {
    unitNumber = newUnitNumber;
  }

  void addSelectedWordToUnit({
    required String hanzi,
    required String pinyin,
    required String translations0,
  }) {
    setState(() {
      SQLHelper.addWordToCustomCourse(
        course: widget.courseName,
        hanzi: hanzi,
        pinyin: pinyin,
        translations0: translations0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> searchWordKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text("Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CupertinoSearchTextField(
              controller: textController,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: unitsFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> units = snapshot.data!;
                  return ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 100, maxWidth: 500),
                    child: _FoundWords(
                      updateSearchWord: updateSearchWord,
                      addSelectedWordToUnit: addSelectedWordToUnit,
                      hskFuture: hskFuture,
                      searchWordKey: searchWordKey,
                      units: units,
                      updateUnitNumber: updateUnitNumber,
                      textController: textController,
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundWords extends StatelessWidget {
  final Function updateSearchWord;
  final Future<List<Map<String, dynamic>>> hskFuture;
  final Function addSelectedWordToUnit;
  final GlobalKey<FormState> searchWordKey;
  final List<Map<String, dynamic>> units;
  final void Function(int newUnitNumber) updateUnitNumber;
  final TextEditingController textController;
  const _FoundWords({
    required this.updateSearchWord,
    required this.hskFuture,
    required this.addSelectedWordToUnit,
    required this.searchWordKey,
    required this.units,
    required this.updateUnitNumber,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: hskFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>>? hskList = snapshot.data;
            if (hskList!.isEmpty) {
              return const Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "no results",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              );
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Center(child: Text("found ${hskList.length} results")),
                        const SizedBox(
                          height: 15,
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: const ScrollPhysics(),
                            padding: const EdgeInsets.only(left: 2.0),
                            scrollDirection: Axis.vertical,
                            itemCount: hskList.length,
                            itemBuilder: (context, index) {
                              return _FoundWordsItem(
                                  index: index,
                                  hskList: hskList[index],
                                  onClick: addSelectedWordToUnit);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class _FoundWordsItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> hskList;
  final Function onClick;
  const _FoundWordsItem({
    required this.index,
    required this.hskList,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    print(hskList);
    String sideInfo = '';
    if (hskList["hsk"] != null) {
      sideInfo += 'hsk ${hskList["hsk"].toString()}';
    } else if (hskList["course"] != null) {
      sideInfo += hskList["course"];
    }
    if (hskList["unit"] != null) {
      sideInfo += " unit ${hskList["unit"]}";
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Text((index + 1).toString()),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toneNumberToPiyin(hskList["pinyin"]),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              hskList["hanzi"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ]),
                      Text(
                        hskList["translations"].join("; "),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999EA3),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    sideInfo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
