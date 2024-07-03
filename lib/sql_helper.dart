//create a copy of pg_connection_example.dart called pg_connection.dart
import 'package:chinese_data_tool/pg_connection.dart';
import 'package:postgres/postgres.dart';

class SQLHelper {
  static late PostgreSQLConnection connection;
  static bool connected = false;

  static Future<PostgreSQLConnection> psql() async {
    if (connected == false || connection.isClosed) {
      //create a copy of pg_connection_example.dart called pg_connection.dart
      final con = ConnectionInfo();
      connection = PostgreSQLConnection(con.host, con.port, con.databaseName,
          username: con.username, password: con.password, useSSL: con.useSSL);
      await connection.open();
      connected = true;
    }
    return connection;
  }

  static void insertSentence(
      {required int unit,
      required String characters,
      required String pinyin,
      required String meaning,
      required int subunit,
      required String course}) async {
    final db = await SQLHelper.psql();
    String sql = """
    INSERT into sentences(unit, characters, pinyin, meaning, subunit, course)
    VALUES (@a, @b, @c, @d, @e, '$course')
    """;
    final Map<String, dynamic> substitutionValues = {
      "a": unit,
      "b": characters,
      "c": pinyin,
      "d": meaning,
      "e": subunit
    };
    int completed =
        await db.execute(sql, substitutionValues: substitutionValues);
    print("insert Sentence result: $completed");
    while (completed != 1) {
      await db.execute(sql, substitutionValues: substitutionValues);
    }
  }

  static Future<void> updateSentenceSubunit(
      {required int id, required int subunit}) async {
    final db = await SQLHelper.psql();
    final String sql = "UPDATE sentences SET subunit = $subunit WHERE id = $id";
    db.execute(sql);
  }

  static void updateWordTranslation(
      {required int id, required String value}) async {
    final db = await SQLHelper.psql();
    final String sql =
        "UPDATE courses SET translations0 = '$value', custom_translation = true WHERE id = $id";
    db.execute(sql);
  }

  static void updateWord(
      {required int id,
      required String translation,
      required String hanzi,
      required String pinyin}) async {
    final db = await SQLHelper.psql();
    final String sql = """
    UPDATE courses SET 
      translations0 = '$translation', 
      hanzi = '$hanzi',
      pinyin = '$pinyin',
      custom_translation = true 
    WHERE id = $id
    """;
    db.execute(sql);
  }

  static void updateSentence(
      {required String hanzi,
      required meaning,
      required pinyin,
      required int id}) async {
    final db = await SQLHelper.psql();
    final String sql =
        "UPDATE sentences SET characters = @a,  pinyin = @b, meaning = @c WHERE id = $id";
    final Map<String, dynamic> substitutionValues = {
      "a": hanzi,
      "b": pinyin,
      "c": meaning
    };
    db.execute(sql, substitutionValues: substitutionValues);
  }

  static void removeSentence({required int id}) async {
    final db = await SQLHelper.psql();
    final String sql = "DELETE FROM sentences WHERE id = $id";
    db.execute(sql);
  }

  static void removeWord({required id}) async {
    final db = await SQLHelper.psql();
    final String sql =
        "UPDATE courses SET unit = NULL, subunit = NULL WHERE id = $id";
    db.execute(sql);
  }

  static void updateSubunit({required int id, required int subunit}) async {
    final db = await SQLHelper.psql();
    final String sql = "UPDATE courses SET subunit = $subunit WHERE id = $id";
    db.execute(sql);
  }

  static void addWord({required int id, required int unit}) async {
    final db = await SQLHelper.psql();
    final String sql =
        "UPDATE courses SET unit = $unit, subunit = 1 WHERE id = $id";
    db.execute(sql);
  }

  static Future<List<Map<String, dynamic>>> getNewWords({
    required String courseName,
    String sortBy = "hsk, pinyin ASC",
  }) async {
    final db = await SQLHelper.psql();
    String hsk = "";
    if (courseName == "hsk") {
      hsk = "AND hsk < 5";
    }
    String sql = """
      SELECT
        id, hanzi, pinyin, translations0, ROW_NUMBER () OVER (ORDER BY hsk, pinyin ASC)
      FROM courses
      WHERE course = '$courseName' AND unit IS NULL $hsk
      ORDER BY $sortBy
    """;
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery(sql);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      result.add({...row["courses"]!, ...row[""]!});
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getCourseUnits(
      String course) async {
    final db = await SQLHelper.psql();
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery("""
      SELECT units.unit_id, units.unit_name, units.hsk, units.unit_order, units.visible, QTY.quantity FROM units
      LEFT JOIN
          (SELECT COUNT(courses.unit) AS quantity, courses.unit FROM courses GROUP BY courses.unit) AS QTY
      ON units.unit_id = QTY.unit
      WHERE course = '$course'
      ORDER BY units.unit_order
    """);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      final Map<String, dynamic> combined = {...row["units"]!, ...row[""]!};
      result.add(combined);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getCourseUnitsWithCompletionBoolean(
      String course) async {
    final db = await SQLHelper.psql();
    final String sql = """
    select unit_id, unit_name, hsk, unit_order, completed, visible, QTY.quantity from(
      select units.unit_id as unit_id, 
      units.unit_name as unit_name, 
      units.hsk as hsk, 
      units.unit_order as unit_order,
      units.visible as visible,
      completed_units.completed is null as completed from units
      left join (
        select courses.unit as completed from courses 
        where unit = unit and id not in (
          select courses.id from courses
          join sentences 
          on sentences.characters like '%' || courses.hanzi || '%'
          where courses.unit = courses.unit and sentences.unit = courses.unit
          and courses.course = '$course'
          group by courses.id
        )
        and courses.course = '$course'
        group by courses.unit
      )
      as completed_units on units.unit_id = completed_units.completed
      where units.course = '$course'
      order by units.unit_order
    ) as cte  
    LEFT JOIN
    (SELECT COUNT(courses.unit) AS quantity, courses.unit FROM courses GROUP BY courses.unit) AS QTY
    ON cte.unit_id = QTY.unit
    ORDER BY unit_order
    """;
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery(sql);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      final Map<String, dynamic> combined = {...row["units"]!, ...row[""]!};
      result.add(combined);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> findWord(String newWord) async {
    final db = await SQLHelper.psql();
    late String column;
    String word = newWord;
    if (RegExp(r"(ā|á|ǎ|à|ē|é|ě|è|ī|í|ǐ|ì|ō|ó|ǒ|ò|ū|ú|ǔ|ù|ǖ|ǘ|ǚ|ǜ)",
            unicode: true)
        .hasMatch(newWord)) {
      column = "pinyin";
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
      newWord.replaceAllMapped(
          RegExp(r"(ā|á|ǎ|à|ē|é|ě|è|ī|í|ǐ|ì|ō|ó|ǒ|ò|ū|ú|ǔ|ù|ǖ|ǘ|ǚ|ǜ)",
              unicode: true), (match) {
        return pinyinToNumber[match[0]]!;
      });
      newWord = "'%$newWord%'";
    } else if (RegExp(r"\p{Script=Hani}", unicode: true).hasMatch(newWord)) {
      column = "hanzi";
      newWord = "'%$newWord%'";
    } else {
      newWord = "'%$newWord%'";
      column = "translations[1]";
    }
    String sql = """
      (SELECT id, hanzi, pinyin, ARRAY [translations0] as translations, course, hsk, unit
      FROM courses
      WHERE $column like '%$word%'
      ORDER BY CASE
      WHEN $column LIKE '$word' THEN 1
      WHEN $column LIKE '% $word' THEN 2
      WHEN $column LIKE '$word %' THEN 2
      WHEN $column LIKE '% $word %' THEN 2
      WHEN $column LIKE '$word%' THEN 3
      WHEN $column LIKE '%$word' THEN 5
      ELSE 4 end)
      UNION ALL (SELECT
        dict.id, dict.hanzi, dict.pinyin, dict.translations, 'CC-CEDICT', null, null
      FROM dict
      WHERE dict.$column like '%$word%'
      ORDER BY CASE
      WHEN dict.$column LIKE '$word' THEN 1
      WHEN dict.$column LIKE '% $word' THEN 2
      WHEN dict.$column LIKE '$word %' THEN 2
      WHEN dict.$column LIKE '% $word %' THEN 2
      WHEN dict.$column LIKE '$word%' THEN 3
      WHEN dict.$column LIKE '%$word' THEN 5
      ELSE 4 end
      limit 100)
    """;
    print(sql);
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery(sql);
    print(await results);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      result.add({...row[""]!});
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getUnit(int unit) async {
    final db = await SQLHelper.psql();
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery("""
      SELECT
        id, hanzi, pinyin, translations0, subunit
      FROM courses  
      WHERE unit = $unit
      ORDER BY subunit ASC
    """);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      result.add(row["courses"]!);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getUnitWithMissingSentences(
      int unit) async {
    final db = await SQLHelper.psql();
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery("""
    select  cte_2.id, cte_2.hanzi, cte_2.pinyin, cte_2.translations0, cte_2.subunit, cte_2.completed from(
    select DISTINCT on (cte.id)  cte.id, cte.hanzi, cte.pinyin, cte.translations0, cte.subunit, cte.completed from
      (select
      courses.id, courses.hanzi, courses.pinyin, courses.translations0, courses.subunit,
      sentences.unit is not null as completed
      from courses
      join sentences 
      on sentences.characters like '%' || courses.hanzi || '%'
      where courses.unit = $unit and sentences.unit = $unit
      union select courses.id, courses.hanzi, courses.pinyin, courses.translations0, courses.subunit,
      1 is null from courses
      where unit = $unit
      order by id) as cte 
      order by cte.id, completed desc
      )as cte_2
    order by cte_2.subunit, cte_2.completed
    """);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      final Map<String, dynamic> combined = {...row[""]!};
      result.add(combined);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getSentences(int unit) async {
    final db = await SQLHelper.psql();
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery("""
      SELECT
        characters, pinyin, meaning, id, subunit
      FROM sentences  
      WHERE unit = $unit
      ORDER BY subunit
    """);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      result.add(row["sentences"]!);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getLiteralDefinitions() async {
    final db = await SQLHelper.psql();
    List<Map<String, Map<String, dynamic>>> results =
        await db.mappedResultsQuery("""
      select * from literal_translations 
      join courses on courses.id = literal_translations.word_id
      where literal_translation is null and hsk < 5
    """);
    List<Map<String, dynamic>> result = [];
    for (final row in results) {
      result.add(row["literal_translations"]!);
    }
    return result;
  }

  static Future<void> setLiteralTranslation(int id, int wordId) async {
    final db = await SQLHelper.psql();
    db.execute(
        "update courses set literal_translation = $id where id = $wordId");
  }

  static Future<void> setUnitOrder(
      {required int unit, required int order}) async {
    final db = await SQLHelper.psql();
    db.execute("update units set unit_order = $order where unit_id = $unit");
  }

  static void swapUnits(
      {required int pressedUnit,
      required int swapUnit,
      required String pressedName,
      required String swapName}) async {
    final db = await SQLHelper.psql();
    db.execute("""
      BEGIN;
      
      update sentences 
      set unit = (case when unit = $pressedUnit then $swapUnit else $pressedUnit end) 
      where unit = $pressedUnit or unit = $swapUnit;

      update courses 
      set unit = (case when unit = $pressedUnit then $swapUnit else $pressedUnit end) 
      where unit = $pressedUnit or unit = $swapUnit;

      update units 
      set unit_name = (case when unit_id = $pressedUnit then '$swapName' else '$pressedName' end) 
      where unit_id = $pressedUnit or unit_id = $swapUnit;
      
      COMMIT;
    """);
  }

  static void insertUnitAt({
    required int pressedUnit,
    required int unitInsertNum,
  }) async {
    final db = await SQLHelper.psql();
    db.execute("""
      BEGIN;
    
      update units 
      set unit_id = (case when unit_id = $pressedUnit then $unitInsertNum else unit_id +1 end) 
      where unit_id >= $unitInsertNum and unit_id <= $pressedUnit;

      update courses 
      set unit = (case when unit = $pressedUnit then $unitInsertNum else unit +1 end) 
      where unit >= $unitInsertNum and unit <= $pressedUnit;

      update courses 
      set unit = (case when unit = $pressedUnit then $unitInsertNum else unit +1 end) 
      where unit >= $unitInsertNum and unit <= $pressedUnit;
      
      COMMIT;
    """);
  }

  static Future<void> updateUnitName(
      {required int id, required String newName}) async {
    final db = await SQLHelper.psql();
    db.execute("update units set unit_name = @a where unit_id = $id",
        substitutionValues: {"a": newName});
  }

  static Future<void> updateVisibility(
      {required int id, required int newVisibility}) async {
    final db = await SQLHelper.psql();
    db.execute("update units set visible = @a where unit_id = $id",
        substitutionValues: {"a": newVisibility});
  }

  static void createNewUnit(
      {required String name, required int? hsk, required String course}) async {
    final db = await SQLHelper.psql();
    db.execute(
        "insert into units (course, unit_name, hsk) values (@a, @b, $hsk)",
        substitutionValues: {"a": course, "b": name});
  }

  static void setUnitHskLevel({required int unit, required int hsk}) async {
    final db = await SQLHelper.psql();
    db.execute("update units set hsk = $hsk where unit_id = $unit");
  }

  static void addWordToCustomCourse({
    required String course,
    required String hanzi,
    required String pinyin,
    required String translations0,
    int? unit,
  }) async {
    final db = await SQLHelper.psql();
    late String sql;
    if (unit == null) {
      sql = """INSERT into 
        courses (course, hanzi, pinyin, translations0 ) 
        VALUES ('$course', '$hanzi', '$pinyin', '$translations0')
        """;
    } else {
      sql = """INSERT into 
        courses (course, hanzi, pinyin, translations0, unit, subunit) 
        VALUES ('$course', '$hanzi', '$pinyin', '$translations0', '$unit', 1)
        """;
    }
    db.execute(sql);
  }

  static void mergeUnits({
    required int pressedUnit,
    required int mergeUnit,
  }) async {
    final db = await SQLHelper.psql();
    final int lowerUnit = pressedUnit > mergeUnit ? mergeUnit : pressedUnit;
    final int higherUnit = pressedUnit > mergeUnit ? pressedUnit : mergeUnit;

    db.execute("""
      BEGIN;
      
      update sentences 
      set unit = $lowerUnit
      where unit = $lowerUnit or unit = $higherUnit;

      update courses 
      set unit = $lowerUnit
      where unit = $lowerUnit or unit = $higherUnit;

      delete from units where unit_id = $higherUnit;
      
      COMMIT;
    """);
  }
}
