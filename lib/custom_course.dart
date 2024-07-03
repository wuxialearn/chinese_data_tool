import 'package:chinese_data_tool/search_word.dart';
import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/material.dart';

import 'home_hsk.dart';

class CustomCourse extends StatefulWidget {
  const CustomCourse({super.key});

  @override
  State<CustomCourse> createState() => _CustomCourseState();
}

class _CustomCourseState extends State<CustomCourse> {
  late Future<List<Map<String, dynamic>>> unitList;
  String courseName = "wuxia";
  @override
  void initState() {
    super.initState();
    unitList = getUnitNum();
  }

  Future<List<Map<String, dynamic>>> getUnitNum() async {
    final data =
        await SQLHelper.getCourseUnitsWithCompletionBoolean(courseName);
    return data;
  }

  void update() {
    setState(() {
      unitList = getUnitNum();
    });
  }

  List<Widget> createGridItems(List<Map<String, dynamic>> hskList) {
    return [
      SliverToBoxAdapter(
        child: Row(
          children: [
            TextButton(
                onPressed: () {
                  addWordDialog();
                },
                child: const Text("Add words to course"))
          ],
        ),
      ),
      SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100.0,
          mainAxisSpacing: 30.0,
          crossAxisSpacing: 30.0,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return GridItem(
              index: index,
              hskList: hskList,
              update: update,
              courseName: courseName,
            );
          },
          childCount: hskList.length,
        ),
      )
    ];
  }

  void addWordDialog() {
    final GlobalKey<FormState> newCourseWord = GlobalKey<FormState>();
    late String hanzi;
    late String translation;
    late String pinyin;
    late int unit;
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: newCourseWord,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      onSaved: (String? value) {
                        hanzi = value!;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter Hanzi',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onSaved: (String? value) {
                        translation = value!;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter Translation',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onSaved: (String? value) {
                        pinyin = value!;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter Pinyin',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (String? value) {
                        unit = int.parse(value!);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter Unit',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (newCourseWord.currentState!.validate()) {
                            if (newCourseWord.currentState!.validate()) {
                              newCourseWord.currentState!.save();
                              SQLHelper.addWordToCustomCourse(
                                  course: courseName,
                                  hanzi: hanzi,
                                  pinyin: pinyin,
                                  translations0: translation,
                                  unit: unit);
                              update();
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: unitList,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> unitList = snapshot.data!;
            final List<Widget> gridItems = createGridItems(unitList);
            return CourseView(
              unitList: unitList,
              gridItems: gridItems,
              update: update,
              courseName: courseName,
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
