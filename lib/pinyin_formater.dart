const Map<String, String> pinyinToNumber = {
  "ā": "a1",
  "á": "a2",
  "ǎ": "a3",
  "à": "a4",
  "ē": "e1",
  "é": "e2",
  "ě": "e3",
  "è": "e4",
  "ī": "i1",
  "í": "i2",
  "ǐ": "i3",
  "ì": "i4",
  "ō": "o1",
  "ó": "o2",
  "ǒ": "o3",
  "ò": "o4",
  "ū": "u1",
  "ú": "u2",
  "ǔ": "u3",
  "ù": "u4",
  "ǖ": "u5",
  "ǘ": "u6",
  "ǚ": "u7",
  "ǜ": "u8",
};
const Map<String, String> numberToPinyin = {
  "a1": "ā",
  "a2": "á",
  "a3": "ǎ",
  "a4": "à",
  "e1": "ē",
  "e2": "é",
  "e3": "ě",
  "e4": "è",
  "i1": "ī",
  "i2": "í",
  "i3": "ǐ",
  "i4": "ì",
  "o1": "ō",
  "o2": "ó",
  "o3": "ǒ",
  "o4": "ò",
  "u1": "ū",
  "u2": "ú",
  "u3": "ǔ",
  "u4": "ù",
  "u5": "ǖ",
  "u6": "ǘ",
  "u7": "ǚ",
  "u8": "ǜ",
  "a5": "a",
  "e5": "e",
  "i5": "i",
  "o5": "o",
};

String toneNumberToPiyin(String toneNumberString) {
  return toneNumberString.replaceAllMapped(
      RegExp(
          r"(a1|a2|a3|a4|a5|e1|e2|e3|e4|e5|i1|i2|i3|i4|i5|o1|o2|o3|o4|05|u1|u2|u3|u4|u5|u6|u7|u8)",
          unicode: true), (match) {
    return numberToPinyin[match[0]]!;
  });
}

/*
List<String> keysList = pinyinToNumber.keys.toList();
    for (var i =0; i<pinyinToNumber.length; i++){
      str += '"${pinyinToNumber[keysList[i]]}": "${keysList[i]}", ';
    }
 */
