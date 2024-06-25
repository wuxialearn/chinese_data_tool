import 'package:flutter/material.dart';

class HskListview extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> hskList;
  final bool showTranslation;
  final Color color;
  final Function(int i) onClick;
  final bool showNumbers;
  const HskListview({Key? key, required  this.hskList, required this.showTranslation, required this.color, required this.onClick, this.showNumbers =false}) : super(key: key);

  get flutterTts => null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: hskList,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>>? hskList = snapshot.data;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:color,
                  ),
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    itemCount: hskList!.length,
                    itemBuilder: (context, index) {
                      return HskListviewItem(hskList: hskList[index], showTranslation: showTranslation, separator: true, onClick: onClick, showNumber: showNumbers, index: index);
                    },
                  ),
                ),
              ),
            );
          }
          else{return const Center(child: CircularProgressIndicator());}
        }
    );
  }
}

class HskListviewItem extends StatelessWidget {
  final Map<String, dynamic> hskList;
  final bool showTranslation;
  final bool separator;
  final Function(int i) onClick;
  final bool showNumber;
  final int index;
  final bool useGivenIndex;
  const HskListviewItem({Key? key, required this.hskList, required this.showTranslation, required this.separator, required this.onClick, required this.showNumber, required this.index, this.useGivenIndex = false,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize:  MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            showNumber? Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: useGivenIndex? Text(hskList["row_number"].toString()) :Text(index.toString()),
            ): const SizedBox(height: 0),
            GestureDetector(
              onTap:() {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                      child: Row(
                        children: [
                          TextButton(onPressed: (){onClick(hskList["id"]);Navigator.pop(context);}, child: const Text("Add word")),
                          TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Cancel"))
                        ],
                      )
                  ));
                },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      children: [
                        Text(
                          hskList["pinyin"],
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          hskList["hanzi"],
                          style: const TextStyle(fontSize: 25),
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
            ),
          ],
        ),
      ),
    );
  }
}