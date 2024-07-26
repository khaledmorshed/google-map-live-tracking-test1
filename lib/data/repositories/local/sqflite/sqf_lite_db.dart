import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' ;

class SqfLitDb{
  static Database? _database;
  static int dbVersion = 0;
  static String createTableInfo = "";
  static String previousTableInfo = "";
  //_initDb will call every time if we insert, delete, update something in database
  static Future<Database> _initDb({String databaseName = "main_db"}) async{
    final rootPath = await getDatabasesPath();
    final dbPath = join(rootPath, databaseName);
    return await openDatabase(dbPath, version: 1, onCreate: _createDb, onUpgrade: _upgradeDb);
  }

  //create table for first time
  static Future _createDb(Database db, int version)async{
    print('firstTime.......$version');
    await db.execute(createTableInfo);
  }

  //create table during version updating
  static Future<void>  _upgradeDb(Database db, int oldVersion, int newVersion)async{
    print('db upgrade.......1...old...$oldVersion.....new....$newVersion');
    if (oldVersion != newVersion) {
      await db.execute(createTableInfo);
    }
  }

  //if you create first table then you will not create another table with build in onCreate function. so you need this _createAnewTableWithoutBuildInFunction function
  static Future<void> _createAnewTableWithoutBuildInFunction(Database db, String table) async {
    await db.execute(table);
  }

  //insert data into table of database with onCreate function which is build in. it is for creating table first time
  static Future<int> createDatabaseFirstTimeAndInsertDataInTable({required String tableName, required String createTableInformation, required var map, String databaseName = "main_db"}) async{
    //print("..nae.........${nameIdDbModel.id}...${nameIdDbModel.name}");
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'main_db');

    // Check if the database exists
    bool doesDatabaseExist = await databaseExists(path);
    print("doesDatabaseExist..fir...$doesDatabaseExist....$tableName");

    createTableInfo = createTableInformation;
    final db = await _initDb(databaseName: databaseName);
    return db.insert(tableName, map);
  }

  //insert data into table of database without build in function because if you create first table then you can not create table with build in onCreate function.
  static Future<int> insertDataInTableWithoutBuildINFunction({required String tableName, required String createTableInformation, required var map, String databaseName = "main_db"}) async{
    try{
      //print("..nae.........${nameIdDbModel.id}...${nameIdDbModel.name}");
      // createTableInfo = createTableInformation;

      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, databaseName);

      // Check if the database exists
      bool doesDatabaseExist = await databaseExists(path);
      print("doesDatabaseExist..sec...$doesDatabaseExist......$tableName");

      final db = await _initDb(databaseName: databaseName);
      await _createAnewTableWithoutBuildInFunction(db, createTableInformation);
      return db.insert(tableName, map);
    }catch(err){
      throw err;
    }
  }

  //insert data into table of database with onCreate function which is build in. it is for creating table first time
  static Future<dynamic> createDatabaseAndInsertDataInTable({required String tableName, required String createTableInformation,  var map, String databaseName = "main_db"}) async{
    //print("..nae.........${nameIdDbModel.id}...${nameIdDbModel.name}");

    var databasesPath = await getDatabasesPath();
    print("databasesPath....$databasesPath");
    String path = join(databasesPath, databaseName);
    // Check if the database exists
    bool doesDatabaseExist = await databaseExists(path);
    print("doesDatabaseExist..sale...$doesDatabaseExist.....$tableName....map=");
    print("createTableInformation////....$createTableInformation");
    if(doesDatabaseExist == false){
      createTableInfo = createTableInformation;
      print("createTableInfo////....$createTableInfo");
      final db = await _initDb(databaseName: databaseName);
      return db.insert(tableName, map);
    }else{
      final db = await _initDb(databaseName: databaseName);
      await _createAnewTableWithoutBuildInFunction(db, createTableInformation);
      return db.insert(tableName, map);
    }

  }

  //search a row inside of table with specific id
  //also we have to create a shadow method of getContactByIdInDb in provider
  // static Future<ClientDbModel> getInformationBySearchingFromATable({required String tableName, String filterText = ""})async{
  //   final db = await _initDb();
  //   //specific row with id
  //   final List<Map<String, dynamic>> mapList = await db.query(tableClient, where: '$tableClientColumnId = ?', whereArgs: [id]);
  //   //here 1 model will return with firt item which will match with above query
  //   return ClientDbModel.fromMap(mapList.first);
  // }

  static Future<List<Map<String, dynamic>>> getInformationBySearchingFromATable({required String tableName, String filterText = "", String databaseName = "main_db"}) async {
    try{
      final db = await _initDb(databaseName: databaseName);
      // Use the query method to search for records with a matching filter text.
      final result = await db.query(
        tableName,
        where: 'Id LIKE ? OR Name LIKE ?',
        whereArgs: ['%$filterText%', '%$filterText%'], // Use '%' to match any characters before and after the filter
      );
      //print("#$tableName's RESULT//..........${result.toString()}");
      return result;
    }catch(err){
      return [];
    }
  }

  //get data when column and value will be passed
  static Future<List<Map<String, dynamic>>> getAnAccountList({
    required String tableName,
    required List<String> columns,
    required String where,
    required List<dynamic> whereArgs,
    String databaseName = "main_db"
  }) async {
    final db = await _initDb(databaseName: databaseName);

    List<Map<String, dynamic>> results = await db.query(
      tableName,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
    );
    return results;
  }


  //for deleting ContactModel with id
  //which row it delete, it return that's id
  // static Future<int> deleteContactByIdInDb(int id)async{
  //   final db = await _initDb();
  //   return db.delete(tableClient, where: '$tableClientColumnId = ?', whereArgs: [id]);
  // }

  // //update favorite value
  // static Future<int> updateContactFavoriteByIdInDb(int id, int value) async{
  //   final db = await openDatabase();
  //   return db.update(tableContact, {tableContactColumnFavorite: value}, where: '$tableContactColumnId = ?' ,whereArgs: [id]);
  // }


  //get any data from table with passing table name and filter text
  static Future<List<Map<String, dynamic>>> getAnyTableDataFromLocalDb({required String tableName, String filterText = "", String databaseName = "main_db"}) async {
    try{
      final db = await _initDb(databaseName: databaseName);
      // Use the query method to search for records with a matching filter text.
      final result = await db.query(
        tableName,
        where: 'Id LIKE ? OR Name LIKE ?',
        whereArgs: ['%$filterText%', '%$filterText%'], // Use '%' to match any characters before and after the filter
      );
     // print("#$tableName's RESULT//..........${result.toString()}");
      return result;
    }catch(err){
      return [];
    }
  }

  //get any data from table with passing table name
  static Future<List<Map<String, dynamic>>> getAnyTableDataFromLocalDbWitPassingOnlyTableName({required String tableName, String databaseName = "main_db"}) async {
    try{
      final db = await _initDb(databaseName: databaseName);
      final result = await db.query(
        tableName,
      );
      // print("#$tableName's RESULT//..........${result.toString()}");
      return result;
    }catch(err){
      return [];
    }
  }

  //get data when column and value will be passed
  static Future<List<Map<String, dynamic>>> getAnyDataListFromLocalDbWithColumnFilter({

    required String tableName,
    required List<String> columns,
    required String where,
    required List<dynamic> whereArgs,
    String databaseName = "main_db"
  }) async {
    try{
      final db = await _initDb(databaseName: databaseName);

      List<Map<String, dynamic>> results = await db.query(
        tableName,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
      );
      return results;
    }catch(err){
      return [];
    }
  }

  //without passing arguments
  static Future<List<Map<String, dynamic>>> getDataWithRawQueryWithoutPassingArgumentsFromLocalDatabase({required String rawQuery})async{

    final db = await _initDb(databaseName: "main_db");

    String query = '''
  SELECT product_table.product_type, product_table.product_id, clients.name, clients.id
  FROM product_table
  JOIN salesman_sales ON product_table.salesman_sale_id = salesman_sales.id
  JOIN clients ON salesman_sales.client_id = clients.id
  WHERE salesman_sales.id = 'specific_salesman_sale_id'
''';

    try{
      final List<Map<String, dynamic>> results = await db.rawQuery(rawQuery);
      return results;
    }catch(er){
      return [];
    }

  }

  //with passing arguments
  static Future<List<Map<String, dynamic>>> getDataWithRawQueryWithPassingArgumentsFromLocalDatabase({required String rawQuery, List<dynamic> arguments = const[]})async{
    final db = await _initDb(databaseName: "main_db");
    String query = '''
  SELECT product_table.product_type, product_table.product_id, clients.name, clients.id
  FROM product_table
  JOIN salesman_sales ON product_table.salesman_sale_id = salesman_sales.id
  JOIN clients ON salesman_sales.client_id = clients.id
  WHERE salesman_sales.id = 'specific_salesman_sale_id'
''';
    try{
      final List<Map<String, dynamic>> results = await db.rawQuery(rawQuery, arguments);
      return results;
    }catch(er){
      return [];
    }

  }

  //update table value
  static Future<void> updateAnyTableDataFromLocalDb({
    required String tableName,
    required dynamic updateColumnValues,
    required String where,
    required List<dynamic> whereArgs,
    String databaseName = "main_db"
  }) async {
    try{

      final db = await _initDb(databaseName: databaseName);
      await db.update(
        tableName,
        updateColumnValues,
        where: where,
        whereArgs: whereArgs,
      );
      return;
    }catch(err){
      return;
    }
  }


  //delete any table with direct and with passing value
  static Future<bool> deleteAnyTableDataFromLocalDb({
    required String tableName,
     String? where,
    List<dynamic>? whereArgs,
    bool isTableDataDirectReset = true,
    String databaseName = "main_db"
  }) async {
    try{
      final db = await _initDb(databaseName: databaseName);
      if (isTableDataDirectReset == false) {
        //await db.delete(table, where: 'is_id_fake = ?', whereArgs: [true]);
        print("delete..indirect...$tableName");
        await db.delete(tableName, where: where, whereArgs: whereArgs);
        print("delete..indirect...2$tableName");
      } else {
        print("delete..direct...$tableName");
        await db.delete(tableName);
      }
      return true;
    }catch(err){
      return false;
    }
  }



  static Future<void> deleteDatabaseFile({String databaseName = "main_db"}) async {
    print("main...db....de");
    try{
      final rootPath = await getDatabasesPath();
      final dbPath = join(rootPath, databaseName);

      // Close any open database connection.
      if (_database != null) {
        await _database?.close();
        _database = null;
      }

      // Delete the database file.
      await deleteDatabase(dbPath);
      print("sucess.......delete....+$databaseName");
    }catch(err){
      throw err;
    }
  }

}