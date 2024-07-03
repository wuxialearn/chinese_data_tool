import 'package:chinese_data_tool/sql_helper.dart';
import 'package:chinese_data_tool/unit_view.dart';
import 'package:flutter/material.dart';

class HomeHsk extends StatefulWidget {
  const HomeHsk({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeHsk> createState() => _HomeHskState();
}

class _HomeHskState extends State<HomeHsk> {
  late Future<List<Map<String, dynamic>>> unitNumList;
  String courseName = "hsk";
  @override
  void initState() {
    super.initState();
    unitNumList = getUnitNum();
  }

  Future<List<Map<String, dynamic>>> getUnitNum() async {
    //final data = await SQLHelper.getCourseUnits(courseName);
    final data =
        await SQLHelper.getCourseUnitsWithCompletionBoolean(courseName);
    return data;
  }

  void update() {
    setState(() {
      unitNumList = getUnitNum();
    });
  }

  @override
  Widget build(BuildContext context) {
    return HSKCourseView(
        unitList: unitNumList, update: update, courseName: courseName);
  }
}

class HSKCourseView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> unitList;
  final Function update;
  final String courseName;
  const HSKCourseView({
    Key? key,
    required this.unitList,
    required this.update,
    required this.courseName,
  }) : super(key: key);

  @override
  State<HSKCourseView> createState() => _HSKCourseViewState();
}

class _HSKCourseViewState extends State<HSKCourseView> {
  List<Widget> createGridItems(List<Map<String, dynamic>> hskList) {
    List<Widget> widgets = [];
    List<int> hskListOffset = [];
    List<int> hskListUnitLengths = [];
    for (int i = 0; i < hskList.length; i++) {
      if (i == 0) {
        hskListOffset.add(0);
      } else if (hskList[i]["hsk"] != hskList[i - 1]["hsk"]) {
        hskListUnitLengths.add(i - hskListOffset.last);
        hskListOffset.add(i);
      }
      if (i == hskList.length - 1) {
        //+1 because we are using the i from last of the current unit rather than the first of the next unit
        hskListUnitLengths.add(i - hskListOffset.last + 1);
      }
    }
    for (int i = 0; i < hskListOffset.length; i++) {
      widgets.add(SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        sliver: SliverToBoxAdapter(
          child: Center(
              child: Text(
            "hsk ${i + 2} (${hskListUnitLengths[i]})",
            style: const TextStyle(fontSize: 20),
          )),
        ),
      ));
      widgets.add(
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
                index: index + hskListOffset[i],
                hskList: hskList,
                update: widget.update,
                courseName: widget.courseName,
              );
            },
            childCount: hskListUnitLengths[i],
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.unitList,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final List<Map<String, dynamic>> unitList = snapshot.data!;
            final List<Widget> gridItems = createGridItems(unitList);
            return CourseView(
              unitList: unitList,
              gridItems: gridItems,
              update: widget.update,
              courseName: widget.courseName,
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class CourseView extends StatelessWidget {
  final List<Map<String, dynamic>> unitList;
  final List<Widget> gridItems;
  final Function update;
  final String courseName;
  const CourseView({
    super.key,
    required this.unitList,
    required this.update,
    required this.courseName,
    required this.gridItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const FittedBox(
                            child: FlutterLogo(),
                          ),
                          Text(
                            '$courseName course',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...gridItems,
                SliverToBoxAdapter(
                  child: IconButton(
                      onPressed: () {
                        final GlobalKey<FormState> newUnitKey =
                            GlobalKey<FormState>();
                        late String newName;
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            child: Form(
                              key: newUnitKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      "unit name",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  TextFormField(
                                    onSaved: (String? value) {
                                      newName = value!;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Enter a name',
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (newUnitKey.currentState!
                                            .validate()) {
                                          newUnitKey.currentState!.save();
                                          SQLHelper.createNewUnit(
                                              course: courseName,
                                              name: newName,
                                              hsk: unitList.last['hsk']);
                                          update();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GridItem extends StatelessWidget {
  final int index;
  final List<Map<String, dynamic>> hskList;
  final Function update;
  final String courseName;
  const GridItem(
      {super.key,
      required this.index,
      required this.hskList,
      required this.update,
      required this.courseName});

  @override
  Widget build(BuildContext context) {
    final Color unitColor = hskList[index].containsKey("completed")
        ? hskList[index]["completed"]
            ? Colors.green
            : Colors.blueGrey
        : Colors.blueGrey;
    return GestureDetector(
      onLongPress: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChangeUnitNameForm(
                      hskList: hskList, index: index, update: update),
                  SetHskLevelForm(
                      hskList: hskList, index: index, update: update),
                  SetUnitOrderForm(
                      hskList: hskList, index: index, update: update),
                  SwapUnitForm(hskList: hskList, index: index, update: update),
                  InsertUnitAtIndexForm(
                      pressedIndex: hskList[index]["unit_id"], update: update),
                  MergeUnitsForm(
                      pressedIndex: hskList[index]["unit_id"], update: update),
                  SetVisibilityForm(
                      hskList: hskList, index: index, update: update),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: unitColor, width: 3)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("id ${hskList[index]["unit_id"].toString()}"),
                    Text("order ${hskList[index]["unit_order"].toString()}"),
                  ],
                ),
              ),
            ),
            Text(hskList[index]["quantity"].toString()),
            TextButton(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitView(
                        unit: hskList[index]["unit_id"],
                        name: hskList[index]["unit_name"],
                        courseName: courseName,
                        updateHomeHsk: update),
                  ),
                );
              },
              child: Text(
                hskList[index]["unit_name"],
                style: TextStyle(color: unitColor, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//forms

class ChangeUnitNameForm extends StatefulWidget {
  const ChangeUnitNameForm(
      {super.key,
      required this.hskList,
      required this.index,
      required this.update});
  final List<Map<String, dynamic>> hskList;
  final int index;
  final Function update;

  @override
  State<ChangeUnitNameForm> createState() => _ChangeUnitNameFormState();
}

class _ChangeUnitNameFormState extends State<ChangeUnitNameForm> {
  late String newName;
  final GlobalKey<FormState> unitNameKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String pressedName = widget.hskList[widget.index]["unit_name"];
    return Form(
      key: unitNameKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Change unit name",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            onSaved: (String? value) {
              newName = value!;
            },
            initialValue: pressedName,
            decoration: const InputDecoration(
              hintText: 'Enter a new name',
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
                if (unitNameKey.currentState!.validate()) {
                  unitNameKey.currentState!.save();
                  int id = widget.hskList[widget.index]["unit_id"];
                  SQLHelper.updateUnitName(id: id, newName: newName);
                  widget.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class SetHskLevelForm extends StatefulWidget {
  const SetHskLevelForm(
      {super.key,
      required this.hskList,
      required this.index,
      required this.update});
  final List<Map<String, dynamic>> hskList;
  final int index;
  final Function update;

  @override
  State<SetHskLevelForm> createState() => _SetHskLevelFormState();
}

class _SetHskLevelFormState extends State<SetHskLevelForm> {
  final GlobalKey<FormState> unitHskLevel = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final String currentHskLevel = widget.hskList[widget.index]["hsk"] != null
        ? widget.hskList[widget.index]["hsk"].toString()
        : "";
    late int hskLevel;
    final int pressedIndex = widget.hskList[widget.index]["unit_id"];
    return Form(
      key: unitHskLevel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "set hsk Level",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: currentHskLevel,
            onSaved: (String? value) {
              hskLevel = int.parse(value!);
            },
            decoration: const InputDecoration(
              hintText: 'Enter a number',
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
                if (unitHskLevel.currentState!.validate()) {
                  unitHskLevel.currentState!.save();
                  SQLHelper.setUnitHskLevel(unit: pressedIndex, hsk: hskLevel);
                  widget.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class SetUnitOrderForm extends StatefulWidget {
  const SetUnitOrderForm(
      {super.key,
      required this.hskList,
      required this.index,
      required this.update});
  final List<Map<String, dynamic>> hskList;
  final int index;
  final Function update;

  @override
  State<SetUnitOrderForm> createState() => _SetUnitOrderFormState();
}

class _SetUnitOrderFormState extends State<SetUnitOrderForm> {
  final GlobalKey<FormState> unitHskLevel = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final String currentUnitOrder =
        widget.hskList[widget.index]["unit_order"] != null
            ? widget.hskList[widget.index]["unit_order"].toString()
            : "";
    late int newUnitOrder;
    final int pressedIndex = widget.hskList[widget.index]["unit_id"];
    return Form(
      key: unitHskLevel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "set unit order",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: currentUnitOrder,
            onSaved: (String? value) {
              newUnitOrder = int.parse(value!);
            },
            decoration: const InputDecoration(
              hintText: 'Enter a number',
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
                if (unitHskLevel.currentState!.validate()) {
                  unitHskLevel.currentState!.save();
                  SQLHelper.setUnitOrder(
                      unit: pressedIndex, order: newUnitOrder);
                  widget.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class SwapUnitForm extends StatefulWidget {
  const SwapUnitForm(
      {super.key,
      required this.hskList,
      required this.index,
      required this.update});
  final List<Map<String, dynamic>> hskList;
  final int index;
  final Function update;

  @override
  State<SwapUnitForm> createState() => _SwapUnitFormState();
}

class _SwapUnitFormState extends State<SwapUnitForm> {
  final GlobalKey<FormState> unitFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String pressedName = widget.hskList[widget.index]["unit_name"];
    late int swapIndex;
    final int pressedIndex = widget.hskList[widget.index]["unit_id"];
    return Form(
      key: unitFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Swap unit with",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            onSaved: (String? value) {
              swapIndex = int.parse(value!);
            },
            decoration: const InputDecoration(
              hintText: 'Enter a number',
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
                if (unitFormKey.currentState!.validate()) {
                  unitFormKey.currentState!.save();
                  if (widget.hskList[swapIndex - 1]["unit_id"] == swapIndex) {
                    String swapName =
                        widget.hskList[swapIndex - 1]["unit_name"];
                    SQLHelper.swapUnits(
                      pressedUnit: pressedIndex,
                      swapUnit: swapIndex,
                      pressedName: pressedName,
                      swapName: swapName,
                    );
                    widget.update();
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class InsertUnitAtIndexForm extends StatefulWidget {
  const InsertUnitAtIndexForm(
      {super.key, required this.update, required this.pressedIndex});
  final int pressedIndex;
  final Function update;

  @override
  State<InsertUnitAtIndexForm> createState() => _InsertUnitAtIndexFormState();
}

class _InsertUnitAtIndexFormState extends State<InsertUnitAtIndexForm> {
  final GlobalKey<FormState> unitInsertKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    late int insertAt;
    return Form(
      key: unitInsertKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Insert unit at",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            onSaved: (String? value) {
              insertAt = int.parse(value!);
            },
            decoration: const InputDecoration(
              hintText: 'Enter a number',
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
                if (unitInsertKey.currentState!.validate()) {
                  unitInsertKey.currentState!.save();
                  SQLHelper.insertUnitAt(
                    pressedUnit: widget.pressedIndex,
                    unitInsertNum: insertAt,
                  );
                  widget.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class MergeUnitsForm extends StatefulWidget {
  const MergeUnitsForm(
      {super.key, required this.pressedIndex, required this.update});
  final int pressedIndex;
  final Function update;

  @override
  State<MergeUnitsForm> createState() => _MergeUnitsFormState();
}

class _MergeUnitsFormState extends State<MergeUnitsForm> {
  final GlobalKey<FormState> mergeUnitsKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    late int mergeWith;
    return Form(
      key: mergeUnitsKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Merge unit with",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            onSaved: (String? value) {
              mergeWith = int.parse(value!);
            },
            decoration: const InputDecoration(
              hintText: 'Enter a number',
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
                if (mergeUnitsKey.currentState!.validate()) {
                  mergeUnitsKey.currentState!.save();
                  SQLHelper.mergeUnits(
                    pressedUnit: widget.pressedIndex,
                    mergeUnit: mergeWith,
                  );
                  widget.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class SetVisibilityForm extends StatefulWidget {
  const SetVisibilityForm(
      {super.key,
      required this.hskList,
      required this.index,
      required this.update});
  final List<Map<String, dynamic>> hskList;
  final int index;
  final Function update;

  @override
  State<SetVisibilityForm> createState() => _SetVisibilityFormState();
}

class _SetVisibilityFormState extends State<SetVisibilityForm> {
  late int visible;
  final GlobalKey<FormState> visibilityKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    print(widget.hskList[widget.index]);
    int pressedVisibility = widget.hskList[widget.index]["visible"];
    return Form(
      key: visibilityKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Change unit visibility",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextFormField(
            onSaved: (String? value) {
              visible = int.parse(value!);
            },
            initialValue: pressedVisibility.toString(),
            decoration: const InputDecoration(
              hintText: 'Enter a new name',
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
                if (visibilityKey.currentState!.validate()) {
                  visibilityKey.currentState!.save();
                  int id = widget.hskList[widget.index]["unit_id"];
                  SQLHelper.updateVisibility(id: id, newVisibility: visible);
                  widget.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
