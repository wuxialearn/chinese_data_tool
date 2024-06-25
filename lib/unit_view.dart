import 'package:chinese_data_tool/hsk_listview.dart';
import 'package:chinese_data_tool/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'hsk_wrapview.dart';

class UnitView extends StatefulWidget {
  final int unit; final String name; final String courseName; final Function updateHomeHsk;
  const UnitView({Key? key, required this.unit, required this.name, required this.courseName, required this.updateHomeHsk}) : super(key: key);

  @override
  State<UnitView> createState() => _UnitViewState();
}

class _UnitViewState extends State<UnitView> {
  late Future<List<Map<String, dynamic>>> hskFuture;
  late Future<List<Map<String, dynamic>>> sentencesFuture;

  @override
  initState() {
    super.initState();
    hskFuture = SQLHelper.getUnitWithMissingSentences(widget.unit);
    //hskFuture = SQLHelper.getUnit(widget.unit);
    sentencesFuture = SQLHelper.getSentences(widget.unit);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.updateHomeHsk();
          }
        ),
        middle: Text(widget.name),
      ),
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Visibility(
                      visible: false, maintainSize: true,
                      maintainAnimation: true, maintainState: true,
                      child: IconButton(onPressed: (){}, icon: const Icon(Icons.add, color: Colors.blue,),),
                    ),
                    const Text("Words", style: TextStyle(fontSize: 20),),
                    IconButton(
                        onPressed: (){
                          Future<List<Map<String, dynamic>>> newWordsFuture = SQLHelper.getNewWords(courseName: widget.courseName);
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => _SelectHskDialog(
                                hskList: newWordsFuture,
                                unit: widget.unit,
                                update: (){
                                  setState(() {
                                    hskFuture = SQLHelper.getUnitWithMissingSentences(widget.unit);
                                    //hskFuture = SQLHelper.getUnit(widget.unit);
                                  });
                                }
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.blue,)
                    ),
                  ]
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: HskWrapView(
                  hskList: hskFuture,
                  showTranslation: true,
                  color: Colors.transparent,
                  updateWords: (){
                    setState(() {
                      hskFuture = SQLHelper.getUnitWithMissingSentences(widget.unit);
                      //hskFuture = SQLHelper.getUnit(widget.unit);
                    });
                  }
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: false, maintainSize: true,
                    maintainAnimation: true, maintainState: true,
                    child: IconButton(onPressed: (){}, icon: const Icon(Icons.add, color: Colors.blue,),),
                  ),
                  const Text("Sentences", style: TextStyle(fontSize: 20),),
                  IconButton(onPressed: (){
                    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                    late String hanzi;
                    late String translation;
                    late String pinyin;
                    late int subunit;
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
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    TextFormField(
                                      onSaved: (String? value){hanzi = value!;},
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Hanzi',
                                      ),
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {return 'Please enter some text';}
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      onSaved: (String? value){translation = value!;},
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Translation',
                                      ),
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {return 'Please enter some text';}
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      onSaved: (String? value){pinyin = value!;},
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Pinyin',
                                      ),
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {return 'Please enter some text';}
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      onSaved: (String? value){subunit = int.parse(value!);},
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Subunit',
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
                                          if (formKey.currentState!.validate()) {
                                            formKey.currentState!.save();
                                            SQLHelper.insertSentence(unit: widget.unit, characters: hanzi, pinyin: pinyin, meaning: translation, subunit: subunit, course: widget.courseName);
                                            setState(() {
                                              hskFuture = SQLHelper.getUnitWithMissingSentences(widget.unit);
                                              sentencesFuture = SQLHelper.getSentences(widget.unit);
                                            });
                                            Navigator.pop(context);
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
                  }, icon: const Icon(Icons.add), color: Colors.blue,),
                ],
              )
            ),
            _Sentences(
                sentencesFuture: sentencesFuture,
                updateSentencesFuture: (){
                  setState(() {
                    hskFuture = SQLHelper.getUnitWithMissingSentences(widget.unit);
                    sentencesFuture = SQLHelper.getSentences(widget.unit);
                  });
                }
            ),
          ],
        ),
      )
    );
  }
}

class _SelectHskDialog extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> hskList;
  final int unit;
  final Function update;
  const _SelectHskDialog({Key? key, required this.hskList, required this.unit, required this.update}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            HskListview(
              hskList: hskList,
              showTranslation: true,
              color: Colors.white,
              showNumbers: true,
              onClick: (int i){
                SQLHelper.addWord(id: i, unit: unit);
                update();
              }
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: ()=> Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sentences extends StatelessWidget {
  const _Sentences({super.key, required this.sentencesFuture, required this.updateSentencesFuture});
  final Future<List<Map<String, dynamic>>> sentencesFuture;
  final Function updateSentencesFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: sentencesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>>? sentences = snapshot.data;
            if (sentences!.isEmpty){
              return const SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("There are no sentences yet for this unit", style: TextStyle(fontSize: 20),),
                  ],
                ),
              );
            }else{
              List<int> unitIndex = [0];
              List<int> unitLength = [];
              int lastIndex = 1;
              int length = 0;
              for (int i = 0; i < sentences.length; i++){
                if(sentences[i]["subunit"] != lastIndex){
                  unitIndex.add(i);
                  lastIndex++;
                  unitLength.add(i - length - 1);
                  length += i - length -1;
                }
                if (i == sentences.length -1){
                  unitLength.add(i - length);
                }
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                    childCount: sentences.length,
                        (BuildContext context, int index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            unitIndex.contains(index)?
                            Text("subunit ${unitIndex.indexOf(index) +1}", style: const TextStyle(color: Colors.blue),)
                                :const SizedBox(height: 0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sentences[index]["pinyin"], overflow: TextOverflow.ellipsis,),
                                      Text(sentences[index]["characters"], style: const TextStyle(fontSize: 20),overflow: TextOverflow.ellipsis,),
                                      Text(sentences[index]["meaning"], style: const TextStyle(fontSize: 20),overflow: TextOverflow.ellipsis,),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: (){
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => Dialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 30,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    SQLHelper.removeSentence(id: sentences[index]["id"]);
                                                    updateSentencesFuture();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final GlobalKey<FormState> unitFormKey = GlobalKey<FormState>();
                                                    late int newUnit;
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
                                                                      SQLHelper.updateSentenceSubunit(id: sentences[index]["id"], subunit: newUnit);
                                                                      updateSentencesFuture();
                                                                      Navigator.pop(context);
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
                                                  child: const Text('Edit Subunit'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final GlobalKey<FormState> editSentenceFormKey = GlobalKey<FormState>();
                                                    late String newHanzi;
                                                    late String newMeaning;
                                                    late String newPinyin;
                                                    showDialog<String>(
                                                      context: context,
                                                      builder: (BuildContext context) => Dialog(
                                                        child: Form(
                                                          key: editSentenceFormKey,
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              TextFormField(
                                                                initialValue: sentences[index]["characters"],
                                                                onSaved: (String? value){newHanzi = value!;},
                                                                decoration: const InputDecoration(
                                                                  hintText: 'Enter new translation',
                                                                ),
                                                                validator: (String? value) {
                                                                  if (value == null || value.isEmpty) {return 'Please enter some text';}
                                                                  return null;
                                                                },
                                                              ),
                                                              TextFormField(
                                                                initialValue: sentences[index]["meaning"],
                                                                onSaved: (String? value){newMeaning = value!;},
                                                                decoration: const InputDecoration(
                                                                  hintText: 'Enter new translation',
                                                                ),
                                                                validator: (String? value) {
                                                                  if (value == null || value.isEmpty) {return 'Please enter some text';}
                                                                  return null;
                                                                },
                                                              ),
                                                              TextFormField(
                                                                initialValue: sentences[index]["pinyin"],
                                                                onSaved: (String? value){newPinyin = value!;},
                                                                decoration: const InputDecoration(
                                                                  hintText: 'Enter new translation',
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
                                                                    if (editSentenceFormKey.currentState!.validate()) {
                                                                      editSentenceFormKey.currentState!.save();
                                                                      List<String> list = [newHanzi, newMeaning, newPinyin, index.toString()];
                                                                      SQLHelper.updateSentence(hanzi: newHanzi, meaning: newMeaning, pinyin: newPinyin, id: sentences[index]["id"]);
                                                                      updateSentencesFuture();
                                                                      Navigator.pop(context);
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
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.settings_suggest, size: 30,),
                                )
                              ],
                            ),
                            const Divider(height: 20, thickness: 1, indent: 5, endIndent: 5, color: Colors.grey,),
                          ],
                        ),
                      );
                    }
                ),
              );}
          }
          else{return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));}
        }
    );
  }
}
