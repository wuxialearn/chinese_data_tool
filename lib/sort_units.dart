import 'package:chinese_data_tool/hsk_listview.dart';
import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/material.dart';

class SortUnits extends StatefulWidget {
  const SortUnits({super.key});

  @override
  State<SortUnits> createState() => _SortUnitsState();
}

class _SortUnitsState extends State<SortUnits> {
  Future<List<Map<String, dynamic>>> hskFuture =
      SQLHelper.getNewWords(courseName: 'hsk');
  @override
  Widget build(BuildContext context) {
    void update() {
      setState(() {
        hskFuture =
            SQLHelper.getNewWords(sortBy: "Random()", courseName: 'hsk');
      });
    }

    return Scaffold(body: _MissingWords(update: update, hskFuture: hskFuture));
  }
}

class _MissingWords extends StatelessWidget {
  final Function update;
  final Future<List<Map<String, dynamic>>> hskFuture;
  const _MissingWords({required this.update, required this.hskFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: hskFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>>? hskList = snapshot.data;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("${hskList!.length} unsorted words in hsk 1-4"),
                        TextButton(
                            onPressed: () {
                              update();
                            },
                            child: const Text("Randomize"))
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        primary: true,
                        physics: const ScrollPhysics(),
                        padding: const EdgeInsets.only(left: 2.0),
                        scrollDirection: Axis.vertical,
                        itemCount: hskList.length,
                        itemBuilder: (context, index) {
                          return HskListviewItem(
                              hskList: hskList[index],
                              showTranslation: true,
                              separator: true,
                              onClick: (i) {},
                              showNumber: true,
                              index: index,
                              useGivenIndex: true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
