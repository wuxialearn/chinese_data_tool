import 'package:chinese_data_tool/hsk_listview.dart';
import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/material.dart';

class LiteralDefinitionSorter extends StatefulWidget {
  const LiteralDefinitionSorter({super.key});

  @override
  State<LiteralDefinitionSorter> createState() =>
      _LiteralDefinitionSorterState();
}

class _LiteralDefinitionSorterState extends State<LiteralDefinitionSorter> {
  var literalDefinitions = SQLHelper.getLiteralDefinitions();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: literalDefinitions,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>>? definitions = snapshot.data;
            return Column(
              children: [
                const Text("we are building!!!"),
                Expanded(
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    itemCount: definitions!.length,
                    itemBuilder: (context, index) {
                      var row = definitions[index];
                      String text = row["char_one"];
                      if (row["char_two"] != null) {
                        text += " + ${row["char_two"]}";
                      }
                      if (row["char_three"] != null) {
                        text += " + ${row["char_three"]}";
                      }
                      if (row["char_four"] != null) {
                        text += " + ${row["char_four"]}";
                      }
                      return LiteralTranslationItem(
                        literalDefinitions: definitions[index],
                        onClick: () {
                          SQLHelper.setLiteralTranslation(
                              row["id"], row["word_id"]);
                          setState(() {
                            literalDefinitions =
                                SQLHelper.getLiteralDefinitions();
                          });
                        },
                        text: text,
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class LiteralTranslationItem extends StatelessWidget {
  final Map<String, dynamic> literalDefinitions;
  final Function onClick;
  final String text;
  const LiteralTranslationItem({
    Key? key,
    required this.literalDefinitions,
    required this.onClick,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Text(literalDefinitions["id"].toString()),
            ),
            GestureDetector(
              onTap: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                            child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  onClick();
                                  Navigator.pop(context);
                                },
                                child: const Text("Add word")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"))
                          ],
                        )));
              },
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(children: [
                        /*
                            Text(
                              literalDefinitions["pinyin"],
                              style: const TextStyle(fontSize: 14),
                            ),
                             */
                        Text(
                          literalDefinitions["hanzi"],
                          style: const TextStyle(fontSize: 25),
                        ),
                      ]),
                      Text(
                        literalDefinitions["translation"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999EA3),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Column(
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          literalDefinitions["translation"],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.transparent),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
