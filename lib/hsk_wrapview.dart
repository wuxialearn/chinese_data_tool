import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/material.dart';

class HskWrapView extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> hskList;
  final bool showTranslation;
  final Color color;
  final Function() updateWords;
  const HskWrapView({Key? key, required  this.hskList, required this.showTranslation, required this.color, required this.updateWords,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: hskList,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>>? hskList = snapshot.data;
            List<int> unitIndex = [0];
            List<int> unitLength = [];
            int lastIndex = 1;
            int length = 0;
            for (int i = 0; i < hskList!.length; i++){
              if(hskList[i]["subunit"] != lastIndex){
                unitIndex.add(i);
                lastIndex++;
                unitLength.add(i - length);
                length += i - length;
              }
              if (i == hskList.length -1){
                unitLength.add(i - length +1);
              }
            }
            return Column(
              children: List<Widget>.generate(unitIndex.length, (i) {
                return Column(
                  children: [
                    Text("unit ${i+1}"),
                    Wrap(
                      children: List<Widget>.generate(unitLength[i], (index) {
                        return _HskWrapViewItem(
                          hskList: hskList[unitIndex[i]+index],
                          showTranslation: showTranslation,
                          separator: true,
                          updateWords: updateWords,
                        );
                      }),
                    ),
                  ],
                );
              }),
            );
          }
          else{return const Center(child: CircularProgressIndicator());}
        }
    );
  }
}
class _HskWrapViewItem extends StatelessWidget {
  final Map<String, dynamic> hskList;
  final bool showTranslation;
  final bool separator;
  final Function updateWords;
  const _HskWrapViewItem({Key? key, required this.hskList, required this.showTranslation, required this.separator, required this.updateWords,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onLongPress: (){
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: _HskDialog(hskList: hskList, updateWords: updateWords)
            ),
          );
        },
        child: Row(
          mainAxisSize:  MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                    children: [
                      Text(
                        hskList["pinyin"],
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "${hskList["hanzi"]} ",
                        style: TextStyle(fontSize: 25, color: hskList.containsKey("completed")?
                          hskList["completed"]? Colors.black : Colors.red : Colors.black
                        ),
                      ),
                    ]
                ),
                Visibility(
                  visible: showTranslation,
                  child: Text(
                    hskList["translations0"],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999EA3),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HskDialog extends StatefulWidget {
  final Map<String, dynamic> hskList;
  final Function updateWords;
  const _HskDialog({Key? key, required this.hskList, required this.updateWords}) : super(key: key);

  @override
  State<_HskDialog> createState() => _HskDialogState();
}

class _HskDialogState extends State<_HskDialog> {
  final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> unitFormKey = GlobalKey<FormState>();
  late String newTranslation;
  late int newUnit;
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              TextButton(
                                  onPressed: (){
                                    SQLHelper.removeWord(id: widget.hskList["id"]);
                                    widget.updateWords();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("delete")
                              ),
                              TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("cancel"))
                            ],
                          ),
                        ],
                      )
                  ),
                );
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Form(
                      key: unitFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.number,
                            onSaved: (String? value){newUnit = int.parse(value!);},
                            decoration: const InputDecoration(
                              hintText: 'Enter a number',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {return 'Please enter some text';}
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (unitFormKey.currentState!.validate()) {
                                  unitFormKey.currentState!.save();
                                  SQLHelper.updateSubunit(id: widget.hskList["id"], subunit: newUnit);
                                  widget.updateWords();
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
              child: const Text('Edit subunit'),
            ),
            TextButton(
              onPressed: () {
                final GlobalKey<FormState> editWordKey = GlobalKey<FormState>();
                String newHanzi = widget.hskList["hanzi"];
                late String newTranslation;
                late String newPinyin;
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Form(
                      key: editWordKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            initialValue: widget.hskList["hanzi"],
                            onSaved: (String? value){newHanzi = value!;},
                            decoration: const InputDecoration(
                              hintText: 'Enter hanzi',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {return 'Please enter some text';}
                              return null;
                            },
                          ),
                          TextFormField(
                            initialValue: widget.hskList["translations0"],
                            onSaved: (String? value){newTranslation = value!;},
                            decoration: const InputDecoration(
                              hintText: 'Enter translation',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {return 'Please enter some text';}
                              return null;
                            },
                          ),
                          TextFormField(
                            initialValue: widget.hskList["pinyin"],
                            onSaved: (String? value){newPinyin = value!;},
                            decoration: const InputDecoration(
                              hintText: 'Enter pinyin',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {return 'Please enter some text';}
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (editWordKey.currentState!.validate()) {
                                  editWordKey.currentState!.save();
                                  print("$newTranslation, $newHanzi, $newPinyin");
                                  SQLHelper.updateWord(id: widget.hskList["id"], translation: newTranslation, hanzi: newHanzi, pinyin: newPinyin);
                                  widget.updateWords();
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
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
